//
//  SSLCertificateCoordinator.swift
//  Opacity
//
//  Created by Falsy on 5/24/25.
//

import SwiftUI
import Security
import ASN1Decoder

class SSLCertificateCoordinator: NSObject, URLSessionDelegate {
  var parent: MainWebView!
  private var URLSessionHost: String = ""
  private var cacheIsValidCertificate: Bool = false
  private var cacheCertificateSummary: String = ""
  
  init(parent: MainWebView) {
    self.parent = parent
    super.init()
  }
  
  func checkedSSLCertificate(url: URL) {
    DispatchQueue.main.async {
      self.parent.tab.certificateSummary = ""
      self.parent.tab.isValidCertificate = nil
    }
    
    cacheIsValidCertificate = false
    cacheCertificateSummary = ""
    
    if url.scheme == "opacity" {
      return
    }
    
    if let host = url.host {
      URLSessionHost = host
    }
          
    let config = URLSessionConfiguration.default
    config.requestCachePolicy = .reloadIgnoringLocalCacheData
    config.urlCache = nil
    let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
    let request = URLRequest(url: url)
    let task = session.dataTask(with: request) { data, response, error in
      if error != nil {
        print("Error: \(error!.localizedDescription)")
      }
      DispatchQueue.main.async {
        self.parent.tab.certificateSummary = self.cacheCertificateSummary
        self.parent.tab.isValidCertificate = self.cacheIsValidCertificate
      }
      session.finishTasksAndInvalidate()
    }
    task.resume()
  }
  
  private func matchesDomain(pattern: String, host: String) -> Bool {
    if pattern == host {
      return true
    }
    if pattern.hasPrefix("*.") {
      let basePattern = pattern.dropFirst(2)
      let hostParts = host.split(separator: ".")
      let patternParts = basePattern.split(separator: ".")
      if hostParts.count == patternParts.count + 1 {
        return Array(hostParts.suffix(patternParts.count)) == patternParts
      }
    }
    return false
  }
  
  private func matchesHostCertificate(certificate: SecCertificate, host: String) throws -> String? {
    let data = SecCertificateCopyData(certificate) as Data
    let x509 = try X509Certificate(data: data)
    if let cn = x509.subjectDistinguishedName {
      for pattern in x509.subjectAlternativeNames {
        if matchesDomain(pattern: pattern, host: host) {
          return cn
        }
      }
    }
    return nil
  }
  
  // MARK: - URLSessionDelegate
  func urlSession(
    _ session: URLSession,
    didReceive challenge: URLAuthenticationChallenge,
    completionHandler: @escaping @Sendable (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
  ) {
    guard let serverTrust = challenge.protectionSpace.serverTrust else {
      completionHandler(.cancelAuthenticationChallenge, nil)
      return
    }
    
    var error: CFError?
    let isValid = SecTrustEvaluateWithError(serverTrust, &error)
    
    if isValid, let certificateChain = SecTrustCopyCertificateChain(serverTrust) as? [SecCertificate] {
      for certificate in certificateChain {
        if let _ = try? matchesHostCertificate(certificate: certificate, host: URLSessionHost) {
          cacheIsValidCertificate = true
          cacheCertificateSummary = SecCertificateCopySubjectSummary(certificate) as String? ?? "Unknown"
        }
      }
      completionHandler(.useCredential, URLCredential(trust: serverTrust))
    } else {
      completionHandler(.cancelAuthenticationChallenge, nil)
    }
  }
}
