//
//  ZoomDialog.swift
//  Opacity
//
//  Created by Falsy on 5/10/24.
//

import SwiftUI

struct ZoomDialog: View {
  @ObservedObject var tab: Tab
  
  @State private var isHobverPlus: Bool = false
  @State private var isHobverMinus: Bool = false
  @State private var isHobverClose: Bool = false
  
  var body: some View {
    VStack(spacing: 0) {
      VStack(spacing: 0) {
        HStack(spacing: 0) {
          Text("\(Int(tab.zoomLevel *  100))%")
            .font(.system(size: 12))
            .padding(.leading, 5)
          Spacer()
          VStack(spacing: 0) {
            Image(systemName: "plus")
              .frame(maxWidth: 14, maxHeight: 14)
              .font(.system(size: 13))
              .foregroundColor(Color("Icon"))
          }
          .frame(width: 22, height: 22)
          .background(isHobverPlus ? .gray.opacity(0.2) : .gray.opacity(0))
          .clipShape(RoundedRectangle(cornerRadius: 6))
          .onHover { hover in
            withAnimation {
              isHobverPlus = hover
            }
          }
          .onTapGesture {
            tab.zoomLevel = ((tab.zoomLevel * 10) + 1) / 10
          }
          .padding(.leading, 5)
          VStack(spacing: 0) {
            Image(systemName: "minus")
              .frame(maxWidth: 14, maxHeight: 14)
              .font(.system(size: 13))
              .foregroundColor(Color("Icon"))
          }
          .frame(width: 22, height: 22)
          .background(isHobverMinus ? .gray.opacity(0.2) : .gray.opacity(0))
          .clipShape(RoundedRectangle(cornerRadius: 6))
          .onHover { hover in
            withAnimation {
              isHobverMinus = hover
            }
          }
          .onTapGesture {
            tab.zoomLevel = ((tab.zoomLevel * 10) - 1) / 10
          }
          .padding(.leading, 5)
          
        }
        .padding(5)
      }
      .padding(5)
    }
    .frame(width: 140)
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
