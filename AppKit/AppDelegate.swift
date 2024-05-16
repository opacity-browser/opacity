//
//  AppDelegate.swift
//  Opacity
//
//  Created by Falsy on 1/16/24.
//

import SwiftUI
import SwiftData
import CoreLocation

class OpacityWindowDelegate: NSObject, NSWindowDelegate, ObservableObject {
  var windowMap: [UUID:NSWindow] = [:]
  @Published var isFullScreen: Bool = false
  var lastActivationTime: Date?
  
  func windowWillEnterFullScreen(_ notification: Notification) {
    DispatchQueue.main.async {
      self.isFullScreen = true
    }
  }
  
  func windowDidEnterFullScreen(_ notification: Notification) {
  }
  
  func windowWillExitFullScreen(_ notification: Notification) {
    DispatchQueue.main.async {
      self.isFullScreen = false
    }
  }

  func windowDidExitFullScreen(_ notification: Notification) {
  }
  
  func windowDidBecomeMain(_ notification: Notification) {
    print("windowDidBecomeMain")
    let currentTime = Date()
    if let lastTime = lastActivationTime {
      let elapsedTime = currentTime.timeIntervalSince(lastTime)
      if elapsedTime >= 3600 {
        AppDelegate.shared.deleteExpiredData()
        lastActivationTime = currentTime
      }
    } else {
      AppDelegate.shared.deleteExpiredData()
      lastActivationTime = currentTime
    }
  }
  
  func windowWillClose(_ notification: Notification) {
    print("windowWillClose")
    guard let window = notification.object as? NSWindow else { return }
    let frameString = NSStringFromRect(window.frame)
    UserDefaults.standard.set(frameString, forKey: "lastWindowFrame")
  }
  
  func windowShouldClose(_ sender: NSWindow) -> Bool {
    print("windowShouldClose")
    let windowNumber = sender.windowNumber
    if let browser = AppDelegate.shared.service.browsers[windowNumber] {
      let tabs = browser.tabs
      for tab in tabs {
        AppDelegate.shared.closeInspector(tab.id)
      }
      browser.closeAllTab {
        browser.tabs = []
        AppDelegate.shared.service.browsers[windowNumber] = nil
        sender.close()
      }
      return false
    } else {
      return true
    }
  }
}


class AppDelegate: NSObject, NSApplicationDelegate {
  static var shared: AppDelegate!
  private var isTerminating = false
  
  var prevWindow: NSWindow?
  var windowMap: [UUID:NSWindow] = [:]
  
  var service: Service = Service()
  let locationManager = CLLocationManager()
  let windowDelegate = OpacityWindowDelegate()
  
  var sidebarToggleMenuItem: NSMenuItem!
  
