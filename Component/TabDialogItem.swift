//
//  TabDialogItem.swift
//  Opacity
//
//  Created by Falsy on 2/16/24.
//

import SwiftUI

struct TabDialogItem: View {
  @ObservedObject var browser: Browser
  @ObservedObject var tab: Tab
  @Binding var activeTabId: UUID?
  
  @State private var isTabHover: Bool = false
  
  var body: some View {
    VStack(spacing: 0) {
      VStack(spacing: 0) {
        VStack(spacing: 0) {
          HStack(spacing: 0) {
            if let favicon = tab.favicon {
              HStack(spacing: 0) {
                VStack(spacing: 0) {
                  favicon
                    .resizable() // 이미지 크기 조절 가능하게 함
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: 14, maxHeight: 14)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .clipped()
                }
              }
              .frame(maxWidth: 14, maxHeight: 20, alignment: .center)
              .padding(.leading, 6)
            }
            Text(tab.title)
              .frame(height: 22, alignment: .leading)
              .foregroundColor(Color("UIText"))
              .font(.system(size: 12))
              .padding(.leading, tab.favicon == nil ? 7 : 4)
              .padding(.trailing, 7)
              .lineLimit(1)
              .truncationMode(.tail)
            Spacer()
          }
          .frame(height: 22, alignment: .leading)
          
          HStack(spacing: 0) {
            Text(tab.originURL.absoluteString)
              .font(.system(size: 11))
              .padding(.leading, 7)
              .padding(.trailing, 7)
              .lineLimit(1)
              .truncationMode(.tail)
            Spacer()
          }
        }
        .onHover { hovering in
          isTabHover = hovering
        }
      }
      .padding(5)
      .padding(.bottom, 4)
      .background(Color("SearchBarBG").opacity(tab.id == activeTabId ? 1 : isTabHover ? 0.5 : 0))
      .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    .frame(width: 230, alignment: .leading)
    .padding(.horizontal, 10)
    .padding(.top, 5)
  }
}
