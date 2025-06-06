//
//  ErrorPageView.swift
//  Opacity
//
//  Created by Falsy on 6/3/25.
//

import SwiftUI

enum ErrorPageType {
  case notFindHost
  case notConnectHost
  case notConnectInternet
  case occurredSSLError
  case blockedContent
  case unknown
}

struct ErrorPageView: View {
  let errorType: ErrorPageType
  let failingURL: String
  let onRefresh: () -> Void
  
  private var errorInfo: (title: String, message: String, icon: String) {
    switch errorType {
    case .notFindHost:
      return (
        title: NSLocalizedString("Page not found", comment: ""),
        message: String(format: NSLocalizedString("The server IP address for '%@' could not be found.", comment: ""), failingURL),
        icon: "exclamationmark.triangle"
      )
    case .notConnectHost:
      return (
        title: NSLocalizedString("Unable to connect to site", comment: ""),
        message: NSLocalizedString("Connection has been reset.", comment: ""),
        icon: "network.slash"
      )
    case .notConnectInternet:
      return (
        title: NSLocalizedString("No internet connection", comment: ""),
        message: NSLocalizedString("There is no internet connection.", comment: ""),
        icon: "wifi.slash"
      )
    case .occurredSSLError:
      return (
        title: NSLocalizedString("SSL/TLS certificate error", comment: ""),
        message: NSLocalizedString("A secure connection cannot be made because the certificate is not valid.", comment: ""),
        icon: "lock.slash"
      )
    case .blockedContent:
      return (
        title: NSLocalizedString("Blocked content", comment: ""),
        message: NSLocalizedString("This content is blocked. To use the service, you must lower or turn off tracker blocking.", comment: ""),
        icon: "shield.slash"
      )
    case .unknown:
      return (
        title: NSLocalizedString("Unknown error", comment: ""),
        message: NSLocalizedString("An unknown error occurred.", comment: ""),
        icon: "exclamationmark.triangle"
      )
    }
  }
  
  var body: some View {
    VStack(spacing: 0) {
      Spacer()
      
      VStack(spacing: 24) {
        // 오류 아이콘
        Image(systemName: errorInfo.icon)
          .font(.system(size: 56, weight: .light))
          .foregroundColor(Color("Icon").opacity(1))
        
        VStack(spacing: 12) {
          // 오류 제목
          Text(errorInfo.title)
            .font(.system(size: 36, weight: .semibold))
            .foregroundColor(Color("UIText"))
            .multilineTextAlignment(.center)
          
          // 오류 메시지
          Text(errorInfo.message)
            .font(.system(size: 14))
            .foregroundColor(Color("UIText").opacity(0.6))
            .multilineTextAlignment(.center)
            .lineSpacing(4)
            .padding(.horizontal, 40)
        }
        
        // 새로고침 버튼
        Button(action: onRefresh) {
          HStack(spacing: 8) {
            Image(systemName: "arrow.clockwise")
              .font(.system(size: 14, weight: .medium))
            Text(NSLocalizedString("Refresh", comment: ""))
              .font(.system(size: 14, weight: .medium))
          }
          .foregroundColor(Color("ButtonText"))
          .padding(.horizontal, 24)
          .padding(.vertical, 10)
          .background(Color("ButtonBG"))
          .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
        .onHover { isHover in
          // 호버 효과를 원한다면 여기에 추가
        }
        .padding(.top, 12)
        
        // URL 정보 (선택사항)
        if !failingURL.isEmpty {
          Text(failingURL)
            .font(.custom("SF Mono", size: 12))
            .foregroundColor(Color("UIText").opacity(0.3))
            .padding(.horizontal, 40)
            .multilineTextAlignment(.center)
            .lineLimit(2)
        }
      }
      
      Spacer()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color("SearchBarBG"))
  }
}