  override init() {
    super.init()
    NotificationCenter.default.addObserver(self, selector: #selector(windowDidResignKey(notification:)), name: NSWindow.didResignKeyNotification, object: nil)
  }
  
  @objc func windowDidResignKey(notification: Notification) {
    if let keyWindow = NSApplication.shared.keyWindow {
      let windowNo = keyWindow.windowNumber
      if let pWindow = self.prevWindow {
        if pWindow.windowNumber != windowNo {
          if pWindow.title == "" && keyWindow.title != "" {
            if !windowMap.values.contains(pWindow) {
              if let activeBrowser = service.browsers[pWindow.windowNumber], let tabId = activeBrowser.activeTabId {
                windowMap[tabId] = keyWindow
              }
            }
          }
        }
      }
      self.prevWindow = keyWindow
    }
  }

  @MainActor
  let opacityModelContainer: ModelContainer = {
    let schema = Schema([GeneralSetting.self, DomainPermission.self, BookmarkGroup.self,  SearchHistoryGroup.self, VisitHistoryGroup.self, Favorite.self])
//    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
    do {
      let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
      
      let generalSettingDescriptor = FetchDescriptor<GeneralSetting>()
      if try container.mainContext.fetch(generalSettingDescriptor).count == 0 {
        container.mainContext.insert(GeneralSetting())
      }
      
      let baseBookmarkGroupDescriptor = FetchDescriptor<BookmarkGroup>(
        predicate: #Predicate { $0.isBase == true }
      )
      if try container.mainContext.fetch(baseBookmarkGroupDescriptor).count == 0 {
        let baseBookmarkGroup = BookmarkGroup(index: 0, depth: 0, name: "----", isBase: true)
        container.mainContext.insert(baseBookmarkGroup)
        if let baseGroup = try container.mainContext.fetch(baseBookmarkGroupDescriptor).first {
          baseGroup.bookmarkGroups.append(BookmarkGroup(index: 0, depth: 1))
        }
      }
      
      return container
    } catch {
      fatalError("Could not create ModelContainer: \(error)")
    }
  }()
  
  func createWindow(tabId: UUID? = nil, frame: NSRect? = nil) {
    var windowRect = NSRect(x: 0, y: 0, width: 1400, height: 800)
    var isWindowCenter = true
    
    if let frameString = UserDefaults.standard.string(forKey: "lastWindowFrame") {
      isWindowCenter = false
      windowRect = NSRectFromString(frameString)
    }
    
    if let paramFrame = frame {
      isWindowCenter = false
      windowRect = paramFrame
    }
    
    let newWindow = NSWindow(contentRect: windowRect,
                             styleMask: [.titled, .closable, .miniaturizable, .resizable],
                             backing: .buffered, defer: false)
    newWindow.backgroundColor = NSColor(named: "WindowTitleBG")
    let newWindowNo = newWindow.windowNumber
    let newBrowser = Browser(service: service, windowNumber: newWindowNo, tabId: tabId)
    newBrowser.windowNumber = newWindowNo
    self.service.browsers[newWindowNo] = newBrowser
    
    let contentView = ContentView(tabId: tabId, width: windowRect.size.width)
      .environmentObject(self.windowDelegate)
      .environmentObject(self.service)
      .environmentObject(self.service.browsers[newWindowNo]!)
      .background(VisualEffectNSView())
      .frame(minWidth: 500, maxWidth: .infinity, minHeight: 350, maxHeight: .infinity)
      .modelContainer(opacityModelContainer)
    
    newWindow.contentView = NSHostingController(rootView: contentView).view
    
    if isWindowCenter {
      newWindow.center()
    }
    
    newWindow.titlebarAppearsTransparent = true
    newWindow.titleVisibility = .hidden
    newWindow.styleMask.insert(.fullSizeContentView)

    newWindow.makeKeyAndOrderFront(nil)
    newWindow.delegate = windowDelegate
    
    let windowController = NSWindowController(window: newWindow)
    windowController.showWindow(self)
  }

  func applicationDidFinishLaunching(_ notification: Notification) {
    AppDelegate.shared = self
    createWindow()
    setMainMenu()
  }
  
  func createNewWindow(tabId: UUID, frame: NSRect? = nil) {
    createWindow(tabId: tabId, frame: frame)
    setMainMenu()
  }
  
  func setMainMenu() {
    DispatchQueue.main.async {
      let mainMenu = NSMenu()
      
      // Opacity
      let opacityItem = NSMenuItem(title: NSLocalizedString("Opacity", comment: ""), action: nil, keyEquivalent: "")
      let opacityMenu = NSMenu(title: NSLocalizedString("Opacity", comment: ""))
      opacityMenu.addItem(NSMenuItem(title: NSLocalizedString("About Opacity", comment: ""), action: #selector(self.openAboutWindow), keyEquivalent: ""))
      opacityMenu.addItem(NSMenuItem.separator())
      opacityMenu.addItem(NSMenuItem(title: NSLocalizedString("Settings", comment: ""), action: #selector(self.openSettings), keyEquivalent: ","))
      opacityMenu.addItem(NSMenuItem.separator())
      opacityMenu.addItem(withTitle: NSLocalizedString("Quit Opacity", comment: ""), action: #selector(self.exitApplication), keyEquivalent: "q")
      opacityItem.submenu = opacityMenu
      
      mainMenu.addItem(opacityItem)
      
      // File
      let fileItem = NSMenuItem(title: NSLocalizedString("File", comment: ""), action: nil, keyEquivalent: "")
      let fileMenu = NSMenu(title: NSLocalizedString("File", comment: ""))
      fileMenu.addItem(withTitle: NSLocalizedString("New Window", comment: ""), action: #selector(self.newWindow), keyEquivalent: "n")
      fileMenu.addItem(withTitle: NSLocalizedString("New Tab", comment: ""), action: #selector(self.newTab), keyEquivalent: "t")
      fileMenu.addItem(NSMenuItem.separator())
      fileMenu.addItem(withTitle: NSLocalizedString("Close Window", comment: ""), action: #selector(self.closeWindow), keyEquivalent: "W")
      fileMenu.addItem(withTitle: NSLocalizedString("Close Tab", comment: ""), action: #selector(self.closeTab), keyEquivalent: "w")
      fileItem.submenu = fileMenu
      
      mainMenu.addItem(fileItem)
      
      // Edit
      let editItem = NSMenuItem(title: NSLocalizedString("Edit", comment: ""), action: nil, keyEquivalent: "")
      let editMenu = NSMenu(title: NSLocalizedString("Edit", comment: ""))
      editMenu.addItem(withTitle: "Undo", action: Selector(("undo:")), keyEquivalent: "z")
      editMenu.addItem(withTitle: "Redo", action: Selector(("redo:")), keyEquivalent: "Z")
      editMenu.addItem(NSMenuItem.separator())
      editMenu.addItem(withTitle: NSLocalizedString("Cut", comment: ""), action: #selector(NSText.cut(_:)), keyEquivalent: "x")
      editMenu.addItem(withTitle: NSLocalizedString("Copy", comment: ""), action: #selector(NSText.copy(_:)), keyEquivalent: "c")
      editMenu.addItem(withTitle: NSLocalizedString("Paste", comment: ""), action: #selector(NSText.paste(_:)), keyEquivalent: "v")
      editMenu.addItem(withTitle: NSLocalizedString("Select All", comment: ""), action: #selector(NSText.selectAll(_:)), keyEquivalent: "a")
      editMenu.addItem(NSMenuItem.separator())
      
      let findMenu = NSMenuItem(title: NSLocalizedString("Find", comment: ""), action: nil, keyEquivalent: "")
      let findSubMenu = NSMenu(title: NSLocalizedString("Find", comment: ""))
      findMenu.submenu = findSubMenu
      editMenu.addItem(findMenu)
      
      findSubMenu.addItem(withTitle: NSLocalizedString("Find in Page...", comment: ""), action: #selector(self.findKeyword), keyEquivalent: "f")
      findSubMenu.addItem(withTitle: NSLocalizedString("Find Next", comment: ""), action: #selector(self.findKeywordNext), keyEquivalent: "g")
      let findPrevMenu = NSMenuItem(title: NSLocalizedString("Find Previous", comment: ""), action: #selector(self.findKeywordPrev), keyEquivalent: "g")
      findPrevMenu.keyEquivalentModifierMask = [.command, .shift]
      findSubMenu.addItem(findPrevMenu)
      
      editItem.submenu = editMenu
      mainMenu.addItem(editItem)
      
      // View
      let viewItem = NSMenuItem(title: NSLocalizedString("View", comment: ""), action: nil, keyEquivalent: "")
      let viewMenu = NSMenu(title: NSLocalizedString("View", comment: ""))
      viewMenu.addItem(withTitle: NSLocalizedString("Reload Page", comment: ""), action: #selector(self.refreshTab), keyEquivalent: "r")
      
      self.sidebarToggleMenuItem = NSMenuItem(title: NSLocalizedString("Show Sidebar", comment: ""), action: #selector(self.isSidebar), keyEquivalent: "s")
      viewMenu.addItem(self.sidebarToggleMenuItem)

      let fullScreenMenuItem = NSMenuItem(title: "Enter Full Screen", action: #selector(self.toggleFullScreen), keyEquivalent: "f")
      fullScreenMenuItem.keyEquivalentModifierMask = [.command, .control]
      viewMenu.addItem(fullScreenMenuItem)
      
      viewMenu.addItem(NSMenuItem.separator())
      
      viewMenu.addItem(withTitle: NSLocalizedString("Zoom In", comment: ""), action: #selector(self.zoomIn), keyEquivalent: "+")
      viewMenu.addItem(withTitle: NSLocalizedString("Zoom Out", comment: ""), action: #selector(self.zoomOut), keyEquivalent: "-")
      
      viewMenu.addItem(NSMenuItem.separator())
      
      viewItem.submenu = viewMenu
      mainMenu.addItem(viewItem)
      
      // Window Menu
      let windowMenuItem = NSMenuItem(title: NSLocalizedString("Window", comment: ""), action: nil, keyEquivalent: "")
      let windowMenu = NSMenu(title: NSLocalizedString("Window", comment: ""))

      windowMenu.addItem(withTitle: NSLocalizedString("Minimize", comment: ""), action: #selector(NSWindow.performMiniaturize(_:)), keyEquivalent: "m")
      windowMenu.addItem(withTitle: NSLocalizedString("Zoom", comment: ""), action: #selector(NSWindow.performZoom(_:)), keyEquivalent: "")
      
      windowMenuItem.submenu = windowMenu
      mainMenu.addItem(windowMenuItem)
      
//      // 단축키에 파라미터 전송 예시
//      let menuItem3 = NSMenuItem(title: "File2", action: nil, keyEquivalent: "")
//      let myMenu = NSMenu()
//      let menuItem2 = NSMenuItem(title: "Click Me", action: #selector(self.menuItemAction(sender:)), keyEquivalent: "")
//      menuItem2.representedObject = "test"
//      myMenu.addItem(menuItem2)
//      menuItem3.submenu = myMenu
//      mainMenu.addItem(menuItem3)
      
      NSApplication.shared.mainMenu = mainMenu
    }
  }
  
  @objc func zoomIn() {
    if let keyWindow = NSApplication.shared.keyWindow {
      let windowNumber = keyWindow.windowNumber
      if let target = self.service.browsers[windowNumber], let activeId = target.activeTabId {
        if let targetTab = target.tabs.first(where: { $0.id == activeId }) {
          DispatchQueue.main.async {
            targetTab.isZoomDialog = true
            targetTab.zoomLevel = ((targetTab.zoomLevel * 10) + 1) / 10
          }
        }
      }
    }
  }
  
  @objc func zoomOut() {
    if let keyWindow = NSApplication.shared.keyWindow {
      let windowNumber = keyWindow.windowNumber
      if let target = self.service.browsers[windowNumber], let activeId = target.activeTabId {
        if let targetTab = target.tabs.first(where: { $0.id == activeId }) {
          DispatchQueue.main.async {
            targetTab.isZoomDialog = true
            targetTab.zoomLevel = ((targetTab.zoomLevel * 10) - 1) / 10
          }
        }
      }
    }
  }
  
  @objc func findKeywordPrev() {
    if let keyWindow = NSApplication.shared.keyWindow {
      let windowNumber = keyWindow.windowNumber
      if let target = self.service.browsers[windowNumber], let activeId = target.activeTabId {
        if let targetTab = target.tabs.first(where: { $0.id == activeId }), targetTab.isFindDialog {
          DispatchQueue.main.async {
            targetTab.isFindPrev = true
            targetTab.isFindAction = true
          }
        }
      }
    }
  }
  
  @objc func findKeywordNext() {
    if let keyWindow = NSApplication.shared.keyWindow {
      let windowNumber = keyWindow.windowNumber
      if let target = self.service.browsers[windowNumber], let activeId = target.activeTabId {
        if let targetTab = target.tabs.first(where: { $0.id == activeId }), targetTab.isFindDialog {
          DispatchQueue.main.async {
            targetTab.isFindPrev = false
            targetTab.isFindAction = true
          }
        }
      }
    }
  }
  
  @objc func findKeyword() {
    if let keyWindow = NSApplication.shared.keyWindow {
      let windowNumber = keyWindow.windowNumber
      if let target = self.service.browsers[windowNumber], let activeId = target.activeTabId {
        if let targetTab = target.tabs.first(where: { $0.id == activeId }) {
          DispatchQueue.main.async {
            targetTab.isFindDialog.toggle()
          }
        }
      }
    }
  }
  
  @objc func toggleFullScreen(_ sender: AnyObject?) {
    if let keyWindow = NSApplication.shared.keyWindow {
      keyWindow.toggleFullScreen(nil)
    }
  }
  
  @objc func exitApplication() {
    if self.isTerminating {
      NSApplication.shared.terminate(self)
    } else {
      exitWindow()
      self.isTerminating = true
    }
  }
  
  @objc func newWindow() {
    if let keyWindow = NSApplication.shared.keyWindow {
      let windowFrame = keyWindow.frame
      let newWindowFrame = NSRect(x: windowFrame.origin.x + 30, y: windowFrame.origin.y - 20, width: windowFrame.width, height: windowFrame.height)
      createWindow(frame: newWindowFrame)
    }
  }
  
  @objc func newTab() {
    if let keyWindow = NSApplication.shared.keyWindow {
      let windowNumber = keyWindow.windowNumber
      if let target = self.service.browsers[windowNumber] {
        target.initTab()
      }
    }
  }
  
  @objc func closeWindow() {
    if let keyWindow = NSApplication.shared.keyWindow {
      let windowNumber = keyWindow.windowNumber
      if let browser = self.service.browsers[windowNumber] {
        let tabs = browser.tabs
        for tab in tabs {
          self.closeInspector(tab.id)
        }
        browser.closeAllTab {
          browser.tabs = []
          self.service.browsers[windowNumber] = nil
          keyWindow.close()
        }
      }
    }
  }
  
  func closeInspector(_ tabId: UUID) {
    if windowMap.keys.contains(tabId) {
      windowMap[tabId]!.close()
      windowMap.removeValue(forKey: tabId)
    }
  }
  
  @objc func closeTab() {
    if let keyWindow = NSApplication.shared.keyWindow {
      let windowNumber = keyWindow.windowNumber
      if let browser = self.service.browsers[windowNumber], let activeId = browser.activeTabId {
        if let targetRemoveIndex = browser.tabs.firstIndex(where: { $0.id == activeId }) {
          print("close tab clean up webview")
          let targetTab = browser.tabs[targetRemoveIndex]
          targetTab.closeTab {
            browser.tabs.remove(at: targetRemoveIndex)
            if browser.tabs.count == 0 {
              keyWindow.close()
            } else {
              let targetIndex = browser.tabs.count > targetRemoveIndex ? targetRemoveIndex : browser.tabs.count - 1
              browser.activeTabId = browser.tabs[targetIndex].id
            }
          }
        }
        self.closeInspector(activeId)
      } else {
        for (key, value) in windowMap {
          if value == keyWindow {
            windowMap.removeValue(forKey: key)
          }
        }
        keyWindow.close()
      }
    }
  }
  
  @objc func refreshTab() {
    if let keyWindow = NSApplication.shared.keyWindow {
      let windowNumber = keyWindow.windowNumber
      if let target = self.service.browsers[windowNumber], let tab = target.tabs.first(where: { $0.id == target.activeTabId }), let webview = tab.webview {
        webview.reload()
        tab.clearPermission()
      }
    }
  }
  
  @objc func isSidebar() {
    if let keyWindow = NSApplication.shared.keyWindow {
      let windowNumber = keyWindow.windowNumber
      if let target = self.service.browsers[windowNumber] {
        target.isSideBar = !target.isSideBar
        sidebarToggleMenuItem.title = target.isSideBar ? NSLocalizedString("Hide Sidebar", comment: "") : NSLocalizedString("Show Sidebar", comment: "")
      }
    }
  }
  
  @objc func openAboutWindow() {
    aboutWindow()
    setMainMenu()
  }
  
  @objc func openSettings() {
    if let keyWindow = NSApplication.shared.keyWindow {
      let windowNumber = keyWindow.windowNumber
      if let target = self.service.browsers[windowNumber] {
        target.openSettings()
      }
    }
  }
  
  func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
    if !flag {
      createWindow()
    }
    return true
  }
  
  private func exitWindow() {
    let windowRect = NSRect(x: 0, y: 0, width: 380, height: 60)
    let exitWindow = NSWindow(contentRect: windowRect, styleMask: [], backing: .buffered, defer: false)

    let contentView = HStack(spacing: 0) {
      Text(NSLocalizedString("to quit, press ⌘Q agin", comment: ""))
        .font(.system(size: 30))
        .bold()
        .foregroundStyle(.white)
    }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .padding(.vertical, 10)
      .padding(.horizontal, 20)
      .background(.black.opacity(0.4))
      .clipShape(RoundedRectangle(cornerRadius: 10))
    
    let newContentSize = NSHostingController(rootView: contentView).view.fittingSize
    exitWindow.setContentSize(newContentSize)
    
    exitWindow.contentView = NSHostingController(rootView: contentView).view
    exitWindow.center()
    exitWindow.isOpaque = false
    exitWindow.backgroundColor = NSColor.black.withAlphaComponent(0)
    exitWindow.titlebarAppearsTransparent = true
    exitWindow.titleVisibility = .hidden
    exitWindow.styleMask.insert(.fullSizeContentView)

    exitWindow.makeKeyAndOrderFront(nil)
    
    let windowController = NSWindowController(window: exitWindow)
    windowController.showWindow(self)
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
      exitWindow.close()
      self.isTerminating = false
    }
  }
  
  private func aboutWindow() {
    let windowRect = NSRect(x: 0, y: 0, width: 400, height: 200)
    let aboutWindow = NSWindow(contentRect: windowRect,
                             styleMask: [.titled, .closable],
                             backing: .buffered, defer: false)
    
//    aboutWindow.backgroundColor = NSColor(named: "WindowTitleBG")

    let contentView = About()
    let newContentSize = NSHostingController(rootView: contentView).view.fittingSize
    aboutWindow.setContentSize(newContentSize)
    
    aboutWindow.contentView = NSHostingController(rootView: contentView).view
    aboutWindow.center()
    
//    aboutWindow.titlebarAppearsTransparent = true
//    aboutWindow.titleVisibility = .hidden
//    aboutWindow.styleMask.insert(.fullSizeContentView)

    aboutWindow.makeKeyAndOrderFront(nil)
    
    let windowController = NSWindowController(window: aboutWindow)
    windowController.showWindow(self)
  }
  
  @MainActor func deleteExpiredData() {
    do {
      let generalSettingDescriptor = FetchDescriptor<GeneralSetting>()
      if let generalSetting = try AppDelegate.shared.opacityModelContainer.mainContext.fetch(generalSettingDescriptor).first {
        if generalSetting.retentionPeriod != DataRententionPeriodList.indefinite.rawValue {
          let calendar = Calendar.current
          let today = Date()
          let searchHistory = FetchDescriptor<SearchHistory>()
          let visitHistory = FetchDescriptor<VisitHistory>()
          let searchHistories = try AppDelegate.shared.opacityModelContainer.mainContext.fetch(searchHistory)
          let visitHIstories = try AppDelegate.shared.opacityModelContainer.mainContext.fetch(visitHistory)
                    
          for searchData in searchHistories {
            let components = calendar.dateComponents([.day], from: searchData.createDate, to: today)
            if let days = components.day {
              if (generalSetting.retentionPeriod == DataRententionPeriodList.oneDay.rawValue && days >= 1)
                  || (generalSetting.retentionPeriod == DataRententionPeriodList.oneWeek.rawValue && days >= 7)
                  || (generalSetting.retentionPeriod == DataRententionPeriodList.oneMonth.rawValue && days >= 30) {
                AppDelegate.shared.opacityModelContainer.mainContext.delete(searchData)
              }
            }
          }

          for visitData in visitHIstories {
            let components = calendar.dateComponents([.day], from: visitData.createDate, to: today)
            if let days = components.day {
              if (generalSetting.retentionPeriod == DataRententionPeriodList.oneDay.rawValue && days >= 1)
                  || (generalSetting.retentionPeriod == DataRententionPeriodList.oneWeek.rawValue && days >= 7)
                  || (generalSetting.retentionPeriod == DataRententionPeriodList.oneMonth.rawValue && days >= 30) {
                AppDelegate.shared.opacityModelContainer.mainContext.delete(visitData)
              }
            }
          }
        }
      }
    } catch {
      fatalError("Could not deleteExpiredData ModelContainer: \(error)")
    }
  }
}
