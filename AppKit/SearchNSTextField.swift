//
//  SearchTextField.swift
//  Opacity
//
//  Created by Falsy on 3/19/24.
//

import SwiftUI

struct SearchNSTextField: NSViewRepresentable {
  @ObservedObject var browser: Browser
  @ObservedObject var tab: Tab
  var searchHistoryGroups: [SearchHistoryGroup]
  var visitHistoryGroups: [VisitHistoryGroup]
  
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
        self.parent.tab.autoCompleteList = self.parent.searchHistoryGroups.filter {
          $0.searchText.lowercased().hasPrefix(lowercaseKeyword)
        }.sorted {
          $0.searchHistories.count > $1.searchHistories.count
        }.sorted {
          $0.searchText.hasPrefix(textField.stringValue) && !$1.searchText.hasPrefix(textField.stringValue)
        }
        
        self.parent.tab.autoCompleteVisitList = self.parent.visitHistoryGroups.filter {
          $0.url.contains(lowercaseKeyword) || ($0.title != nil && $0.title!.contains(lowercaseKeyword))
        }.sorted {
          $0.visitHistories.count > $1.visitHistories.count
        }
        
        if !self.parent.tab.isChangeByKeyDown {
          self.parent.tab.autoCompleteIndex = nil
        } else {
          self.parent.tab.isChangeByKeyDown = false
        }
        
        if self.allowedCharacters(string: lowercaseKeyword)
            && (self.parent.tab.autoCompleteList.count + self.parent.tab.autoCompleteVisitList.count) > 0
            && lowercaseKeyword.count != self.parent.tab.inputURL.count - 1
            && textField.stringValue.count != 0 {
          self.parent.tab.autoCompleteIndex = 0
        }
        
        self.parent.tab.inputURL = textField.stringValue
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
      if (commandSelector == #selector(NSResponder.insertNewline(_:))) {
        if self.parent.tab.inputURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
          return true
        }
        DispatchQueue.main.async {
          self.parent.tab.searchInSearchBar()
        }
        return true
      } else if (commandSelector == #selector(NSResponder.deleteBackward(_:)) || commandSelector == #selector(NSResponder.cancelOperation(_:))) {
        let selectedRange = textView.selectedRange()
        if let index = self.parent.tab.autoCompleteIndex,
           self.parent.tab.autoCompleteList.count > 0,
           self.parent.tab.autoCompleteList[index].searchText != self.parent.tab.inputURL,
           selectedRange.length == 0 {
          DispatchQueue.main.async {
            self.parent.tab.autoCompleteIndex = nil
          }
          return true
        }
        return false
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
    
    textField.cell?.wraps = false
    textField.cell?.isScrollable = true
    textField.cell?.usesSingleLineMode = true
    
    textField.font = NSFont.systemFont(ofSize: 13.5)
    
    return textField
  }
  
  func updateNSView(_ nsView: FocusableTextField, context: Context) {
    nsView.stringValue = tab.inputURL
    nsView.tab = tab
    context.coordinator.updateTab(tab: tab, searchHistoryGroups: searchHistoryGroups, visitHistoryGroups: visitHistoryGroups)
    
    let textAlpha = tab.isEditSearch ? 0.85 : 0
    if nsView.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua {
      nsView.textColor = NSColor.white.withAlphaComponent(textAlpha)
    } else {
      nsView.textColor = NSColor.black.withAlphaComponent(textAlpha)
    }
    
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
