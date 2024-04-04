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
  
  func windowWillClose(_ notification: Notification) {
    guard let window = notification.object as? NSWindow else { return }
    let frameString = NSStringFromRect(window.frame)
    UserDefaults.standard.set(frameString, forKey: "lastWindowFrame")
  }
  
  func windowShouldClose(_ sender: NSWindow) -> Bool {
    let windowNo = sender.windowNumber
    if let childTabs = AppDelegate.shared.service.browsers[windowNo]?.tabs {
      for childTab in childTabs {
        AppDelegate.shared.closeInspector(childTab.id)
      }
    }
    return true
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

  var opacityModelContainer: ModelContainer = {
    let schema = Schema([OpacityBrowserSettings.self, DomainPermission.self, Bookmark.self,  SearchHistoryGroup.self, VisitHistoryGroup.self, Favorite.self])
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    do {
      let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
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
    
    let newWindowNo = newWindow.windowNumber
    let newBrowser = Browser()
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
      let opacityItem = NSMenuItem(title: NSLocalizedString("Fried Egg", comment: ""), action: nil, keyEquivalent: "")
      let opacityMenu = NSMenu(title: NSLocalizedString("Fried Egg", comment: ""))
      opacityMenu.addItem(NSMenuItem(title: NSLocalizedString("About Fried Egg", comment: ""), action: nil, keyEquivalent: ""))
      opacityMenu.addItem(NSMenuItem.separator())
      opacityMenu.addItem(withTitle: NSLocalizedString("Quit Fried Egg", comment: ""), action: #selector(self.exitApplication), keyEquivalent: "q")
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
      editItem.submenu = editMenu
      
      mainMenu.addItem(editItem)
      
      // View
      let viewItem = NSMenuItem(title: NSLocalizedString("View", comment: ""), action: nil, keyEquivalent: "")
      let viewMenu = NSMenu(title: NSLocalizedString("View", comment: ""))
      viewMenu.addItem(withTitle: NSLocalizedString("Reload Page", comment: ""), action: #selector(self.refreshTab), keyEquivalent: "r")
      
      viewMenu.addItem(withTitle: NSLocalizedString("Show/Hide Sidebar", comment: ""), action: #selector(self.isSidebar), keyEquivalent: "s")
      viewMenu.addItem(NSMenuItem.separator())
      viewItem.submenu = viewMenu
      
      mainMenu.addItem(viewItem)
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
      if let childTabs = self.service.browsers[windowNumber]?.tabs {
        for childTab in childTabs {
          self.closeInspector(childTab.id)
        }
      }
      self.service.browsers[windowNumber] = nil
      keyWindow.close()
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
      print(keyWindow)
      let windowNumber = keyWindow.windowNumber
      if let target = self.service.browsers[windowNumber], let activeId = target.activeTabId {
        if let targetRemoveIndex = target.tabs.firstIndex(where: { $0.id == activeId }) {
          target.tabs.remove(at: targetRemoveIndex)
          if target.tabs.count == 0 {
            self.closeWindow()
          } else {
            let targetIndex = target.tabs.count > targetRemoveIndex ? targetRemoveIndex : target.tabs.count - 1
            target.activeTabId = target.tabs[targetIndex].id
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
      if let target = self.service.browsers[windowNumber], let tab = target.tabs.first(where: { $0.id == target.activeTabId }) {
        tab.webview.reload()
        tab.clearPermission()
      }
    }
  }
  
  @objc func isSidebar() {
    if let keyWindow = NSApplication.shared.keyWindow {
      let windowNumber = keyWindow.windowNumber
      if let target = self.service.browsers[windowNumber] {
        target.isSideBar = !target.isSideBar
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
}
