//
//  BookmarkDragArea.swift
//  Opacity
//
//  Created by Falsy on 4/13/24.
//

import SwiftUI

struct BookmarkDragAreaNSView: NSViewRepresentable {
  @ObservedObject var service: Service
  
  func moveBookmark() {
    if let baseGroup = BookmarkManager.getBaseBookmarkGroup() {
      if let startBookmark = service.dragBookmark {
        // 파비콘 데이터도 함께 전달
        BookmarkManager.addBookmark(bookmarkGroup: baseGroup, title: startBookmark.title, url: startBookmark.url, favicon: startBookmark.favicon)
        BookmarkManager.deleteBookmark(bookmark: startBookmark)
      }
      
      if let startBookmarkGroup = service.dragBookmarkGroup {
        BookmarkManager.moveBookamrkGroupToBase(baseGroup: baseGroup, bookmarkGroup: startBookmarkGroup)
      }
    }
  }
  
  func makeNSView(context: Context) -> NSView {
    let containerView = BookmarkAreaDragSource()
    containerView.dragDelegate = context.coordinator
    containerView.moveBookmark = moveBookmark
    
    // 영역 클릭 핸들러 추가 (빈 영역 클릭 시 동작)
    containerView.areaClickHandler = {
      // 빈 영역 클릭 시 수행할 동작 (예: 포커스 해제 등)
      print("Bookmark area clicked")
    }
    
    let hostingView = NSHostingView(rootView: VStack(spacing: 0) { }
      .frame(width: 280, height: 100)
    )
    hostingView.translatesAutoresizingMaskIntoConstraints = false
    
    containerView.addSubview(hostingView)
    
    NSLayoutConstraint.activate([
      hostingView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
      hostingView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
      hostingView.topAnchor.constraint(equalTo: containerView.topAnchor),
      hostingView.heightAnchor.constraint(equalTo: containerView.heightAnchor)
    ])
    
    context.coordinator.bookmarkAreaDragSource = containerView
    return containerView
  }
  
  func updateNSView(_ nsView: NSView, context: Context) {
    
  }
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  class Coordinator: NSObject, NSDraggingSource {
    var parent: BookmarkDragAreaNSView
    weak var bookmarkAreaDragSource: BookmarkAreaDragSource?
    
    init(_ parent: BookmarkDragAreaNSView) {
      self.parent = parent
    }
    
    func draggingSession(_ session: NSDraggingSession, sourceOperationMaskFor context: NSDraggingContext) -> NSDragOperation {
      return .move
    }

    func draggingSession(_ session: NSDraggingSession, willBeginAt screenPoint: NSPoint) {
      
    }
    
    func draggingSession(_ session: NSDraggingSession, endedAt screenPoint: NSPoint, operation: NSDragOperation) {

    }
  }
}


class BookmarkAreaDragSource: NSView {
  var dragDelegate: NSDraggingSource?
  var moveBookmark: (() -> Void)?
  var areaClickHandler: (() -> Void)?  // 영역 클릭 핸들러 추가
  
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
  }
  
  override func mouseDragged(with event: NSEvent) {
    // BookmarkAreaDragSource는 일반적으로 드래그 소스가 아니므로
    // 드래그 시작하지 않음 (단순히 드롭 타겟 역할)
  }
  
  override func mouseUp(with event: NSEvent) {
    let currentTime = event.timestamp
    let currentLocation = event.locationInWindow
    let timeDiff = currentTime - mouseDownTime
    let distance = sqrt(pow(currentLocation.x - mouseDownLocation.x, 2) +
                       pow(currentLocation.y - mouseDownLocation.y, 2))
    
    // 짧은 클릭이고 움직임이 적으면 일반 클릭으로 처리
    if timeDiff < dragMinimumTime && distance < dragMinimumDistance {
      handleAreaClick()
    }
  }
  
  private func handleAreaClick() {
    // 영역 클릭 핸들러 실행
    areaClickHandler?()
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
    if let moveBookmark = self.moveBookmark {
      moveBookmark()
    }
    return true
  }
  
  override func concludeDragOperation(_ sender: NSDraggingInfo?) {
  }
}
