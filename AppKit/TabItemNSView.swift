//
//  TabItemView.swift
//  Opacity
//
//  Created by Falsy on 2/6/24.
//

import SwiftUI

struct TabItemNSView: NSViewRepresentable {
  @ObservedObject var service: Service
  @ObservedObject var browser: Browser
  @Binding var tabs: [Tab]
  @ObservedObject var tab: Tab
  @Binding var activeTabId: UUID?
  var index: Int
  @Binding var tabWidth: CGFloat
  
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
    let containerView = TabDragSource()
    containerView.dragDelegate = context.coordinator
    containerView.moveTab = moveTab
    containerView.index = index
    
    // 탭 클릭 핸들러 추가 (값 직접 캡처)
    let tabId = tab.id
    containerView.tabClickHandler = {
      DispatchQueue.main.async {
        self.activeTabId = tabId
      }
    }
    
    let hostingView = NSHostingView(rootView: TabItem(browser: browser, tab: tab, activeTabId: $activeTabId, tabWidth: $tabWidth))
    hostingView.translatesAutoresizingMaskIntoConstraints = false
    
    containerView.addSubview(hostingView)
    
    NSLayoutConstraint.activate([
      hostingView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
      hostingView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
      hostingView.topAnchor.constraint(equalTo: containerView.topAnchor),
      hostingView.heightAnchor.constraint(equalTo: containerView.heightAnchor)
    ])
    
    context.coordinator.tabItemNSView = containerView
    return containerView
  }
  
  func updateNSView(_ nsView: NSView, context: Context) {
    context.coordinator.thisIndex = index
    context.coordinator.tabId = tab.id
    
    for subview in nsView.subviews {
      if let hostingView = subview as? NSHostingView<TabItem> {
        hostingView.rootView = TabItem(browser: browser, tab: tab, activeTabId: $activeTabId, tabWidth: $tabWidth)
        hostingView.layout()
      }
    }
    
    if let customView = nsView as? TabDragSource {
      if customView.index != index {
        customView.index = index
      }
    }
  }
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  class Coordinator: NSObject, NSDraggingSource {
    var parent: TabItemNSView
    var thisIndex: Int?
    var tabId: UUID?
    weak var tabItemNSView: TabDragSource?
    
    init(_ parent: TabItemNSView) {
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
      guard let window = tabItemNSView?.window, let dragBrowserNo = parent.service.dragBrowserNumber else { return }
      
      let windowFrame = window.frame
      let windowPoint = window.convertPoint(fromScreen: screenPoint)
      let titleBarHeight: CGFloat = 80
      let titleBarRect = NSRect(x: 0, y: windowFrame.height - titleBarHeight, width: windowFrame.width, height: titleBarHeight)
      
      if !titleBarRect.contains(windowPoint) {
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


class TabDragSource: NSView {
  var appDelegate: AppDelegate?
  var dragDelegate: NSDraggingSource?
  var index: Int?
  var moveTab: ((Int) -> Void)?
  var tabClickHandler: (() -> Void)?  // 탭 클릭 핸들러 추가
  
  // 드래그 감지를 위한 프로퍼티들
  private var mouseDownTime: TimeInterval = 0
  private var mouseDownLocation: NSPoint = .zero
  private var dragMinimumTime: TimeInterval = 0.1 // 최소 드래그 시간 (100ms)
  private var dragMinimumDistance: CGFloat = 3.0  // 최소 드래그 거리 (3pt)
  
  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    self.registerForDraggedTypes([.string])
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func mouseDown(with event: NSEvent) {
    // 마우스 다운 시점과 위치 기록
    mouseDownTime = event.timestamp
    mouseDownLocation = event.locationInWindow
    
    // 기본 mouseDown 처리는 하지 않음 (드래그 판단 후 처리)
  }
  
  override func mouseDragged(with event: NSEvent) {
    guard let _ = dragDelegate else { return }
    
    let currentTime = event.timestamp
    let currentLocation = event.locationInWindow
    let timeDiff = currentTime - mouseDownTime
    let distance = sqrt(pow(currentLocation.x - mouseDownLocation.x, 2) +
                       pow(currentLocation.y - mouseDownLocation.y, 2))
    
    // 시간과 거리 조건을 모두 만족할 때만 드래그 시작
    if timeDiff >= dragMinimumTime && distance >= dragMinimumDistance {
      startDragSession(with: event)
    }
  }
  
  override func mouseUp(with event: NSEvent) {
    let currentTime = event.timestamp
    let currentLocation = event.locationInWindow
    let timeDiff = currentTime - mouseDownTime
    let distance = sqrt(pow(currentLocation.x - mouseDownLocation.x, 2) +
                       pow(currentLocation.y - mouseDownLocation.y, 2))
    
    // 짧은 클릭이고 움직임이 적으면 일반 클릭으로 처리
    if !(timeDiff >= dragMinimumTime && distance >= dragMinimumDistance) {
      // 일반 클릭 이벤트 처리 (탭 활성화 등)
      handleTabClick()
    }
  }
  
  private func startDragSession(with event: NSEvent) {
    guard let dragDelegate = dragDelegate else { return }
    
    let draggedImage = self.snapshot()
    
    let draggingItem = NSDraggingItem(pasteboardWriter: NSString(string: "Drag Content"))
    draggingItem.setDraggingFrame(self.bounds, contents: draggedImage)
    
    let session = self.beginDraggingSession(with: [draggingItem], event: event, source: dragDelegate)
    session.animatesToStartingPositionsOnCancelOrFail = true
  }
  
  private func handleTabClick() {
    // 탭 클릭 핸들러 실행
    tabClickHandler?()
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
