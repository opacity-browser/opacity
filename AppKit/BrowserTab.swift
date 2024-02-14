////
////  BrowserTab.swift
////  FriedEgg
////
////  Created by Falsy on 2/5/24.
////
//
//import SwiftUI
//import AppKit
//
//struct BrowserTab: NSViewRepresentable {
//  @Binding var tabs: [Tab]
//  @Binding var activeTabIndex: Int
//  @Binding var progress: Double
//  @Binding var showProgress: Bool
//  
//  func makeNSView(context: Context) -> NSView {
//    let containerView = BrowserTabViewByAppKit()
//    containerView.wantsLayer = true
//    let hostingView = NSHostingView(rootView: TitlebarView(tabs: $tabs, activeTabIndex: $activeTabIndex, progress: $progress, showProgress: $showProgress)
//    )
//    hostingView.translatesAutoresizingMaskIntoConstraints = false // Auto Layout 사용 설정
//
//    containerView.addSubview(hostingView)
//    
//    // Auto Layout Constraints 추가
//    NSLayoutConstraint.activate([
//      hostingView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
//      hostingView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
//      hostingView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 0),
//      hostingView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
//    ])
//    
//    return containerView
//  }
//  
//  func updateNSView(_ nsView: NSView, context: Context) {
//      // 필요한 경우 뷰 업데이트 로직
//  }
//}
//
//class BrowserTabViewByAppKit: NSView, NSDraggingSource {
//  
//  override func mouseDown(with event: NSEvent) {
//      let pasteboardItem = NSPasteboardItem()
//      pasteboardItem.setString("드래그 데이터", forType: .string)
//      
//      let draggingItem = NSDraggingItem(pasteboardWriter: pasteboardItem)
//      draggingItem.setDraggingFrame(self.bounds, contents: "드래그 이미지 또는 데이터")
//      
//      let draggingSession = beginDraggingSession(with: [draggingItem], event: event, source: self)
//      draggingSession.animatesToStartingPositionsOnCancelOrFail = true
//  }
//  
//  func draggingSession(_ session: NSDraggingSession, willBeginAt screenPoint: NSPoint) {
//      print("드래그 시작")
//  }
//  
//  func draggingSession(_ session: NSDraggingSession, endedAt screenPoint: NSPoint, operation: NSDragOperation) {
//      print("드래그 종료, 위치: \(screenPoint)")
//  }
//  
//  func draggingSession(_ session: NSDraggingSession, sourceOperationMaskFor context: NSDraggingContext) -> NSDragOperation {
//    return .copy
//  }
//  
//  override init(frame frameRect: NSRect) {
//    super.init(frame: frameRect)
//    self.registerForDraggedTypes([.string]) // 드래그될 데이터 타입 등록
//  }
//  
//  required init?(coder: NSCoder) {
//    fatalError("init(coder:) has not been implemented")
//  }
//    
////  override func mouseDown(with event: NSEvent) {
////      // 드래그 세션 시작 로직
////    print("drag start")
////  }
////  
////  func draggingSession(_ session: NSDraggingSession, willBeginAt screenPoint: NSPoint) {
////    print("drag session start")
////  }
////  
////  func draggingSession(_ session: NSDraggingSession, endedAt screenPoint: NSPoint, operation: NSDragOperation) {
////      // 드래그 세션이 종료될 때 호출, 윈도우 밖으로 나갔는지 여부를 확인할 수 있음
////    print("drag end")
////  }
//          
//  override func draggingExited(_ sender: NSDraggingInfo?) {
//      // 드래그 아이템이 대상 영역을 떠났을 때 호출
//    print("drag exited")
//  }
//  
//  override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
//    print("dragenterd")
//    return .copy
//  }
//  
//  override func concludeDragOperation(_ sender: NSDraggingInfo?) {
//      print("conclude drag operation")
//  }
//  
//  override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
//    // 드래그된 데이터 처리 로직
//    // 예: 드래그된 문자열 가져오기
//    guard let draggedData = sender.draggingPasteboard.string(forType: .string) else { return false }
//    print("Dragged Data: \(draggedData)")
//    return true
//  }
//}
