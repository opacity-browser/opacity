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
    
    // 북마크 클릭 핸들러 추가
    let bookmarkUrl = bookmark.url
    let _ = browser.id
    containerView.bookmarkClickHandler = {
      print("Custom bookmark click handler called") // 디버깅용
      if let activeTabId = browser.activeTabId,
         let thisTab = browser.tabs.first(where: { $0.id == activeTabId }),
         thisTab.isInit {
        thisTab.updateURLBySearch(url: URL(string: bookmarkUrl)!)
      } else {
        browser.newTab(URL(string: bookmarkUrl)!)
      }
    }
    
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
  var bookmarkClickHandler: (() -> Void)?  // 북마크 클릭 핸들러 추가
  
  // 드래그 감지를 위한 프로퍼티들
  private var mouseDownTime: TimeInterval = 0
  private var mouseDownLocation: NSPoint = .zero
  private var dragMinimumTime: TimeInterval = 0.15 // 최소 드래그 시간 (150ms로 증가)
  private var dragMinimumDistance: CGFloat = 5.0   // 최소 드래그 거리 (5pt로 증가)
  
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
    
    // 기본 mouseDown 처리도 수행
    super.mouseDown(with: event)
  }
  
  override func mouseDragged(with event: NSEvent) {
    // 드래그가 비활성화된 경우 처리하지 않음
    guard let enabledDrag = enabledDrag, enabledDrag else { return }
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
      handleBookmarkClick()
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
  
  private func handleBookmarkClick() {
    print("Bookmark clicked!") // 디버깅용 로그
    
    if let enabledDrag = enabledDrag, !enabledDrag {
      // 드래그가 비활성화된 경우 기존 클릭 로직 실행
      if let browser = browser, let bookmark = bookmark {
        DispatchQueue.main.async {
          if let activeTabId = browser.activeTabId,
             let thisTab = browser.tabs.first(where: { $0.id == activeTabId }),
             thisTab.isInit {
            thisTab.updateURLBySearch(url: URL(string: bookmark.url)!)
          } else {
            browser.newTab(URL(string: bookmark.url)!)
          }
        }
      }
    } else {
      // 커스텀 클릭 핸들러가 있으면 실행
      DispatchQueue.main.async {
        self.bookmarkClickHandler?()
      }
    }
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
