//
//  AppDelegate.swift
//  Opacity
//
//  Created by Falsy on 1/16/24.
//

import Cocoa
import SwiftUI

//class WindowController: NSWindowController {
//  var browser: Browser = Browser()
//  
//  override init(window: NSWindow?) {
//      super.init(window: window)
//  }
//  
//  required init?(coder: NSCoder) {
//      fatalError("init(coder:) has not been implemented")
//  }
//}

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
  private var isTerminating = false
  var browsers: [Int:Browser] = [:]
  
  private func exitWindow() {
    let windowRect = NSRect(x: 0, y: 0, width: 380, height: 60)
    let exitWindow = NSWindow(contentRect: windowRect, styleMask: [], backing: .buffered, defer: false)

    let contentView = HStack(spacing: 0) {
      Text("to quit, press ")
        .font(.system(size: 30))
        .bold()
        .foregroundStyle(.white)
      Image(systemName: "command")
        .font(.system(size: 30))
        .bold()
        .foregroundStyle(.white)
      Text("Q again")
        .font(.system(size: 30))
        .bold()
        .foregroundStyle(.white)
    }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(.black.opacity(0.4))
      .clipShape(RoundedRectangle(cornerRadius: 10))
    
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
  

  private func createWindow() {
    // 윈도우 사이즈 및 스타일 정의
    let windowRect = NSRect(x: 0, y: 0, width: 1400, height: 800)
    let newWindow = NSWindow(contentRect: windowRect,
                             styleMask: [.titled, .closable, .miniaturizable, .resizable],
                             backing: .buffered, defer: false)
    
    let newWindowNo = newWindow.windowNumber
    self.browsers[newWindowNo] = Browser()

    // 윈도우 컨트롤러 및 뷰 컨트롤러 설정
    let contentView = GeometryReader { geometry in
      ContentView()
        .environmentObject(self.browsers[newWindowNo]!)
        .background(VisualEffect())
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
    createWindow()
    
    DispatchQueue.main.async {
      let mainMenu = NSMenu()
      
      // Opacity 메뉴
      let opacityItem = NSMenuItem(title: "Opacity", action: nil, keyEquivalent: "")
      let opacityMenu = NSMenu(title: "Opacity")
      opacityMenu.addItem(NSMenuItem(title: "About Opacity", action: nil, keyEquivalent: ""))
      opacityMenu.addItem(NSMenuItem.separator())
      opacityMenu.addItem(withTitle: "Exit Opacity", action: #selector(self.exitApplication), keyEquivalent: "q")
      opacityItem.submenu = opacityMenu // 파일 메뉴를 파일 메뉴 아이템에 연결
      
      mainMenu.addItem(opacityItem)
      
      // File 메뉴
      let fileItem = NSMenuItem(title: "File", action: nil, keyEquivalent: "")
      let fileMenu = NSMenu(title: "File")
      fileMenu.addItem(withTitle: "New Window", action: #selector(self.newWindow), keyEquivalent: "n")
      fileMenu.addItem(withTitle: "New Tab", action: #selector(self.newTab), keyEquivalent: "t")
      fileMenu.addItem(NSMenuItem.separator())
      fileMenu.addItem(withTitle: "Close Window", action: #selector(self.closeWindow), keyEquivalent: "W")
      fileMenu.addItem(withTitle: "Close Tab", action: #selector(self.closeTab), keyEquivalent: "w")
      fileItem.submenu = fileMenu
      
      mainMenu.addItem(fileItem)
      
      // Edit 메뉴
      let editItem = NSMenuItem(title: "Edit", action: nil, keyEquivalent: "")
      let editMenu = NSMenu(title: "Edit")
      editMenu.addItem(withTitle: "Undo", action: Selector(("undo:")), keyEquivalent: "z")
      editMenu.addItem(withTitle: "Redo", action: Selector(("redo:")), keyEquivalent: "Z")
      editMenu.addItem(NSMenuItem.separator())
      editMenu.addItem(withTitle: "Cut", action: #selector(NSText.cut(_:)), keyEquivalent: "x")
      editMenu.addItem(withTitle: "Copy", action: #selector(NSText.copy(_:)), keyEquivalent: "c")
      editMenu.addItem(withTitle: "Paste", action: #selector(NSText.paste(_:)), keyEquivalent: "v")
      editMenu.addItem(withTitle: "Select All", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a")
      editMenu.addItem(NSMenuItem.separator())
      editItem.submenu = editMenu
      
      mainMenu.addItem(editItem)
      
      // View 메뉴
      let viewItem = NSMenuItem(title: "View", action: nil, keyEquivalent: "")
      let viewMenu = NSMenu(title: "View")
      viewMenu.addItem(withTitle: "Reload Page", action: #selector(self.refreshTab), keyEquivalent: "r")
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
  
  func menuWillOpen(_ menu: NSMenu) {
    // 메뉴 아이템의 상태 업데이트
    print("a")
    menu.items.forEach { item in
      item.isEnabled = true // 또는 특정 조건에 따라 설정
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
    createWindow()
  }
  
  @objc func newTab() {
    if let keyWindow = NSApplication.shared.keyWindow {
      let windowNumber = keyWindow.windowNumber
      if let target = self.browsers[windowNumber] {
        let newTab = Tab(url: DEFAULT_URL)
        target.tabs.append(newTab)
        target.index = target.tabs.count - 1
      }
    }
  }
  
  @objc func closeWindow() {
    if let keyWindow = NSApplication.shared.keyWindow {
      keyWindow.close()
    }
  }
  
  @objc func closeTab() {
    if let keyWindow = NSApplication.shared.keyWindow {
      let windowNumber = keyWindow.windowNumber
      if let target = self.browsers[windowNumber] {
        target.tabs.remove(at: target.index)
        target.index = target.tabs.count > target.index ? target.index : target.tabs.count - 1
        if target.tabs.count == 0 {
          keyWindow.close()
        }
      }
    }
  }
  
  @objc func refreshTab() {
    if let keyWindow = NSApplication.shared.keyWindow {
      let windowNumber = keyWindow.windowNumber
      if let target = self.browsers[windowNumber] {
        target.tabs[target.index].webview?.reload()
      }
    }
  }
  
  func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
    if !flag {
      createWindow()
    }
    return true
  }
  
//  // 단축키에 파라미터 전송 예시
//  @objc func menuItemAction(sender: NSMenuItem) {
//    if let data = sender.representedObject as? String {
//     print("Menu item selected with data: \(data)")
//    }
//  }
}
