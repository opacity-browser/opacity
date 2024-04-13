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
//    print("dargExited")
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

