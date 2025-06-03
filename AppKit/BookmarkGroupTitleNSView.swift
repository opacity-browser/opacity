//
//  BookmarkGroupTitleNSView.swift
//  Opacity
//
//  Created by Falsy on 4/13/24.
//

import SwiftUI

struct BookmarkGroupTitleNSView: NSViewRepresentable {
  @ObservedObject var service: Service
  var bookmarkGroup: BookmarkGroup
  
  func moveBookmark() {
    if let startBookmark = service.dragBookmark {
      bookmarkGroup.isOpen = true
      // 파비콘 데이터도 함께 전달
      BookmarkManager.addBookmark(bookmarkGroup: bookmarkGroup, title: startBookmark.title, url: startBookmark.url, favicon: startBookmark.favicon)
      BookmarkManager.deleteBookmark(bookmark: startBookmark)
    }

    if let startBookmarkGroup = service.dragBookmarkGroup {
      if startBookmarkGroup == bookmarkGroup {
        bookmarkGroup.isOpen.toggle()
      } else {
        BookmarkManager.moveBookmarkGroup(from: startBookmarkGroup, to: bookmarkGroup)
      }
    }
  }
  
  func makeNSView(context: Context) -> NSView {
    let containerView = BookmarkGroupDragSource()
    containerView.dragDelegate = context.coordinator
    containerView.moveBookmark = moveBookmark
    
    // 그룹 클릭 핸들러 추가 (폴더 열기/닫기)
    containerView.groupClickHandler = {
      bookmarkGroup.isOpen.toggle()
    }
    
    let hostingView = NSHostingView(rootView: BookmarkGroupTitle(bookmarkGroup: bookmarkGroup))
    hostingView.translatesAutoresizingMaskIntoConstraints = false
    
    containerView.addSubview(hostingView)
    
    NSLayoutConstraint.activate([
      hostingView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
      hostingView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
      hostingView.topAnchor.constraint(equalTo: containerView.topAnchor),
      hostingView.heightAnchor.constraint(equalTo: containerView.heightAnchor)
    ])
    
    context.coordinator.bookmarkGroupDragSource = containerView
    return containerView
  }
  
  func updateNSView(_ nsView: NSView, context: Context) {
    for subview in nsView.subviews {
      if let hostingView = subview as? NSHostingView<BookmarkGroupTitle> {
        hostingView.rootView = BookmarkGroupTitle(bookmarkGroup: bookmarkGroup)
        hostingView.layout()
      }
    }
  }
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  class Coordinator: NSObject, NSDraggingSource {
    var parent: BookmarkGroupTitleNSView
    weak var bookmarkGroupDragSource: BookmarkGroupDragSource?
    
    init(_ parent: BookmarkGroupTitleNSView) {
      self.parent = parent
    }
    
    func draggingSession(_ session: NSDraggingSession, sourceOperationMaskFor context: NSDraggingContext) -> NSDragOperation {
      return .move
    }

    func draggingSession(_ session: NSDraggingSession, willBeginAt screenPoint: NSPoint) {
      self.parent.service.dragBookmarkGroup = self.parent.bookmarkGroup
    }
    
    func draggingSession(_ session: NSDraggingSession, endedAt screenPoint: NSPoint, operation: NSDragOperation) {
      self.parent.service.dragBookmarkGroup = nil
//      print("end")
    }
  }
}


class BookmarkGroupDragSource: NSView {
  var dragDelegate: NSDraggingSource?
  var moveBookmark: (() -> Void)?
  var groupClickHandler: (() -> Void)?  // 그룹 클릭 핸들러 추가
  
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
    guard let _ = dragDelegate else { return }
    
    let currentTime = event.timestamp
    let currentLocation = event.locationInWindow
    let timeDiff = currentTime - mouseDownTime
    let distance = sqrt(pow(currentLocation.x - mouseDownLocation.x, 2) +
                       pow(currentLocation.y - mouseDownLocation.y, 2))
    
    // 시간과 거리 조건을 모두 만족할 때만 드래그 시작
    if timeDiff >= dragMinimumTime || distance >= dragMinimumDistance {
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
    if timeDiff < dragMinimumTime && distance < dragMinimumDistance {
      handleGroupClick()
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
  
  private func handleGroupClick() {
    // 그룹 클릭 핸들러 실행 (폴더 열기/닫기 등)
    groupClickHandler?()
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
