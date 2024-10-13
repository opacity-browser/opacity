//
//  BackKeyButton.swift
//  Opacity
//
//  Created by Falsy on 2/17/24.
//
import SwiftUI

struct HistoryKeyNSView: NSViewRepresentable {
  @ObservedObject var tab: Tab
  var isBack: Bool
  var clickAction: (Bool) -> Void
  var longPressAction: () -> Void
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  class Coordinator: NSObject {
    var parent: HistoryKeyNSView

    init(_ parent: HistoryKeyNSView) {
      self.parent = parent
    }

    @objc func handleClick(_ sender: NSClickGestureRecognizer) {
      let isCommandPressed = NSEvent.modifierFlags.contains(.command)
      parent.clickAction(isCommandPressed)
    }
  }
  
  func makeNSView(context: Context) -> NSView {
    let containerView = HistoryKeyButtonNSView()
    containerView.clickAction = clickAction
    containerView.longPressAction = longPressAction
    
    let clickRecognizer = NSClickGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handleClick(_:)))
    containerView.addGestureRecognizer(clickRecognizer)
    
    let hostingView = NSHostingView(rootView: HistoryKeyButton(tab: tab, isBack: isBack))
    hostingView.translatesAutoresizingMaskIntoConstraints = false
    
    containerView.addSubview(hostingView)
    
    NSLayoutConstraint.activate([
      hostingView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
      hostingView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
      hostingView.topAnchor.constraint(equalTo: containerView.topAnchor),
      hostingView.heightAnchor.constraint(equalTo: containerView.heightAnchor)
    ])
    
    return containerView
  }
  
  func updateNSView(_ nsView: NSView, context: Context) {
    for subview in nsView.subviews {
      if let hostingView = subview as? NSHostingView<HistoryKeyButton> {
        hostingView.rootView = HistoryKeyButton(tab: tab, isBack: isBack)
        hostingView.layout()
      }
    }
    
    if let customView = nsView as? HistoryKeyButtonNSView {
      customView.clickAction = clickAction
      customView.longPressAction = longPressAction
    }
  }
}

class HistoryKeyButtonNSView: NSView {
  var clickAction: ((Bool) -> Void)?
  var longPressAction: (() -> Void)?
  private var longPressTimer: Timer?
  
  override func mouseDown(with event: NSEvent) {
    super.mouseDown(with: event)
    longPressTimer?.invalidate()
    longPressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { [weak self] _ in
      self?.longPressAction?()
    }
  }
  
  override func mouseUp(with event: NSEvent) {
    super.mouseUp(with: event)
    if longPressTimer != nil && longPressTimer!.isValid {
      longPressTimer?.invalidate()
      let isCommandPressed = event.modifierFlags.contains(.command)
      clickAction?(isCommandPressed)
    }
  }
}
