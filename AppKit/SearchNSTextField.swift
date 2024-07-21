//
//  SearchTextField.swift
//  Opacity
//
//  Created by Falsy on 3/19/24.
//

import SwiftUI

struct SearchNSTextField: NSViewRepresentable {
  @Environment(\.colorScheme) var colorScheme
  
  @ObservedObject var browser: Browser
  @ObservedObject var tab: Tab
  var searchHistoryGroups: [SearchHistoryGroup]
  var visitHistoryGroups: [VisitHistoryGroup]
  @Binding var isScrollable: Bool
  
  class Coordinator: NSObject, NSTextFieldDelegate {
    var parent: SearchNSTextField
    
    init(_ parent: SearchNSTextField) {
      self.parent = parent
    }
    
    func updateTab(tab: Tab, searchHistoryGroups: [SearchHistoryGroup], visitHistoryGroups: [VisitHistoryGroup]) {
      self.parent.tab = tab
      self.parent.searchHistoryGroups = searchHistoryGroups
      self.parent.visitHistoryGroups = visitHistoryGroups
    }
    
    func allowedCharacters(string: String) -> Bool {
      let allowedCharacterSet = CharacterSet.urlQueryAllowed
      return string.unicodeScalars.allSatisfy { allowedCharacterSet.contains($0) }
    }
    
    func controlTextDidBeginEditing(_ obj: Notification) {
      
    }
    
    func controlTextDidChange(_ obj: Notification) {
      guard let textField = obj.object as? NSTextField else { return }
      let lowercaseKeyword = textField.stringValue.lowercased()
      
      DispatchQueue.main.async {
        self.parent.tab.inputURL = textField.stringValue
        
        if !self.parent.tab.isChangeByKeyDown {
          self.parent.tab.autoCompleteIndex = nil
        } else {
          self.parent.tab.isChangeByKeyDown = false
        }
        
        if let autoCompleteSearchList = SearchManager.findSearchHistoryGroup(lowercaseKeyword) {
          self.parent.tab.autoCompleteList = autoCompleteSearchList
        }
        
        if let autoCompleteVisitList = VisitManager.findVisitHistoryGroup(lowercaseKeyword) {
          self.parent.tab.autoCompleteVisitList = autoCompleteVisitList
        }
        
        if self.allowedCharacters(string: lowercaseKeyword)
            && (self.parent.tab.autoCompleteList.count + self.parent.tab.autoCompleteVisitList.count) > 0
            && lowercaseKeyword.count != self.parent.tab.inputURL.count - 1
            && textField.stringValue.count != 0 {
          self.parent.tab.autoCompleteIndex = 0
        }
        
        self.checkScrollable(textField: textField)
      }
    }
    
    func checkScrollable(textField: NSTextField) {
      guard let textView = textField.currentEditor() as? NSTextView else { return }
      let layoutManager = textView.layoutManager!
      let textContainer = textView.textContainer!
      
      layoutManager.ensureLayout(for: textContainer)
      let usedRect = layoutManager.usedRect(for: textContainer)
      
      DispatchQueue.main.async {
        self.parent.isScrollable = usedRect.size.width > textField.bounds.size.width
      }
    }
    
    func controlTextDidEndEditing(_ notification: Notification) {
      if let _ = notification.object as? NSTextField {
        DispatchQueue.main.async {
          self.parent.tab.isEditSearch = false
        }
      }
    }
    
    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
      if commandSelector == #selector(NSResponder.insertNewline(_:)) {
        if self.parent.tab.inputURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
          return true
        }
        DispatchQueue.main.async {
          self.parent.tab.searchInSearchBar()
        }
        return true
      } else if commandSelector == #selector(NSResponder.deleteBackward(_:)) {
        let selectedRange = textView.selectedRange()
        if let index = self.parent.tab.autoCompleteIndex,
           self.parent.tab.autoCompleteList.count > 0,
           self.parent.tab.autoCompleteList.count > index,
           self.parent.tab.autoCompleteList[index].searchText != self.parent.tab.inputURL,
           selectedRange.length == 0 {
          DispatchQueue.main.async {
            self.parent.tab.autoCompleteIndex = nil
          }
          return true
        }
        return false
      } else if commandSelector == #selector(NSResponder.cancelOperation(_:)) {
        let selectedRange = textView.selectedRange()
        if let index = self.parent.tab.autoCompleteIndex,
           self.parent.tab.autoCompleteList.count > 0,
           self.parent.tab.autoCompleteList.count > index,
           self.parent.tab.autoCompleteList[index].searchText != self.parent.tab.inputURL,
           selectedRange.length == 0 {
          DispatchQueue.main.async {
            self.parent.tab.autoCompleteIndex = nil
          }
          return true
        } else {
          DispatchQueue.main.async {
            self.parent.tab.isEditSearch = false
          }
          return true
        }
      }
      return false
    }
  }
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  func makeNSView(context: Context) -> FocusableTextField {
    let textField = FocusableTextField()
    textField.tab = tab
    textField.delegate = context.coordinator
    textField.isBordered = false
    textField.focusRingType = .none
    textField.drawsBackground = false
    
    if let textCell = textField.cell as? NSTextFieldCell {
      textCell.wraps = false
      textCell.isScrollable = true
      textCell.usesSingleLineMode = true
    }
    
    let font = NSFont.systemFont(ofSize: 14, weight: .regular)
    textField.font = font
    
    return textField
  }
  
  func updateNSView(_ nsView: FocusableTextField, context: Context) {
    nsView.stringValue = tab.inputURL
    nsView.tab = tab
    context.coordinator.updateTab(tab: tab, searchHistoryGroups: searchHistoryGroups, visitHistoryGroups: visitHistoryGroups)
    
    let textAlpha = tab.isEditSearch ? 0.85 : 0.0
    if colorScheme == .dark {
      nsView.textColor = NSColor.white.withAlphaComponent(textAlpha)
    } else {
      nsView.textColor = NSColor.black.withAlphaComponent(textAlpha)
    }
    
    context.coordinator.checkScrollable(textField: nsView)
    
    if let window = nsView.window {
      if tab.isInit && tab.isInitFocus {
        DispatchQueue.main.async {
          tab.isInitFocus = false
        }
        window.makeFirstResponder(nsView)
      } else if tab.isEditSearch == false && window.firstResponder == nsView.currentEditor() {
        window.makeFirstResponder(nil)
      } else if tab.isEditSearch && window.firstResponder != nsView.currentEditor() {
        window.makeFirstResponder(nsView)
      }
    }
  }
}


class FocusableTextField: NSTextField {
  var tab: Tab?
  
  override func becomeFirstResponder() -> Bool {
    let success = super.becomeFirstResponder()
    if success {
      DispatchQueue.main.async {
        self.tab?.isEditSearch = true
      }
      if let editor = self.currentEditor() {
        editor.perform(#selector(selectAll(_:)), with: self, afterDelay: 0)
      }
    }
    return success
  }
}
