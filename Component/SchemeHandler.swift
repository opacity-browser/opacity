//
//  SchemeHandler.swift
//  Opacity
//
//  Created by Falsy on 1/24/24.
//

import WebKit

class SchemeHandler: NSObject, WKURLSchemeHandler {
  func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
    if let url = urlSchemeTask.request.url,
      let path = Bundle.main.path(forResource: url.host, ofType: "html"),
      let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
        let response = URLResponse(url: url, mimeType: "text/html", expectedContentLength: data.count, textEncodingName: nil)
        urlSchemeTask.didReceive(response)
        urlSchemeTask.didReceive(data)
        urlSchemeTask.didFinish()
    } else {
      urlSchemeTask.didFailWithError(NSError(domain: "CustomErrorDomain", code: 404, userInfo: nil))
    }
  }
    
  func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
  }
}
