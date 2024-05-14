//
//  TestNSTextField.swift
//  Opacity
//
//  Created by Falsy on 5/14/24.
//

import SwiftUI

struct SearchNSTextView: NSViewRepresentable {
  var text: String
  var opacity: CGFloat
  
  func makeNSView(context: Context) -> NSTextView {
    let scrollView = NSScrollView()
    let textView = NSTextView()
    scrollView.documentView = textView
    textView.isEditable = false
    textView.drawsBackground = false
    textView.string = text
    textView.textContainer?.containerSize = CGSize(width: CGFloat.infinity, height: CGFloat.infinity)
    textView.textContainer?.widthTracksTextView = false
    textView.isHorizontallyResizable = true
    textView.maxSize = CGSize(width: CGFloat.infinity, height: CGFloat.infinity)
    textView.textContainerInset = .zero
    textView.moveToBeginningOfDocument(nil)
    
    let font = NSFont.systemFont(ofSize: 14, weight: .regular)
    textView.font = font
    
    return textView
  }
  
  func updateNSView(_ nsView: NSTextView, context: Context) {
    nsView.string = text
    
    if nsView.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua {
      nsView.textColor = NSColor.white.withAlphaComponent(opacity)
    } else {
      nsView.textColor = NSColor.black.withAlphaComponent(opacity)
    }
  }
}
