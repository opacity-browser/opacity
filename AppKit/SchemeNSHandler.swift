//
//  SchemeHandler.swift
//  Opacity
//
//  Created by Falsy on 1/24/24.
//

import WebKit

//class SchemeNSHandler: NSObject, WKURLSchemeHandler {
//  func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
//    if let url = urlSchemeTask.request.url,
//      let path = Bundle.main.path(forResource: url.host, ofType: "html"),
//      let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
//        let response = URLResponse(url: url, mimeType: "text/html", expectedContentLength: data.count, textEncodingName: nil)
//        urlSchemeTask.didReceive(response)
//        urlSchemeTask.didReceive(data)
//        urlSchemeTask.didFinish()
//    } else {
//      urlSchemeTask.didFailWithError(NSError(domain: "CustomErrorDomain", code: 404, userInfo: nil))
//    }
//  }
//    
//  func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
//  }
//}

class SchemeNSHandler: NSObject, WKURLSchemeHandler {
  private func mimeTypeForPath(path: String) -> String {
    let url = URL(fileURLWithPath: path)
    let pathExtension = url.pathExtension
    
    switch pathExtension.lowercased() {
    case "html":
      return "text/html"
    case "js":
      return "application/javascript"
    default:
      return "application/octet-stream"
    }
  }
  
  func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
    guard let url = urlSchemeTask.request.url,
        let scheme = url.scheme,
        scheme == "opacity",
        let resourcePath = Bundle.main.resourcePath else {
      urlSchemeTask.didFailWithError(NSError(domain: "Invalid URL or Scheme", code: 404, userInfo: nil))
      return
    }
    
    let filePath = url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
    let fullPath = (resourcePath as NSString).appendingPathComponent(filePath)
    
    if FileManager.default.fileExists(atPath: fullPath) {
      do {
        let data = try Data(contentsOf: URL(fileURLWithPath: fullPath))
        let mimeType = mimeTypeForPath(path: fullPath)
        let response = URLResponse(url: url, mimeType: mimeType, expectedContentLength: data.count, textEncodingName: nil)
        
        urlSchemeTask.didReceive(response)
        urlSchemeTask.didReceive(data)
        urlSchemeTask.didFinish()
      } catch {
        urlSchemeTask.didFailWithError(error)
      }
    } else {
      urlSchemeTask.didFailWithError(NSError(domain: "File Not Found", code: 404, userInfo: nil))
    }
  }
  
  func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
  }
}
