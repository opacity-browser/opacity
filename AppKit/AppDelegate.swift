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
  var windows: [NSWindow] = []
  var browsers: [Int:Browser] = [:]

  private func createWindow() {
    // 윈도우 사이즈 및 스타일 정의
    let windowRect = NSRect(x: 0, y: 0, width: 1200, height: 800)
    let newWindow = NSWindow(contentRect: windowRect,
                             styleMask: [.titled, .closable, .miniaturizable, .resizable],
                             backing: .buffered, defer: false)
    
    let newWindowNo = newWindow.windowNumber
    self.browsers[newWindowNo] = Browser()

    // 윈도우 컨트롤러 및 뷰 컨트롤러 설정
    let contentView = GeometryReader { geometry in
      ContentView()
        .environmentObject(self.browsers[newWindowNo]!)
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
    let windowNo = createWindow()
    
    DispatchQueue.main.async {
      let mainMenu = NSMenu() // 메인 메뉴 생성
      
      // 파일 메뉴 생성
      let fileMenuItem = NSMenuItem(title: "Opacity", action: nil, keyEquivalent: "")
      mainMenu.addItem(fileMenuItem)
      
      let fileMenu = NSMenu(title: "Opacity")
      
      // 메뉴 아이템 추가
      fileMenu.addItem(NSMenuItem(title: "About Opacity", action: nil, keyEquivalent: ""))
      fileMenuItem.submenu = fileMenu // 파일 메뉴를 파일 메뉴 아이템에 연결
      
      let menuItem = NSMenuItem(title: "File", action: nil, keyEquivalent: "")
      let subMenu = NSMenu(title: "File")
      subMenu.addItem(withTitle: "New Tab", action: #selector(self.newTab), keyEquivalent: "t")
      subMenu.addItem(withTitle: "New Window", action: #selector(self.newWindow), keyEquivalent: "n")
      
      menuItem.submenu = subMenu
      
      mainMenu.addItem(menuItem)
      
      // 메인 메뉴를 애플리케이션에 설정
      NSApplication.shared.mainMenu = mainMenu
    }
  }
  
  @objc func newWindow() {
    createWindow()
  }
  
  @objc func newTab(sender: NSMenuItem) {
    print(sender)
    if let windowNo = sender.representedObject as? Int {
      print(windowNo)
    }
//    let newTab = Tab(webURL: DEFAULT_URL)
//    browsers[sender]
//    browser.tabs.append(newTab)
//    browser.index = browser.tabs.count - 1
  }
  
  func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
    if !flag {
//            window.makeKeyAndOrderFront(self)
//      createWindow()
    }
    return true
  }
//    // NSWindowDelegate 메서드
//    func windowWillClose(_ notification: Notification) {
//        // 윈도우가 닫힐 때 수행할 작업
//        print("윈도우가 닫힘")
//    }
}
