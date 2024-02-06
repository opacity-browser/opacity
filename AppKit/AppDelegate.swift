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

class CustomWindow: NSWindow {
  
  override var canBecomeKey: Bool {
    return true
  }
//
//  var initialMouseLocation: NSPoint?
//  var initialWindowLoaction: NSPoint?
//  
//  
//  override func mouseDown(with event: NSEvent) {
//    print("mouseDown")
//    // 드래그 시작 위치를 저장
//    initialMouseLocation = event.locationInWindow
//    initialWindowLoaction = self.frame.origin
//  }
//  
//  override func mouseDragged(with event: NSEvent) {
//    print("mouseDrag")
//    guard let initWindowLocation = initialWindowLoaction else {
//      return
//    }
//    print("bbb")
//    self.setFrameOrigin(initWindowLocation)
    
//    let tabArea = NSRect(x: 100, y: 0, width: 100, height: 50)
//    if tabArea.contains(initialLocation) {
//        // 여기에는 윈도우 이동을 막는 로직을 실행하지 않습니다.
//        // 대신 필요한 다른 작업(예: 드래그 앤 드롭 처리)을 할 수 있습니다.
//      print("aaa")
//      self.setFrameOrigin(initialMouseLocation!)
//    } else {
//      // 타이틀바 영역 외부에서 드래그가 시작된 경우, 기본 윈도우 이동을 허용
//      super.mouseDragged(with: event)
//    }
//  }
}


class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
  private var isTerminating = false
  var browsers: [Int:Browser] = [:]
  
  func someMethodToCall() {
    print("AppDelegate's method has been called!")
  }
  
//  func windowShouldDragOnMouseDown(_ sender: NSWindow, with event: NSEvent) -> Bool {
//    print("drag")
//    if let keyWindow = NSApplication.shared.keyWindow {
//      let windowNumber = keyWindow.windowNumber
//      if let target = self.browsers[windowNumber] {
//        print(String(describing: target.tabSize))
//      }
//    }
//    return true
//  }
  
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
//    newWindow.backgroundColor = NSColor.clear
//    newWindow.isOpaque = false

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
