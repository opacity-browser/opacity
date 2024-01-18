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
  
  var windows: [NSWindow] = []
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
    
    let windowController = NSWindowController(window: exitWindow)
    exitWindow.contentView = NSHostingController(rootView: contentView).view
    exitWindow.center()
    exitWindow.isOpaque = false
    exitWindow.backgroundColor = NSColor.black.withAlphaComponent(0)
    exitWindow.titlebarAppearsTransparent = true // 타이틀 바를 투명하게
    exitWindow.titleVisibility = .hidden // 타이틀을 숨깁니다
    exitWindow.styleMask.insert(.fullSizeContentView)

    exitWindow.makeKeyAndOrderFront(nil)
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
    
    let windowController = NSWindowController(window: newWindow)

    newWindow.contentView = NSHostingController(rootView: contentView).view
    newWindow.center()
    newWindow.titlebarAppearsTransparent = true // 타이틀 바를 투명하게
    newWindow.titleVisibility = .hidden // 타이틀을 숨깁니다
    newWindow.styleMask.insert(.fullSizeContentView)

    newWindow.makeKeyAndOrderFront(nil)
    newWindow.delegate = self
    windowController.showWindow(self)
  }

  func applicationDidFinishLaunching(_ notification: Notification) {
    createWindow()
    
    DispatchQueue.main.async {
      let mainMenu = NSMenu()
      
      // Opacity 메뉴
      let fileMenuItem = NSMenuItem(title: "Opacity", action: nil, keyEquivalent: "")
      let fileMenu = NSMenu(title: "Opacity")
      fileMenu.addItem(NSMenuItem(title: "About Opacity", action: nil, keyEquivalent: ""))
      fileMenu.addItem(NSMenuItem.separator())
      fileMenu.addItem(withTitle: "Exit Opacity", action: #selector(self.exitApplication), keyEquivalent: "q")
      fileMenuItem.submenu = fileMenu // 파일 메뉴를 파일 메뉴 아이템에 연결
      
      mainMenu.addItem(fileMenuItem)
      
      // File 메뉴
      let menuItem = NSMenuItem(title: "File", action: nil, keyEquivalent: "")
      let subMenu = NSMenu(title: "File")
      subMenu.addItem(withTitle: "New Tab", action: #selector(self.newTab), keyEquivalent: "t")
      subMenu.addItem(withTitle: "New Window", action: #selector(self.newWindow), keyEquivalent: "n")
      subMenu.addItem(NSMenuItem.separator())
      subMenu.addItem(withTitle: "Close Tab", action: #selector(self.closeTab), keyEquivalent: "w")
      menuItem.submenu = subMenu
      
      mainMenu.addItem(menuItem)
      
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
        let newTab = Tab(webURL: DEFAULT_URL)
        target.tabs.append(newTab)
        target.index = target.tabs.count - 1
      }
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
