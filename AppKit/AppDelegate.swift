//
//  AppDelegate.swift
//  Opacity
//
//  Created by Falsy on 1/16/24.
//

import SwiftUI
import SwiftData

class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate, ObservableObject {
  static var shared: AppDelegate!
  private var isTerminating = false
  
  var prevWindow: NSWindow?
  var windowMap: [UUID:NSWindow] = [:]
  
  var service: Service = Service()
  let windowDelegate = OpacityWindowDelegate()
  
  var sidebarToggleMenuItem: NSMenuItem!
  var reloadMenuItem: NSMenuItem!
  
  @Published var isFullScreenMode: Bool = false
  @Published var isOpenSidebar: Bool = false
  
  
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
     
    newWindow.toolbar = NSToolbar()
    
    let accessoryVC = TitlebarTabViewController(service: self.service, browser: self.service.browsers[newWindowNo]!)
    accessoryVC.layoutAttribute = .top
    newWindow.addTitlebarAccessoryViewController(accessoryVC)
    
    NSApplication.shared.activate(ignoringOtherApps: true)
  }

  func applicationDidFinishLaunching(_ notification: Notification) {
    AppDelegate.shared = self
    createWindow()
  }
  
  func createNewWindow(tabId: UUID, frame: NSRect? = nil) {
    createWindow(tabId: tabId, frame: frame)
  }
  
  func applicationDockMenu(_ sender: NSApplication) -> NSMenu? {
    let dockMenu = NSMenu()
    dockMenu.addItem(NSMenuItem(title: NSLocalizedString("New Window", comment: ""), action: #selector(self.newWindow), keyEquivalent: ""))
    return dockMenu
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
  
  @objc func refreshTabAfterClearingCache() {
    if let keyWindow = NSApplication.shared.keyWindow {
      let windowNumber = keyWindow.windowNumber
      if let target = self.service.browsers[windowNumber], let tab = target.tabs.first(where: { $0.id == target.activeTabId }), let webview = tab.webview {
        clearCache {
          print("clearing cache")
          webview.reload()
          tab.clearPermission()
        }
      }
    }
  }
  
  func clearCache(completion: @escaping () -> Void) {
      URLCache.shared.removeAllCachedResponses()
      completion()
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
  
  @objc func toggleFullScreen() {
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
    } else {
      createWindow()
    }
  }
  
  @objc func newTab() {
    if let keyWindow = NSApplication.shared.keyWindow {
      let windowNumber = keyWindow.windowNumber
      if let target = self.service.browsers[windowNumber] {
        target.initTab()
      }
    } else{
      createWindow()
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
  
  @objc func isSidebar() {
    if let keyWindow = NSApplication.shared.keyWindow {
      let windowNumber = keyWindow.windowNumber
      if let target = self.service.browsers[windowNumber] {
        target.isSideBar = !target.isSideBar
        isOpenSidebar = !isOpenSidebar
      }
    }
  }
  
  @objc func openAboutWindow() {
    aboutWindow()
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
    return false
  }
  
  private func exitWindow() {
    let windowRect = NSRect(x: 0, y: 0, width: 380, height: 60)
    let exitWindow = NSWindow(contentRect: windowRect, styleMask: [], backing: .buffered, defer: false)

    let contentView = HStack(spacing: 0) {
      Text(NSLocalizedString("to quit, press ⌘Q again", comment: ""))
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
    
    let contentView = About()
    let newContentSize = NSHostingController(rootView: contentView).view.fittingSize
    aboutWindow.setContentSize(newContentSize)
    
    aboutWindow.contentView = NSHostingController(rootView: contentView).view
    aboutWindow.center()
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
          let searchHistories = try AppDelegate.shared.opacityModelContainer.mainContext.fetch(searchHistory)
                    
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
          
          let searchHistoryGroupDescriptor = FetchDescriptor<SearchHistoryGroup>()
          let searchHistoryGroups = try AppDelegate.shared.opacityModelContainer.mainContext.fetch(searchHistoryGroupDescriptor)
          
          for group in searchHistoryGroups {
            if group.searchHistories.isEmpty {
              AppDelegate.shared.opacityModelContainer.mainContext.delete(group)
            }
          }

          let visitHistory = FetchDescriptor<VisitHistory>()
          let visitHIstories = try AppDelegate.shared.opacityModelContainer.mainContext.fetch(visitHistory)
          
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
          
          let visitHistoryGroupDescriptor = FetchDescriptor<VisitHistoryGroup>()
          let visitHistoryGroups = try AppDelegate.shared.opacityModelContainer.mainContext.fetch(visitHistoryGroupDescriptor)
          
          for group in visitHistoryGroups {
            if group.visitHistories.isEmpty {
              AppDelegate.shared.opacityModelContainer.mainContext.delete(group)
            }
          }
          
          try AppDelegate.shared.opacityModelContainer.mainContext.save()
        }
      }
    } catch {
      fatalError("Could not deleteExpiredData ModelContainer: \(error)")
    }
  }
}
