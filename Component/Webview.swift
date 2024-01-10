//
//  Webview.swift
//  Opacity
//
//  Created by Falsy on 1/10/24.
//

import SwiftUI
import WebKit

struct Webview: NSViewRepresentable {
    @Binding var webURL: String
    @Binding var inputURL: String
    @Binding var viewURL: String
    @Binding var title: String
    
    @Binding var goToPage: Bool
    @Binding var goBack: Bool
    @Binding var goForward: Bool
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        let parent: Webview
        
        init(_ parent: Webview) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            print("############# 코디네이터 호출: didStartProvisionalNavigation")
            print("webview url: \(String(describing: webView.url))")
            print("webview site url: \(parent.webURL)")
            print("input url: \(parent.inputURL )")
            
            var nowWebviewURL: String = ""
            var nowWebviewStringURL: String = ""
            if let stringURL = webView.url {
                nowWebviewStringURL = String(describing: stringURL)
                nowWebviewURL = String(describing: stringURL)
                nowWebviewURL = StringURL.removeLastSlash(url: nowWebviewURL)
            }
            
            if parent.webURL != nowWebviewURL {
                parent.webURL = nowWebviewURL
                parent.viewURL = StringURL.shortURL(url: nowWebviewURL)
                parent.inputURL = StringURL.removeLastSlash(url: nowWebviewStringURL)
            }
            
            if parent.goBack {
                webView.goBack()
                parent.goBack = false
            }
            if parent.goForward {
                webView.goForward()
                parent.goForward = false
            }
        }
        
        func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
            print("############# 리다이렉트 호출: didReceiveServerRedirectForProvisionalNavigation")
            print("webview redirect url: \(String(describing: webView.url))")
            print("webview title2: \(String(describing: webView.title))")
            var nowWebviewURL: String = ""
            var nowWebviewStringURL: String = ""
            if let stringURL = webView.url {
                nowWebviewStringURL = String(describing: stringURL)
                nowWebviewURL = String(describing: stringURL)
                nowWebviewURL = StringURL.removeLastSlash(url: nowWebviewURL)
                
                parent.webURL = nowWebviewURL
                parent.viewURL = StringURL.shortURL(url: nowWebviewURL)
                parent.inputURL = StringURL.removeLastSlash(url: nowWebviewStringURL)
            }
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("aaa")
            guard let title = webView.title else { return }
            print(title)
            if parent.title != title {
                parent.title = title
            }
        }
        
        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            print("############# 새창으로 웹뷰 호출")
            if navigationAction.targetFrame == nil {
                // 새 창 링크를 현재 웹뷰에서 로드
//                webView.load(navigationAction.request)
            }
            return nil
        }
    }
        
    func makeNSView(context: Context) -> WKWebView {
        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true
        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences = prefs
        
        let view = WKWebView(frame: .zero, configuration: config)
        view.navigationDelegate = context.coordinator
        view.uiDelegate = context.coordinator
        view.allowsBackForwardNavigationGestures = true
        return view
    }
    
    func updateNSView(_ webView: WKWebView, context: Context) {
        print("############# 웹뷰 업데이트 호출: update")
        print("webview url: \(String(describing: webView.url))")
        print("webview site url: \(webURL)")
        print("input url: \(inputURL )")
        
        var nowWebviewURL: String = ""
        var nowWebviewStringURL: String = ""
        if let stringURL = webView.url {
            nowWebviewStringURL = String(describing: stringURL)
            nowWebviewURL = String(describing: stringURL)
            nowWebviewURL = StringURL.shortURL(url: nowWebviewURL)
        }
        
        let stateURL: String = StringURL.shortURL(url: webURL)
        
        print("nowWebviewURL: \(nowWebviewURL)")
        print("stateURL: \(stateURL)")
        
        if(stateURL == nowWebviewURL) {
            if StringURL.shortURL(url: viewURL) != stateURL {
                viewURL = stateURL
            }
            print("return")
            return
        }
        
        if nowWebviewStringURL != "" {
            if goToPage {
                webView.load(URLRequest(url: URL(string: webURL)!))
                goToPage = false
            } else {
                webView.load(URLRequest(url: URL(string: nowWebviewStringURL)!))
            }
        } else {
            webView.load(URLRequest(url: URL(string: webURL)!))
        }
    }
    
}
