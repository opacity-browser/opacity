//
//  BookmarkTitleNSView.swift
//  Opacity
//
//  Created by Falsy on 4/13/24.
//

import SwiftUI

struct BookmarkTitleNSView: NSViewRepresentable {
  @ObservedObject var service: Service
  @ObservedObject var browser: Browser
  var bookmark: Bookmark
  var enabledDrag: Bool
  
  func moveBookmark() {
    if let startBookmark = service.dragBookmark {
      if startBookmark == bookmark {
        if let activeTabId = browser.activeTabId, let thisTab = browser.tabs.first(where: { $0.id == activeTabId }), thisTab.isInit {
          thisTab.updateURLBySearch(url: URL(string: bookmark.url)!)
        } else {
          browser.newTab(URL(string: bookmark.url)!)
        }
      } else {
        BookmarkManager.moveBookmark(from: startBookmark, to: bookmark)
      }
    }
    
    if let startBookmarkGroup = service.dragBookmarkGroup {
      BookmarkManager.moveBookmarkGroupToBookmark(startBookmarkGroup: startBookmarkGroup, endBookmark: bookmark)
    }
  }
  
  func makeNSView(context: Context) -> NSView {
    let containerView = BookmarkDragSource()
    containerView.browser = browser
    containerView.bookmark = bookmark
    containerView.dragDelegate = context.coordinator
    containerView.moveBookmark = moveBookmark
    containerView.enabledDrag = enabledDrag
    
    let hostingView = NSHostingView(rootView: BookmarkTitle(bookmark: bookmark))
    hostingView.translatesAutoresizingMaskIntoConstraints = false
    
    containerView.addSubview(hostingView)
    
    NSLayoutConstraint.activate([
      hostingView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
      hostingView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
      hostingView.topAnchor.constraint(equalTo: containerView.topAnchor),
      hostingView.heightAnchor.constraint(equalTo: containerView.heightAnchor)
    ])
    
    context.coordinator.bookmarkDragSource = containerView
    return containerView
  }
  
  func updateNSView(_ nsView: NSView, context: Context) {
    for subview in nsView.subviews {
      if let hostingView = subview as? NSHostingView<BookmarkTitle> {
        hostingView.rootView = BookmarkTitle(bookmark: bookmark)
        hostingView.layout()
      }
    }
  }
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  class Coordinator: NSObject, NSDraggingSource {
    var parent: BookmarkTitleNSView
    weak var bookmarkDragSource: BookmarkDragSource?
    
    init(_ parent: BookmarkTitleNSView) {
      self.parent = parent
    }
    
    func draggingSession(_ session: NSDraggingSession, sourceOperationMaskFor context: NSDraggingContext) -> NSDragOperation {
      return .move
    }

    func draggingSession(_ session: NSDraggingSession, willBeginAt screenPoint: NSPoint) {
      self.parent.service.dragBookmark = self.parent.bookmark
    }
    
    func draggingSession(_ session: NSDraggingSession, endedAt screenPoint: NSPoint, operation: NSDragOperation) {
      self.parent.service.dragBookmark = nil
//      print("end")
    }
  }
}


class BookmarkDragSource: NSView {
  var dragDelegate: NSDraggingSource?
  var browser: Browser?
  var bookmark: Bookmark?
  var moveBookmark: (() -> Void)?
  var enabledDrag: Bool?
  
  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    self.registerForDraggedTypes([.string])
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func mouseDown(with event: NSEvent) {
    if let enabledDrag = enabledDrag, let browser = browser, let bookmark = bookmark, enabledDrag == false {
      if let activeTabId = browser.activeTabId, let thisTab = browser.tabs.first(where: { $0.id == activeTabId }), thisTab.isInit {
        thisTab.updateURLBySearch(url: URL(string: bookmark.url)!)
      } else {
        browser.newTab(URL(string: bookmark.url)!)
      }
      return
    }
    
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
