//
//  TabAreaView.swift
//  FriedEgg
//
//  Created by Falsy on 2/14/24.
//

import SwiftUI

struct TabAreaView: NSViewRepresentable {
  @ObservedObject var service: Service
  @Binding var tabs: [Tab]
  @Binding var activeTabId: UUID?
  
  func moveTabArea() {
    print("Move Tab Area Drop")
    if let targetIndex = tabs.firstIndex(where: { $0.id == service.dragTabId }) {
      let removedItem = tabs.remove(at: targetIndex)
      tabs.append(removedItem)
      activeTabId = removedItem.id
    } else {
      service.isMoveTab = true
      for (_, browser) in service.browsers {
        if let targetTab = browser.tabs.first(where: { $0.id == service.dragTabId }) {
          tabs.append(targetTab)
          activeTabId = targetTab.id
          break
        }
      }
    }
  }
  
  func makeNSView(context: Context) -> NSView {
    let containerView = TabAreaDragSource()
    containerView.dragDelegate = context.coordinator
    containerView.moveTabArea = moveTabArea
    
    let hostingView = NSHostingView(rootView: VStack(spacing: 0) { }
      .frame(maxWidth: .infinity, maxHeight: .infinity))
    hostingView.translatesAutoresizingMaskIntoConstraints = false
    
    containerView.addSubview(hostingView)
    
    NSLayoutConstraint.activate([
      hostingView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
      hostingView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
      hostingView.topAnchor.constraint(equalTo: containerView.topAnchor),
      hostingView.heightAnchor.constraint(equalTo: containerView.heightAnchor)
    ])
    
    context.coordinator.tabAreaNSView = containerView
    return containerView
  }
  
  func updateNSView(_ nsView: NSView, context: Context) {
    
  }
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  class Coordinator: NSObject, NSDraggingSource {
    var parent: TabAreaView
    weak var tabAreaNSView: TabAreaDragSource?
    
    init(_ parent: TabAreaView) {
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


class TabAreaDragSource: NSView {
  var appDelegate: AppDelegate?
  var dragDelegate: NSDraggingSource?
  var moveTabArea: (() -> Void)?
  
  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    self.registerForDraggedTypes([.string]) // 드래그 대상으로 등록
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func mouseDown(with event: NSEvent) {

  }
  
  override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
    return .move
  }
  
  override func draggingExited(_ sender: NSDraggingInfo?) {

  }
  
  override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
    if let moveFunc = self.moveTabArea {
      moveFunc()
    }
    return true
  }
  
  override func concludeDragOperation(_ sender: NSDraggingInfo?) {
    
  }
}
