//
//  TabItemView.swift
//  FriedEgg
//
//  Created by Falsy on 2/6/24.
//

import SwiftUI

struct TabItemView: NSViewRepresentable {
  @ObservedObject var service: Service
  @Binding var tabs: [Tab]
  @ObservedObject var tab: Tab
  var isActive: Bool
  @Binding var activeTabId: UUID?
  var index: Int
  @Binding var showProgress: Bool
  @Binding var isTabHover: Bool
  @Binding var loadingAnimation: Bool
  
  func moveTab(_ idx: Int) {
    if let targetIndex = tabs.firstIndex(where: { $0.id == service.dragTabId }) {
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
    
    let hostingView = NSHostingView(rootView: TabItem(tab: tab, isActive: isActive, showProgress: $showProgress, isTabHover: $isTabHover, loadingAnimation: $loadingAnimation))
    hostingView.translatesAutoresizingMaskIntoConstraints = false
    
    containerView.addSubview(hostingView)
    
    NSLayoutConstraint.activate([
      hostingView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
      hostingView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
      hostingView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: -20),
      hostingView.heightAnchor.constraint(equalTo: containerView.heightAnchor)
    ])
    
    context.coordinator.tabItemNSView = containerView
    return containerView
  }
  
  func updateNSView(_ nsView: NSView, context: Context) {
    context.coordinator.thisIndex = index
    context.coordinator.tabId = tab.id
    
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
    var parent: TabItemView
    var thisIndex: Int?
    var tabId: UUID?
    weak var tabItemNSView: TabDragSource?
    
    init(_ parent: TabItemView) {
      self.parent = parent
    }
    
    // 여기에서 NSDraggingSource 프로토콜 메서드 구현
    func draggingSession(_ session: NSDraggingSession, sourceOperationMaskFor context: NSDraggingContext) -> NSDragOperation {
      // parent.boundValue를 사용하여 필요한 로직 구현
      return .move
    }

    func draggingSession(_ session: NSDraggingSession, willBeginAt screenPoint: NSPoint) {
      print("드래그 시작")
      parent.activeTabId = tabId!
      parent.service.dragTabId = tabId!
    }
    
    func draggingSession(_ session: NSDraggingSession, endedAt screenPoint: NSPoint, operation: NSDragOperation) {
      print("드래그 종료, 위치: \(screenPoint)")
      guard let window = tabItemNSView?.window else { return }
      
      // 스크린 좌표계에서의 윈도우 프레임과 드래그 종료 위치 비교
      if !window.frame.contains(screenPoint) {
        print("드래그가 윈도우 영역 밖에서 종료되었습니다.")
        if let dragId = parent.service.dragTabId {
          if let targetIndex = parent.tabs.firstIndex(where: { $0.id == dragId }) {
            if(parent.tabs.count == 1) {
              if parent.service.isMoveTab {
                AppDelegate.shared.closeTab()
              }
            } else {
              if parent.service.isMoveTab {
                parent.activeTabId = parent.tabs[parent.tabs.count - 2].id
                parent.tabs.remove(at: targetIndex)
              } else {
                AppDelegate.shared.createNewWindow(dragId)
              }
            }
          }
        }
      } else {
        print("드래그가 윈도우 영역 안에서 종료되었습니다.")
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
  
  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    self.registerForDraggedTypes([.string]) // 드래그 대상으로 등록
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func mouseDown(with event: NSEvent) {
    guard let dragDelegate = dragDelegate else { return }
    
    let draggedImage = self.snapshot()
    
    let draggingItem = NSDraggingItem(pasteboardWriter: NSString(string: "Drag Content"))
    draggingItem.setDraggingFrame(self.bounds, contents: draggedImage) // 콘텐츠 설정
    
    // beginDraggingSession 호출
    let session = self.beginDraggingSession(with: [draggingItem], event: event, source: dragDelegate)
    session.animatesToStartingPositionsOnCancelOrFail = true
  }
  
  override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
    print("dragenterd")
    return .move
  }
  
  override func draggingExited(_ sender: NSDraggingInfo?) {
      // 드래그 아이템이 대상 영역을 떠났을 때 호출
    print("drag exited")
  }
  
  override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
    print("현재 요소 인덱스: \(self.index!)")
    if let thisIndex = self.index, let moveFunc = self.moveTab {
      print("action")
      moveFunc(thisIndex)
    }
    // 드래그된 데이터 처리 로직
    // 예: 드래그된 문자열 가져오기
//    guard let draggedData = sender.draggingPasteboard.string(forType: .string) else { return false }
//    print("Dragged Data: \(draggedData)")
//
//    appDelegate!.someMethodToCall()
    return true
  }
  
  override func concludeDragOperation(_ sender: NSDraggingInfo?) {
      print("conclude drag operation")
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
