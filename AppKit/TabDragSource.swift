//
//  TabDragSource.swift
//  Opacity
//
//  Created by Falsy on 6/3/25.
//

import SwiftUI

class TabDragSource: NSView {
  var appDelegate: AppDelegate?
  var dragDelegate: NSDraggingSource?
  var index: Int?
  var moveTab: ((Int) -> Void)?
  var tabClickHandler: (() -> Void)?  // 탭 클릭 핸들러 추가
  
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
    
    // 기본 mouseDown 처리는 하지 않음 (드래그 판단 후 처리)
  }
  
  override func mouseDragged(with event: NSEvent) {
    guard let dragDelegate = dragDelegate else { return }
    
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
      // 일반 클릭 이벤트 처리 (탭 활성화 등)
      handleTabClick()
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
  
  private func handleTabClick() {
    // 탭 클릭 핸들러 실행
    tabClickHandler?()
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
    if let thisIndex = self.index, let moveFunc = self.moveTab {
      moveFunc(thisIndex)
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
