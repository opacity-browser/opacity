//
//  FindNSTextField.swift
//  Opacity
//
//  Created by Falsy on 4/20/24.
//

import SwiftUI

struct FindNSTextField: NSViewRepresentable {
  @ObservedObject var tab: Tab
  
  class Coordinator: NSObject, NSTextFieldDelegate {
    var parent: FindNSTextField
    
    init(_ parent: FindNSTextField) {
      self.parent = parent
    }
    
    func controlTextDidChange(_ obj: Notification) {
      guard let textField = obj.object as? NSTextField else { return }
      self.parent.tab.findKeyword = textField.stringValue
    }
    
    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
      if (commandSelector == #selector(NSResponder.insertNewline(_:))) {
        if self.parent.tab.findKeyword.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
          return true
        }
        
        if NSEvent.modifierFlags.contains(.shift) {
          AppDelegate.shared.findKeywordPrev()
        } else {
          AppDelegate.shared.findKeywordNext()
        }
      }
      if (commandSelector == #selector(NSResponder.cancelOperation(_:))) {
        self.parent.tab.isFindDialog = false
      }
      return false
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
    nsView.stringValue = self.tab.findKeyword
    
    if nsView.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua {
      nsView.textColor = NSColor.white.withAlphaComponent(0.85)
    } else {
      nsView.textColor = NSColor.black.withAlphaComponent(0.85)
    }
  }
}
