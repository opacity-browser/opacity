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

class AppDelegate: NSObject, NSApplicationDelegate {
  var window: NSWindow!
  var browser: Browser = Browser()

  private func createWindow() {
    // 윈도우 사이즈 및 스타일 정의
    let windowRect = NSRect(x: 0, y: 0, width: 1024, height: 800)
    window = NSWindow(contentRect: windowRect,
                      styleMask: [.titled, .closable, .miniaturizable, .resizable],
                      backing: .buffered, defer: false)

    // 윈도우 컨트롤러 및 뷰 컨트롤러 설정
    let contentView = GeometryReader { geometry in
      ContentView()
        .environmentObject(self.browser)
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
    
    let windowController = NSWindowController(window: window)

    window.contentView = NSHostingController(rootView: contentView).view
    window.titlebarAppearsTransparent = true // 타이틀 바를 투명하게
    window.titleVisibility = .hidden // 타이틀을 숨깁니다
    window.styleMask.insert(.fullSizeContentView)

    // 윈도우 타이틀 및 표시
//        window.title = "Opacity"
    window.makeKeyAndOrderFront(nil)
//    window.delegate = self
    windowController.showWindow(self)
  }

  func applicationDidFinishLaunching(_ notification: Notification) {
    let mainMenu = NSMenu() // 메인 메뉴 생성

    // 파일 메뉴 생성
    let fileMenuItem = NSMenuItem(title: "File", action: nil, keyEquivalent: "")
    mainMenu.addItem(fileMenuItem)

    let fileMenu = NSMenu(title: "File")
    fileMenuItem.submenu = fileMenu // 파일 메뉴를 파일 메뉴 아이템에 연결

    // 메뉴 아이템 추가
    fileMenu.addItem(NSMenuItem(title: "New", action: #selector(newDocument), keyEquivalent: "n"))

    // 메인 메뉴를 애플리케이션에 설정
    NSApplication.shared.mainMenu = mainMenu
    
//    createWindow()
  }
  
  @objc func newDocument() {
      // "New" 메뉴 아이템이 선택될 때 실행될 동작을 여기에 작성합니다.
    print("KeyDown Action")
    createWindow()
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
