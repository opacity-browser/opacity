//
//  BookmarkNSTextField.swift
//  Opacity
//
//  Created by Falsy on 4/11/24.
//

import SwiftUI

struct BookmarkNSTextField: NSViewRepresentable {
  
  @Binding var searchText: String
  
  class Coordinator: NSObject, NSTextFieldDelegate {
    var parent: BookmarkNSTextField
    
    init(_ parent: BookmarkNSTextField) {
      self.parent = parent
    }
    
    func controlTextDidChange(_ obj: Notification) {
      guard let textField = obj.object as? NSTextField else { return }
      self.parent.searchText = textField.stringValue
    }
  }
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  func makeNSView(context: Context) -> NSTextField {
    let textField = NSTextField()
    textField.delegate = context.coordinator
    textField.isBordered = false
    textField.focusRingType = .none
    textField.drawsBackground = false
    
    textField.cell?.wraps = false
    textField.cell?.isScrollable = true
    textField.cell?.usesSingleLineMode = true
    
    textField.font = NSFont.systemFont(ofSize: 13.5)
    
    return textField
  }
  
  func updateNSView(_ nsView: NSTextField, context: Context) {
    nsView.stringValue = searchText
    
    if nsView.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua {
      nsView.textColor = NSColor.white.withAlphaComponent(0.85)
    } else {
      nsView.textColor = NSColor.black.withAlphaComponent(0.85)
    }
  }
}
