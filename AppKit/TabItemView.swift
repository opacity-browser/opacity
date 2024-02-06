//
//  TabItemView.swift
//  FriedEgg
//
//  Created by Falsy on 2/6/24.
//

import SwiftUI

struct TabItemView: NSViewRepresentable {
  @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  @ObservedObject var tab: Tab
  var isActive: Bool
  @Binding var activeTabIndex: Int
  @Binding var dragIndex: Int
  var index: Int
  @Binding var showProgress: Bool
  @Binding var isTabHover: Bool
  @Binding var loadingAnimation: Bool
    
  func makeNSView(context: Context) -> NSView {
    let containerView = TabDragSource()
    containerView.appDelegate = appDelegate
//    containerView.activeIndex = activeTabIndex
//    containerView.index = index
    let hostingView = NSHostingView(rootView: TabItem(tab: tab, isActive: isActive, activeTabIndex: $activeTabIndex, index: index, showProgress: $showProgress, isTabHover: $isTabHover, loadingAnimation: $loadingAnimation))
    
    hostingView.translatesAutoresizingMaskIntoConstraints = false
    
    containerView.addSubview(hostingView)
    
    NSLayoutConstraint.activate([
      hostingView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
      hostingView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
      hostingView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: -20),
//      hostingView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
      hostingView.heightAnchor.constraint(equalTo: containerView.heightAnchor)
    ])
    
//    context.coordinator.view = containerView
    containerView.dragDelegate = context.coordinator
    return containerView
  }
  
  func updateNSView(_ nsView: NSView, context: Context) {
//    if let customView = nsView as? TabDragSource {
//      print("good")
//      customView.activeIndex = activeTabIndex
//      customView.index = index
//    }
//    nsView.activeIndex = activeTabIndex
  }
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  class Coordinator: NSObject, NSDraggingSource {
    var parent: TabItemView
    
    init(_ parent: TabItemView) {
      self.parent = parent
    }
    
    // 여기에서 NSDraggingSource 프로토콜 메서드 구현
    func draggingSession(_ session: NSDraggingSession, sourceOperationMaskFor context: NSDraggingContext) -> NSDragOperation {
      // parent.boundValue를 사용하여 필요한 로직 구현
      return .copy
    }

    func draggingSession(_ session: NSDraggingSession, willBeginAt screenPoint: NSPoint) {
      print(parent.index)
      print("드래그 시작")
      parent.activeTabIndex = parent.index
      parent.dragIndex = parent.index
    }
    
    func draggingSession(_ session: NSDraggingSession, endedAt screenPoint: NSPoint, operation: NSDragOperation) {
      print("드래그 종료, 위치: \(screenPoint)")
    }
  }
}


class TabDragSource: NSView {
  var appDelegate: AppDelegate?
  var dragDelegate: NSDraggingSource?
//  var activeIndex: Int?
//  var index: Int?
  
  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    self.registerForDraggedTypes([.string]) // 드래그 대상으로 등록
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func mouseDown(with event: NSEvent) {
    guard let dragDelegate = dragDelegate else { return }
    
    let draggingItem = NSDraggingItem(pasteboardWriter: NSString(string: "Drag Content"))
    draggingItem.setDraggingFrame(self.bounds, contents: "Your Content Here") // 콘텐츠 설정
    
    // beginDraggingSession 호출
    let session = self.beginDraggingSession(with: [draggingItem], event: event, source: dragDelegate)
    session.animatesToStartingPositionsOnCancelOrFail = true
  }
  
  override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
    print("dragenterd")
    return .copy
  }
  
  override func draggingExited(_ sender: NSDraggingInfo?) {
      // 드래그 아이템이 대상 영역을 떠났을 때 호출
    print("drag exited")
  }
  
  override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
    // 드래그된 데이터 처리 로직
    // 예: 드래그된 문자열 가져오기
    guard let draggedData = sender.draggingPasteboard.string(forType: .string) else { return false }
    print("Dragged Data: \(draggedData)")

    appDelegate!.someMethodToCall()
    return true
  }
  
  override func concludeDragOperation(_ sender: NSDraggingInfo?) {
      print("conclude drag operation")
  }
}
