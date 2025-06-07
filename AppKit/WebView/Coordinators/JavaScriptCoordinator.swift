//
//  JavaScriptCoordinator.swift
//  Opacity
//
//  Created by Falsy on 5/24/25.
//

import SwiftUI
import WebKit

class JavaScriptCoordinator: NSObject, WKUIDelegate {
  var parent: MainWebView!
  
  init(parent: MainWebView) {
    self.parent = parent
    super.init()
  }
  
  func handleUIUpdates(webView: WKWebView) {
    // 쿠키 및 스토리지 정리
    if parent.tab.isClearCookieNStorage {
      clearCookiesAndStorage(webView: webView)
      return
    }
    
    // 줌 레벨 업데이트
    if parent.tab.isZoomDialog && parent.tab.zoomLevel != parent.tab.cacheZoomLevel {
      updateZoomLevel(webView: webView)
      return
    }
    
    // 히스토리 업데이트
    if parent.tab.updateWebHistory {
      updateWebHistory(webView: webView)
      return
    }
    
    // 찾기 액션
    if !parent.tab.findKeyword.isEmpty && parent.tab.isFindAction {
      performFindAction(webView: webView)
      return
    }
  }
  
  private func clearCookiesAndStorage(webView: WKWebView) {
    DispatchQueue.main.async {
      self.parent.tab.isClearCookieNStorage = false
      let cookieStore = webView.configuration.websiteDataStore.httpCookieStore
      cookieStore.getAllCookies { cookies in
        for cookie in cookies {
          cookieStore.delete(cookie)
        }
      }
      let jsString = """
        window.localStorage.clear();
        window.sessionStorage.clear();
      """
      webView.evaluateJavaScript(jsString, completionHandler: nil)
    }
  }
  
  private func updateZoomLevel(webView: WKWebView) {
    let jsString = "document.body.style.zoom = '\(parent.tab.zoomLevel)'"
    webView.evaluateJavaScript(jsString, completionHandler: nil)
    parent.tab.cacheZoomLevel = parent.tab.zoomLevel
  }
  
  private func updateWebHistory(webView: WKWebView) {
    DispatchQueue.main.async {
      // 통합 히스토리 시스템을 위해 WebKit 리스트는 더 이상 업데이트하지 않음
      // 대신 historySiteList를 기반으로 back/forward 리스트를 생성
      self.parent.tab.updateWebHistory = false
    }
  }
  
  private func performFindAction(webView: WKWebView) {
    DispatchQueue.main.async {
      self.parent.tab.isFindAction = false
      self.searchWebView(webView, findText: self.parent.tab.findKeyword, isPrev: self.parent.tab.isFindPrev)
    }
  }
  
  // 텍스트 검색
  func searchWebView(_ webView: WKWebView, findText: String, isPrev: Bool) {
    let script = "window.find('\(findText)', false, \(isPrev), true);"
    webView.evaluateJavaScript(script, completionHandler: nil)
  }
  
  // MARK: - WKUIDelegate 메서드들
  func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
    print("createWebViewWith")
    
    // 이미지 다운로드 처리
    if let customAction = (webView as? OpacityWebView)?.contextualMenuAction,
       let requestURL = navigationAction.request.url {
      if customAction == .downloadImage {
        downloadImage(from: requestURL)
        return nil
      }
    }
    
    // 새 탭에서 열기 처리
    if navigationAction.targetFrame == nil {
      if let requestURL = navigationAction.request.url {
        parent.browser.newTab(requestURL)
      }
    }
    return nil
  }
  
  private func downloadImage(from url: URL) {
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
      guard let data = data, error == nil else { return }
      DispatchQueue.main.async {
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.png, .jpeg, .bmp, .gif, .tiff, .webP]
        savePanel.canCreateDirectories = true
        savePanel.isExtensionHidden = false
        savePanel.title = "Save As"
        savePanel.nameFieldLabel = NSLocalizedString("Save As:", comment: "")
        if url.lastPathComponent != "" {
          savePanel.nameFieldStringValue = url.lastPathComponent
        }
        
        if savePanel.runModal() == .OK, let saveURL = savePanel.url {
          do {
            try data.write(to: saveURL)
            print("Image saved to \(saveURL)")
          } catch {
            print("Failed to save image: \(error)")
          }
        }
      }
    }
    task.resume()
  }
  
  // JavaScript 알림 처리
  func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
    let alert = NSAlert()
    alert.messageText = message
    alert.addButton(withTitle: "OK")
    alert.alertStyle = .warning
    alert.beginSheetModal(for: webView.window!) { _ in
      completionHandler()
    }
  }
  
  // JavaScript 확인 처리
  func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
    let alert = NSAlert()
    alert.messageText = message
    alert.addButton(withTitle: "OK")
    alert.addButton(withTitle: "Cancel")
    alert.alertStyle = .warning
    alert.beginSheetModal(for: webView.window!) { response in
      completionHandler(response == .alertFirstButtonReturn)
    }
  }
  
  // JavaScript 프롬프트 처리
  func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
    let alert = NSAlert()
    alert.messageText = prompt
    alert.addButton(withTitle: "OK")
    alert.addButton(withTitle: "Cancel")
    alert.alertStyle = .informational
    
    let textField = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
    textField.stringValue = defaultText ?? ""
    alert.accessoryView = textField
    
    alert.beginSheetModal(for: webView.window!) { response in
      if response == .alertFirstButtonReturn {
        completionHandler(textField.stringValue)
      } else {
        completionHandler(nil)
      }
    }
  }
  
  // 파일 업로드 처리
  func webView(_ webView: WKWebView, runOpenPanelWith parameters: WKOpenPanelParameters, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping ([URL]?) -> Void) {
    let openPanel = NSOpenPanel()
    openPanel.canChooseFiles = true
    openPanel.canChooseDirectories = false
    openPanel.allowsMultipleSelection = parameters.allowsMultipleSelection
    
    openPanel.beginSheetModal(for: webView.window!) { response in
      if response == .OK {
        completionHandler(openPanel.urls)
      } else {
        completionHandler(nil)
      }
    }
  }
}
