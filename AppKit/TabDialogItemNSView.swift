//
//  TabDialogItemView.swift
//  Opacity
//
//  Created by Falsy on 2/16/24.
//

import SwiftUI

struct TabDialogItemNSView: NSViewRepresentable {
  @ObservedObject var service: Service
  @ObservedObject var browser: Browser
  @Binding var tabs: [Tab]
  @ObservedObject var tab: Tab
  @Binding var activeTabId: UUID?
  var index: Int
  
  func moveTab(_ idx: Int) {
    if let targetIndex = tabs.firstIndex(where: { $0.id == service.dragTabId }) {
      if targetIndex == idx {
        return
      }
      let removedItem = tabs.remove(at: targetIndex)
      tabs.insert(removedItem, at: idx)
      activeTabId = removedItem.id
    } else {
      service.isMoveTab = true
      for (_, browser) in service.browsers {
        if let targetTab = browser.tabs.first(where: { $0.id == service.dragTabId }) {
          tabs.insert(targetTab, at: idx + 1)
          activeTabId = targetTab.id
          break
        }
      }
    }
  }
  
  func makeNSView(context: Context) -> NSView {
    let containerView = TabDialogDragSource()
    containerView.dragDelegate = context.coordinator
    containerView.moveTab = moveTab
    containerView.index = index
    
    let hostingView = NSHostingView(rootView: TabDialogItem(browser: browser, tab: tab, activeTabId: $activeTabId))
    hostingView.translatesAutoresizingMaskIntoConstraints = false
    
    containerView.addSubview(hostingView)
    
    NSLayoutConstraint.activate([
      hostingView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
      hostingView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
      hostingView.topAnchor.constraint(equalTo: containerView.topAnchor),
      hostingView.heightAnchor.constraint(equalTo: containerView.heightAnchor)
    ])
    
    context.coordinator.tabDialogItemNSView = containerView
    return containerView
  }
  
  func updateNSView(_ nsView: NSView, context: Context) {
    context.coordinator.thisIndex = index
    context.coordinator.tabId = tab.id
    
    for subview in nsView.subviews {
      if let hostingView = subview as? NSHostingView<TabDialogItem> {
        hostingView.rootView = TabDialogItem(browser: browser, tab: tab, activeTabId: $activeTabId)
        hostingView.layout()
      }
    }
    
    if let customView = nsView as? TabDialogDragSource {
      if customView.index != index {
        customView.index = index
      }
    }
  }
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  class Coordinator: NSObject, NSDraggingSource {
    var parent: TabDialogItemNSView
    var thisIndex: Int?
    var tabId: UUID?
    weak var tabDialogItemNSView: TabDialogDragSource?
    
    init(_ parent: TabDialogItemNSView) {
      self.parent = parent
    }
    
    func draggingSession(_ session: NSDraggingSession, sourceOperationMaskFor context: NSDraggingContext) -> NSDragOperation {
      return .move
    }

    func draggingSession(_ session: NSDraggingSession, willBeginAt screenPoint: NSPoint) {
      if let nowTabId = tabId {
        parent.service.dragTabId = nowTabId
        parent.service.dragBrowserNumber = parent.browser.windowNumber
        let beforeTab = parent.browser.tabs.first(where: { $0.id == parent.activeTabId })
        if let beforeWebview = beforeTab?.webview  {
          parent.browser.updateActiveTab(tabId: nowTabId, webView: beforeWebview)
        }
      }
    }
    
    func draggingSession(_ session: NSDraggingSession, endedAt screenPoint: NSPoint, operation: NSDragOperation) {
      
      guard let dragBrowserNo = parent.service.dragBrowserNumber, 
              let window = NSApp.windows.first(where: { $0.windowNumber == dragBrowserNo }),
              let dialog = tabDialogItemNSView?.window else { return }
      
      let windowFrame = window.frame
      let windowPoint = window.convertPoint(fromScreen: screenPoint)
      let titleBarHeight: CGFloat = 80
      let titleBarRect = NSRect(x: 0, y: windowFrame.height - titleBarHeight, width: windowFrame.width, height: titleBarHeight)
      
      if !dialog.frame.contains(screenPoint) && !titleBarRect.contains(windowPoint) {
        if let dragId = parent.service.dragTabId {
          if let targetIndex = parent.tabs.firstIndex(where: { $0.id == dragId }) {
            if(parent.tabs.count == 1) {
              if parent.service.isMoveTab {
                parent.service.browsers[dragBrowserNo] = nil
                window.close()
              }
            } else {
              if parent.service.isMoveTab {
                parent.tabs.remove(at: targetIndex)
                let newActiveTabIndex = targetIndex == 0 ? 0 : targetIndex - 1
                parent.activeTabId = parent.tabs[newActiveTabIndex].id
              } else {
                let newWindowframe = NSRect(x: screenPoint.x - (windowFrame.width / 2), y: screenPoint.y - windowFrame.height, width: windowFrame.width, height: windowFrame.height)
                AppDelegate.shared.createNewWindow(tabId: dragId, frame: newWindowframe)
              }
            }
          }
        }
      }
      
      parent.service.dragTabId = nil
      parent.service.isMoveTab = false
    }
  }
}


class TabDialogDragSource: NSView {
  var appDelegate: AppDelegate?
  var dragDelegate: NSDraggingSource?
  var index: Int?
  var moveTab: ((Int) -> Void)?
  
  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    self.registerForDraggedTypes([.string])
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func mouseDown(with event: NSEvent) {
    guard let dragDelegate = dragDelegate else { return }
    
    let draggedImage = self.snapshot()
    
    let draggingItem = NSDraggingItem(pasteboardWriter: NSString(string: "Drag Content"))
    draggingItem.setDraggingFrame(self.bounds, contents: draggedImage) // Content
    
    let session = self.beginDraggingSession(with: [draggingItem], event: event, source: dragDelegate)
    session.animatesToStartingPositionsOnCancelOrFail = true
  }
  
  override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
    if let window = self.window {
      window.makeKeyAndOrderFront(nil)
    }
    return .move
  }
  
  override func draggingExited(_ sender: NSDraggingInfo?) {
  }
  
  override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
    if let thisIndex = self.index, let moveFunc = self.moveTab {
      moveFunc(thisIndex)
    }
    return true
  }
  
  override func concludeDragOperation(_ sender: NSDraggingInfo?) {
  }
  
  func snapshot() -> NSImage {
      let image = NSImage(size: self.bounds.size)
      image.lockFocus()
      defer { image.unlockFocus() }
      if let context = NSGraphicsContext.current?.cgContext {
          self.layer?.render(in: context)
      }
      return image
  }
}

