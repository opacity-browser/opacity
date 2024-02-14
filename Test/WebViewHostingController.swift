//
//  WebViewHostingController.swift
//  FriedEgg
//
//  Created by Falsy on 2/13/24.
//

import SwiftUI
import WebKit

// WKWebView를 관리하는 NSViewController
class WebViewHostingController: NSViewController {
    var webView: WKWebView?
    
    override func loadView() {
        self.view = NSView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let webView = webView {
            webView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(webView)
            
            NSLayoutConstraint.activate([
                webView.topAnchor.constraint(equalTo: view.topAnchor),
                webView.leftAnchor.constraint(equalTo: view.leftAnchor),
                webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                webView.rightAnchor.constraint(equalTo: view.rightAnchor)
            ])
        }
    }
}

// NSViewControllerRepresentable 구현
struct WebViewWrapper: NSViewControllerRepresentable {
    let webView: WKWebView
    
    func makeNSViewController(context: Context) -> WebViewHostingController {
        let viewController = WebViewHostingController()
        viewController.webView = webView
        return viewController
    }
    
    func updateNSViewController(_ nsViewController: WebViewHostingController, context: Context) {
        // 뷰 컨트롤러 업데이트 로직 (필요한 경우)
    }
}
