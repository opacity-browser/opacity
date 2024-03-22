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
  @ObservedObject var manualUpdate: ManualUpdate
  var searchHistoryGroups: [SearchHistoryGroup]
  
  class Coordinator: NSObject, NSTextFieldDelegate {
    var parent: SearchNSTextField
    
    init(_ parent: SearchNSTextField) {
      self.parent = parent
    }
    
    func updateTab(_ tab: Tab) {
      self.parent.tab = tab
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
          $0.searchHistories!.count > $1.searchHistories!.count
        }.sorted {
          $0.searchText.hasPrefix(textField.stringValue) && !$1.searchText.hasPrefix(textField.stringValue)
        }
        
        self.parent.tab.autoCompleteIndex = nil
        if self.allowedCharacters(string: lowercaseKeyword)
            && self.parent.tab.autoCompleteList.count > 0
            && lowercaseKeyword.count != self.parent.tab.inputURL.count - 1
            && textField.stringValue.count != 0 {
          self.parent.tab.autoCompleteIndex = 0
        }
        
        self.parent.tab.inputURL = textField.stringValue
      }
    }
    
    func controlTextDidEndEditing(_ notification: Notification) {
      if let _ = notification.object as? NSTextField {
        print("focus out")
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
        
        print("control")
        print(self.parent.tab.id)
        var newURL = self.parent.tab.inputURL
        
        if let choiceIndex = self.parent.tab.autoCompleteIndex {
          newURL = self.parent.tab.autoCompleteList[choiceIndex].searchText
        }
        
        if StringURL.checkURL(url: newURL) {
          if !newURL.contains("://") {
            newURL = "https://\(newURL)"
          }
        } else {
          newURL = "https://www.google.com/search?q=\(newURL)"
        }
        
        DispatchQueue.main.async {
          if(newURL == self.parent.tab.originURL.absoluteString.removingPercentEncoding) {
            self.parent.tab.isEditSearch = false
          } else {
            if let choiceIndex = self.parent.tab.autoCompleteIndex {
              SearchManager.addSearchHistory(self.parent.tab.autoCompleteList[choiceIndex].searchText)
            } else {
              SearchManager.addSearchHistory(self.parent.tab.inputURL)
            }
            self.parent.manualUpdate.search = !self.parent.manualUpdate.search
            self.parent.tab.isPageProgress = true
            self.parent.tab.pageProgress = 0.0
            self.parent.tab.updateURLBySearch(url: URL(string: newURL)!)
            self.parent.tab.isEditSearch = false
            self.parent.tab.autoCompleteIndex = nil
            self.parent.tab.autoCompleteList = []
          }
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
    textField.font = NSFont.systemFont(ofSize: 13.5)
    if let textColor = NSColor(named: "UIText") {      
      textField.textColor = textColor.withAlphaComponent(0.85)
    }
    return textField
  }
  
  func updateNSView(_ nsView: FocusableTextField, context: Context) {
    nsView.stringValue = tab.inputURL
    nsView.tab = tab
    context.coordinator.updateTab(tab)
    if let window = nsView.window, !tab.isEditSearch {
      window.makeFirstResponder(nil)
    }
    if let textColor = NSColor(named: "UIText") {
      nsView.textColor = textColor.withAlphaComponent(tab.isEditSearch ? 0.85 : 0)
    }
  }
}


class FocusableTextField: NSTextField {
  var tab: Tab?
  
  override func becomeFirstResponder() -> Bool {
    let success = super.becomeFirstResponder()
    if success {
      tab?.isEditSearch = true
      if let editor = self.currentEditor() {
        editor.perform(#selector(selectAll(_:)), with: self, afterDelay: 0)
      }
    }
    return success
  }
}
