//
//  WebView.swift
//  FriedEgg
//
//  Created by Falsy on 2/13/24.
//

import SwiftUI
import WebKit

struct WebView: NSViewRepresentable {
    var webView: WKWebView
    
    func makeNSView(context: Context) -> WKWebView {
        return webView
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {
        // 여기에서 필요한 경우 웹뷰를 업데이트합니다.
    }
}
