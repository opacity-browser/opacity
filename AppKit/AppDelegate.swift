//
//  AppDelegate.swift
//  Opacity
//
//  Created by Falsy on 1/16/24.
//

import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
  static var shared: AppDelegate!
  
  private var isTerminating = false
  var service: Service = Service()
  
  func createWindow(_ tabId: UUID? = nil) {
    // 윈도우 사이즈 및 스타일 정의
    let windowRect = NSRect(x: 0, y: 0, width: 1400, height: 800)
    let newWindow = NSWindow(contentRect: windowRect,
                             styleMask: [.titled, .closable, .miniaturizable, .resizable],
                             backing: .buffered, defer: false)
    
    let newWindowNo = newWindow.windowNumber
    self.service.browsers[newWindowNo] = Browser()
    
    if let testTabId = tabId {
      print("tabId: \(testTabId)")
    }
    
    // 윈도우 컨트롤러 및 뷰 컨트롤러 설정
    let contentView = GeometryReader { geometry in
      ContentView(tabId: tabId)
        .environmentObject(self.service)
        .environmentObject(self.service.browsers[newWindowNo]!)
        .background(VisualEffect())
//        .clipShape(RoundedRectangle(cornerRadius: 10))
      
//        .onAppear {
//          if let windowSize = WindowSizeManager.load() {
//            NSApplication.shared.windows.forEach({ NSWindow in
//              NSWindow.setContentSize(windowSize)
//            })
//          }
//        }
//        .onDisappear {
//          WindowSizeManager.save(windowSize: geometry.size)
//        }
    }
    
    newWindow.contentView = NSHostingController(rootView: contentView).view
    newWindow.center()
    newWindow.titlebarAppearsTransparent = true // 타이틀 바를 투명하게
    newWindow.titleVisibility = .hidden // 타이틀을 숨깁니다
    newWindow.styleMask.insert(.fullSizeContentView)

    newWindow.makeKeyAndOrderFront(nil)
    newWindow.delegate = self
    
    let windowController = NSWindowController(window: newWindow)
    windowController.showWindow(self)
  }

  func applicationDidFinishLaunching(_ notification: Notification) {
    AppDelegate.shared = self
    createWindow()
    setMainMenu()
  }
  
  func createNewWindow(_ tabId: UUID) {
    createWindow(tabId)
    setMainMenu()
  }
  
  func setMainMenu() {
    DispatchQueue.main.async {
      let mainMenu = NSMenu()
      
      // Opacity 메뉴
      let opacityItem = NSMenuItem(title: NSLocalizedString("Fried Egg", comment: ""), action: nil, keyEquivalent: "")
      let opacityMenu = NSMenu(title: NSLocalizedString("Fried Egg", comment: ""))
      opacityMenu.addItem(NSMenuItem(title: NSLocalizedString("About Fried Egg", comment: ""), action: nil, keyEquivalent: ""))
      opacityMenu.addItem(NSMenuItem.separator())
      opacityMenu.addItem(withTitle: NSLocalizedString("Quit Fried Egg", comment: ""), action: #selector(self.exitApplication), keyEquivalent: "q")
      opacityItem.submenu = opacityMenu // 파일 메뉴를 파일 메뉴 아이템에 연결
      
      mainMenu.addItem(opacityItem)
      
      // File 메뉴
      let fileItem = NSMenuItem(title: NSLocalizedString("File", comment: ""), action: nil, keyEquivalent: "")
      let fileMenu = NSMenu(title: NSLocalizedString("File", comment: ""))
      fileMenu.addItem(withTitle: NSLocalizedString("New Window", comment: ""), action: #selector(self.newWindow), keyEquivalent: "n")
      fileMenu.addItem(withTitle: NSLocalizedString("New Tab", comment: ""), action: #selector(self.newTab), keyEquivalent: "t")
      fileMenu.addItem(NSMenuItem.separator())
      fileMenu.addItem(withTitle: NSLocalizedString("Close Window", comment: ""), action: #selector(self.closeWindow), keyEquivalent: "W")
      fileMenu.addItem(withTitle: NSLocalizedString("Close Tab", comment: ""), action: #selector(self.closeTab), keyEquivalent: "w")
      fileItem.submenu = fileMenu
      
      mainMenu.addItem(fileItem)
      
      // Edit 메뉴
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
      
      // View 메뉴
      let viewItem = NSMenuItem(title: NSLocalizedString("View", comment: ""), action: nil, keyEquivalent: "")
      let viewMenu = NSMenu(title: NSLocalizedString("View", comment: ""))
      viewMenu.addItem(withTitle: NSLocalizedString("Reload Page", comment: ""), action: #selector(self.refreshTab), keyEquivalent: "r")
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
      
      // 메인 메뉴를 애플리케이션에 설정
      NSApplication.shared.mainMenu = mainMenu
    }
  }
  
//  func menuWillOpen(_ menu: NSMenu) {
//    // 메뉴 아이템의 상태 업데이트
//    print("a")
//    menu.items.forEach { item in
//      item.isEnabled = true // 또는 특정 조건에 따라 설정
//    }
//  }
  
  @objc func exitApplication() {
    if self.isTerminating {
      NSApplication.shared.terminate(self)
    } else {
      exitWindow()
      self.isTerminating = true
    }
  }
  
  @objc func newWindow() {
    createWindow()
  }
  
  @objc func newTab() {
    if let keyWindow = NSApplication.shared.keyWindow {
      let windowNumber = keyWindow.windowNumber
      if let target = self.service.browsers[windowNumber] {
        let newTab = Tab(url: DEFAULT_URL)
        target.tabs.append(newTab)
        target.activeTabId = newTab.id
      }
    }
  }
  
  @objc func closeWindow() {
    if let keyWindow = NSApplication.shared.keyWindow {
      let windowNumber = keyWindow.windowNumber
      if self.service.browsers[windowNumber] != nil {
        self.service.browsers[windowNumber] = nil
      }
      keyWindow.close()
    }
  }
  
  @objc func closeTab() {
    if let keyWindow = NSApplication.shared.keyWindow {
      let windowNumber = keyWindow.windowNumber
      if let target = self.service.browsers[windowNumber] {
        if let targetRemoveIndex = target.tabs.firstIndex(where: { $0.id == target.activeTabId }) {
          target.tabs.remove(at: targetRemoveIndex)
          if target.tabs.count == 0 {
            keyWindow.close()
          } else {
            let targetIndex = target.tabs.count > targetRemoveIndex ? targetRemoveIndex : target.tabs.count - 1
            target.activeTabId = target.tabs[targetIndex].id
          }
        }
      }
    }
  }
  
  @objc func refreshTab() {
    if let keyWindow = NSApplication.shared.keyWindow {
      let windowNumber = keyWindow.windowNumber
      if let target = self.service.browsers[windowNumber] {
        target.tabs.first(where: { $0.id == target.activeTabId })?.webview?.reload()
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
    exitWindow.titlebarAppearsTransparent = true // 타이틀 바를 투명하게
    exitWindow.titleVisibility = .hidden // 타이틀을 숨깁니다
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
