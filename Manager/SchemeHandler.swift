//
//  SchemeHandler.swift
//  Opacity
//
//  Created by Falsy on 1/24/24.
//

import WebKit

class SchemeHandler: NSObject, WKURLSchemeHandler {
  private func mimeTypeForPath(path: String) -> String {
    let url = URL(fileURLWithPath: path)
    let pathExtension = url.pathExtension
    
    switch pathExtension.lowercased() {
    case "html":
      return "text/html"
    case "js":
      return "application/javascript"
    case "png":
        return "image/png"
    case "jpg", "jpeg":
        return "image/jpeg"
    case "avif":
        return "image/avif"
    default:
      return "application/octet-stream"
    }
  }
  
  func appendIndexHtmlNeeded(_ url: URL) -> URL {
    let lastPathComponent = url.lastPathComponent
    let fileExtension = lastPathComponent.components(separatedBy: ".").last
    if fileExtension == nil || fileExtension!.isEmpty {
      var newPath = url.absoluteString
      if !newPath.hasSuffix("/") {
        newPath += "/"
      }
      newPath += "index.html"
      
      return URL(string: newPath) ?? url
    }
    return url
  }
  
  func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
    guard let requestUrl = urlSchemeTask.request.url,
        let host = requestUrl.host,
        let scheme = requestUrl.scheme,
        scheme == "opacity",
        let resourcePath = Bundle.main.resourcePath else {
      urlSchemeTask.didFailWithError(NSError(domain: "Invalid URL or Scheme", code: 404, userInfo: nil))
      return
    }
    
    let url = appendIndexHtmlNeeded(requestUrl)
    let filePath = host + "/" + url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
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
