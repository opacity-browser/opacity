//
//  TabAreaView.swift
//  Opacity
//
//  Created by Falsy on 2/14/24.
//

import SwiftUI

struct TabDragAreaNSView: NSViewRepresentable {
  @ObservedObject var service: Service
  @Binding var tabs: [Tab]
  @Binding var activeTabId: UUID?
  
  func moveTabArea() {
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
    let containerView = TabDragAreaSource()
    containerView.dragDelegate = context.coordinator
    containerView.moveTabArea = moveTabArea
    
    let hostingView = NSHostingView(rootView: VStack(spacing: 0) { }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
    )
    hostingView.translatesAutoresizingMaskIntoConstraints = false
    
    containerView.addSubview(hostingView)
    
    NSLayoutConstraint.activate([
      hostingView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
      hostingView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
      hostingView.topAnchor.constraint(equalTo: containerView.topAnchor),
      hostingView.heightAnchor.constraint(equalTo: containerView.heightAnchor)
    ])
    
    context.coordinator.tabDragAreaNSView = containerView
    return containerView
  }
  
  func updateNSView(_ nsView: NSView, context: Context) {
    
  }
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  class Coordinator: NSObject, NSDraggingSource {
    var parent: TabDragAreaNSView
    weak var tabDragAreaNSView: TabDragAreaSource?
    
    init(_ parent: TabDragAreaNSView) {
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


class TabDragAreaSource: NSView {
  var appDelegate: AppDelegate?
  var dragDelegate: NSDraggingSource?
  var moveTabArea: (() -> Void)?
  
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
    if let moveFunc = self.moveTabArea {
      moveFunc()
    }
    return true
  }
  
  override func concludeDragOperation(_ sender: NSDraggingInfo?) {
    
  }
}
