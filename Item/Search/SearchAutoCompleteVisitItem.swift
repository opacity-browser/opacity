//
//  SearchAutoCompleteVisitItem.swift
//  Opacity
//
//  Created by Falsy on 3/25/24.
//

import SwiftUI

struct SearchAutoCompleteVisitItem: View {
  @ObservedObject var browser: Browser
  @ObservedObject var tab: Tab
  var visitHistoryGroup: VisitHistoryGroup
  var isActive: Bool
  
  @State var isHover: Bool = false
  @State var isDeleteHover: Bool = false
  
  var body: some View {
    VStack(spacing: 0) {
      HStack(spacing: 0) {
        if let faviconData = visitHistoryGroup.faviconData, let nsImage = NSImage(data: faviconData) {
          VStack(spacing: 0) {
            Image(nsImage: nsImage)
              .resizable()
              .aspectRatio(contentMode: .fill)
              .frame(maxWidth: 14, maxHeight: 14)
              .clipShape(RoundedRectangle(cornerRadius: 4))
              .clipped()
          }
          .frame(maxWidth: 26, maxHeight: 26)
          .padding(.leading, 8)
        } else {
          VStack(spacing: 0) {
            Image(systemName: "globe")
              .frame(maxWidth: 14, maxHeight: 14)
              .font(.system(size: 13))
              .foregroundColor(Color("Point"))
          }
          .frame(maxWidth: 26, maxHeight: 26)
          .padding(.leading, 8)
        }
        Text(visitHistoryGroup.title != nil ? "\(visitHistoryGroup.title!) \u{00B7} " : "")
          .font(.system(size: 12.5))
          .padding(.leading, 5)
          .lineLimit(1)
          .truncationMode(.tail)
          
        Text(visitHistoryGroup.url)
          .font(.system(size: 12.5))
          .foregroundColor(Color("Point"))
          .lineLimit(1)
          .truncationMode(.tail)
          .opacity(0.8)
        Spacer()
        VStack(spacing: 0) {
          VStack(spacing: 0) {
            Image(systemName: "xmark")
              .foregroundColor(Color("Icon"))
              .font(.system(size: 12))
              .fontWeight(.regular)
          }
          .frame(maxWidth: 22, maxHeight: 22)
          .background(isDeleteHover ? .gray.opacity(0.2) : .gray.opacity(0))
          .clipShape(RoundedRectangle(cornerRadius: 6))
          .onHover { inside in
            withAnimation {
              isDeleteHover = inside
            }
          }
          .onTapGesture {
            VisitManager.deleteVisitHistoryGroup(visitHistoryGroup)
            tab.autoCompleteVisitList = tab.autoCompleteVisitList.filter {
              $0.id != visitHistoryGroup.id
            }
            if isActive {
              tab.autoCompleteIndex = nil
            }
          }
        }
        .padding(.trailing, 11)
      }
      .frame(height: 30)
    }
    .onHover { hovering in
      withAnimation {
        isHover = hovering
      }
    }
    .background(Color("AutoCompleteHover").opacity(isActive ? 0.8 : isHover ? 0.7 : 0))
    .onTapGesture {
      tab.searchInSearchBar(visitHistoryGroup.url)
    }
  }
}
