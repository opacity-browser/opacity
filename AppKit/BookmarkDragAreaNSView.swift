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
  
  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    self.registerForDraggedTypes([.string])
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func mouseDown(with event: NSEvent) {

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
