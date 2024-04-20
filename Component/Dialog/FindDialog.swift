//
//  FindDialog.swift
//  Opacity
//
//  Created by Falsy on 4/20/24.
//

import SwiftUI

struct FindDialog: View {
  @ObservedObject var tab: Tab
  
  @State private var isHobverPrev: Bool = false
  @State private var isHobverNext: Bool = false
  @State private var isHobverClose: Bool = false
  
  var body: some View {
    VStack(spacing: 0) {
      VStack(spacing: 0) {
        HStack(spacing: 0) {
          FindNSTextField(tab: tab)
          Spacer()
          VStack(spacing: 0) {
            Image(systemName: "chevron.up")
              .frame(maxWidth: 14, maxHeight: 14)
              .font(.system(size: 13))
              .foregroundColor(Color("Icon"))
          }
          .frame(width: 22, height: 22)
          .background(isHobverPrev ? .gray.opacity(0.2) : .gray.opacity(0))
          .clipShape(RoundedRectangle(cornerRadius: 6))
          .onHover { inside in
            withAnimation {
              isHobverPrev = inside
            }
          }
          .onTapGesture {
            if tab.findKeyword.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
              return
            }
            AppDelegate.shared.findKeywordPrev()
          }
          .padding(.leading, 5)
          VStack(spacing: 0) {
            Image(systemName: "chevron.down")
              .frame(maxWidth: 14, maxHeight: 14)
              .font(.system(size: 13))
              .foregroundColor(Color("Icon"))
          }
          .frame(width: 22, height: 22)
          .background(isHobverNext ? .gray.opacity(0.2) : .gray.opacity(0))
          .clipShape(RoundedRectangle(cornerRadius: 6))
          .onHover { inside in
            withAnimation {
              isHobverNext = inside
            }
          }
          .onTapGesture {
            if tab.findKeyword.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
              return
            }
            AppDelegate.shared.findKeywordNext()
          }
          .padding(.leading, 5)
          VStack(spacing: 0) {
            Image(systemName: "xmark")
              .frame(maxWidth: 14, maxHeight: 14)
              .font(.system(size: 13))
              .foregroundColor(Color("Icon"))
          }
          .frame(width: 22, height: 22)
          .background(isHobverClose ? .gray.opacity(0.2) : .gray.opacity(0))
          .clipShape(RoundedRectangle(cornerRadius: 6))
          .onHover { inside in
            withAnimation {
              isHobverClose = inside
            }
          }
          .onTapGesture {
            tab.isFindDialog = false
          }
          .padding(.leading, 5)
        }
        .padding(5)
      }
      .padding(10)
    }
    .frame(width: 240)
    .background(GeometryReader { geometry in
      Color("DialogBG")
        .frame(width: geometry.size.width,
               height: geometry.size.height + 100)
        .frame(width: geometry.size.width,
               height: geometry.size.height,
               alignment: .bottom)
    })
  }
}
