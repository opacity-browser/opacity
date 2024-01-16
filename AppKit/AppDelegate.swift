//
//  AppDelegate.swift
//  Opacity
//
//  Created by Falsy on 1/16/24.
//

import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!

    private func createWindow() {
        // 윈도우 사이즈 및 스타일 정의
        let windowRect = NSRect(x: 0, y: 0, width: 1024, height: 800)
        window = NSWindow(contentRect: windowRect,
                          styleMask: [.titled, .closable, .miniaturizable, .resizable],
                          backing: .buffered, defer: false)

        // 윈도우 컨트롤러 및 뷰 컨트롤러 설정
        let contentView = GeometryReader { geometry in
          ContentView()
            .frame(minWidth: 1024, minHeight: 800, alignment: .center)
            .onAppear {
                if let windowSize = WindowSizeManager.load() {
                    NSApplication.shared.windows.forEach({ NSWindow in
                        NSWindow.setContentSize(windowSize)
                    })
                }
            }
            .onDisappear {
                WindowSizeManager.save(windowSize: geometry.size)
            }
        }
        let windowController = NSWindowController(window: window)

        window.contentView = NSHostingController(rootView: contentView).view
        window.titlebarAppearsTransparent = true // 타이틀 바를 투명하게
        window.titleVisibility = .hidden // 타이틀을 숨깁니다
        window.styleMask.insert(.fullSizeContentView)

        // 윈도우 타이틀 및 표시
//        window.title = "Opacity"
        window.makeKeyAndOrderFront(nil)
//        window.delegate = self
        windowController.showWindow(self)
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        createWindow()
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
//            window.makeKeyAndOrderFront(self)
            createWindow()
        }
        return true
    }
//    // NSWindowDelegate 메서드
//    func windowWillClose(_ notification: Notification) {
//        // 윈도우가 닫힐 때 수행할 작업
//        print("윈도우가 닫힘")
//    }
}
