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
  var isFocused: Binding<Bool>?
  
  var searchHistoryGroups: [SearchHistoryGroup]
  @Binding var autoCompleteList: [SearchHistoryGroup]
  
  @Binding var autoCompleteIndex: Int
  @Binding var autoCompleteText: String
  
  class Coordinator: NSObject, NSTextFieldDelegate {
    var parent: SearchNSTextField
    var isAddString: Bool = true
    
    init(_ parent: SearchNSTextField) {
      self.parent = parent
    }
    
    func controlTextDidChange(_ obj: Notification) {
      if let textField = obj.object as? NSTextField {
        
        
        let lowercaseKeyword = textField.stringValue.lowercased()
        self.parent.autoCompleteList = self.parent.searchHistoryGroups.filter {
          $0.searchText.localizedStandardContains(lowercaseKeyword)
        }.sorted {
          $0.searchHistories!.count > $1.searchHistories!.count
        }.sorted {
          $0.searchText.lowercased().hasPrefix(lowercaseKeyword) && !$1.searchText.lowercased().hasPrefix(lowercaseKeyword)
        }.sorted {
          $0.searchText.hasPrefix(textField.stringValue) && !$1.searchText.hasPrefix(textField.stringValue)
        }
        
        if self.isAddString && self.parent.autoCompleteList.count > 0 && self.parent.autoCompleteIndex == -1 {
          self.parent.autoCompleteIndex = 0
        }
        
        self.parent.tab.inputURL = textField.stringValue
        self.isAddString = true
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
        var newURL = self.parent.tab.inputURL
        if StringURL.checkURL(url: newURL) {
          if !newURL.contains("://") {
            newURL = "https://\(newURL)"
          }
        } else {
          newURL = "https://www.google.com/search?q=\(newURL)"
        }
        if(newURL != self.parent.tab.originURL.absoluteString.removingPercentEncoding) {
          SearchManager.addSearchHistory(self.parent.tab.inputURL)
          DispatchQueue.main.async {
            self.parent.manualUpdate.search = !self.parent.manualUpdate.search
            self.parent.tab.isPageProgress = true
            self.parent.tab.pageProgress = 0.0
            self.parent.tab.updateURLBySearch(url: URL(string: newURL)!)
            self.parent.tab.isEditSearch = false
          }
        }
        return true
      } else if (commandSelector == #selector(NSResponder.deleteBackward(_:)) || commandSelector == #selector(NSResponder.cancelOperation(_:))) {
        self.isAddString = false
        if self.parent.autoCompleteList.count > 0 && self.parent.autoCompleteIndex > -1 {
          self.parent.autoCompleteIndex = -1
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
  
  func makeNSView(context: Context) -> NSTextField {
    let textField = NSTextField()
    textField.delegate = context.coordinator
    textField.isBordered = false
    textField.focusRingType = .none
    textField.font = NSFont.systemFont(ofSize: 13.5)
    if let textColor = NSColor(named: "UIText") {
      textField.textColor = textColor.withAlphaComponent(0.85)
    }
    return textField
  }
  
  func updateNSView(_ nsView: NSTextField, context: Context) {
    nsView.stringValue = tab.inputURL

    if let isFocused = isFocused?.wrappedValue, isFocused, nsView.window?.firstResponder != nsView.currentEditor() {
      nsView.window?.makeFirstResponder(nsView)
    } else if let isFocused = isFocused?.wrappedValue, !isFocused, nsView.window?.firstResponder == nsView.currentEditor() {
      nsView.window?.makeFirstResponder(nil)
    }
  }
}
