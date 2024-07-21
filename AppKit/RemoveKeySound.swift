//
//  RemoveKeySound.swift
//  Opacity
//
//  Created by Falsy on 7/22/24.
//

import SwiftUI

class RemoveSoundNSView: NSView {
  override func performKeyEquivalent(with event: NSEvent) -> Bool {
    if handleShortcut(event: event) == false {
      return true
    }
    
    return super.performKeyEquivalent(with: event)
  }
  
  private func handleShortcut(event: NSEvent) -> Bool {
    // Event keyCode
    // 0(A) / 1(S) / 3(F) / 5(G) / 6(Z) / 7(X) / 8(C) / 9(V) / 12(Q) / 13(W) / 14(E) / 15(R)
    // 17(T) / 24(+) / 27(-) / 43(,) / 45(N) / 47(M) / 123(←) / 124(→) / 125(↓) / 126(↑)
    if event.modifierFlags.contains(.command)
        && [0, 1, 3, 5, 6, 7, 8, 9, 12, 13, 15, 17, 24, 27, 43, 45, 46].contains(event.keyCode) {
      return true
    }
    
    if event.modifierFlags.contains(.option) && [3, 14].contains(event.keyCode) {
      return true
    }
    
    if [123, 124, 125, 126].contains(event.keyCode) {
      return true
    }
    
    return false
  }
}

struct RemoveSoundRepresentable: NSViewRepresentable {
  func makeNSView(context: Context) -> RemoveSoundNSView {
    return RemoveSoundNSView()
  }
  
  func updateNSView(_ nsView: RemoveSoundNSView, context: Context) { }
}
