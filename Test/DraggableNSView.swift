import SwiftUI
import AppKit

struct DraggableNSView: NSViewRepresentable {
    func makeNSView(context: Context) -> some NSView {
      let view = MyCustomView()
      view.wantsLayer = true // 레이어 기반의 뷰 사용
      view.layer?.backgroundColor = NSColor.lightGray.cgColor

      let hostingView = NSHostingView(rootView: TestContentView())
      
      hostingView.frame = CGRect(x: 0, y: 0, width: 200, height: 100)
      
      view.addSubview(hostingView)
      
      return view
    }
    
    func updateNSView(_ nsView: NSViewType, context: Context) {
        // 필요한 경우 뷰 업데이트 로직
    }
}

class MyCustomView: NSView {
  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    self.registerForDraggedTypes([.string]) // 드래그될 데이터 타입 등록
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
    
  override func mouseDown(with event: NSEvent) {
      // 드래그 세션 시작 로직
    print("drag start")
  }
  
  func draggingSession(_ session: NSDraggingSession, willBeginAt screenPoint: NSPoint) {
    print("drag session start")
  }
  
  func draggingSession(_ session: NSDraggingSession, endedAt screenPoint: NSPoint, operation: NSDragOperation) {
      // 드래그 세션이 종료될 때 호출, 윈도우 밖으로 나갔는지 여부를 확인할 수 있음
    print("drag end")
  }
          
  override func draggingExited(_ sender: NSDraggingInfo?) {
      // 드래그 아이템이 대상 영역을 떠났을 때 호출
    print("drag exited")
  }
  
  override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
    print("dragenterd")
      return .copy
  }
  
  override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
    // 드래그된 데이터 처리 로직
    // 예: 드래그된 문자열 가져오기
    guard let draggedData = sender.draggingPasteboard.string(forType: .string) else { return false }
    print("Dragged Data: \(draggedData)")
    return true
  }
}
