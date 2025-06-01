//
//  FavoriteItem.swift
//  Opacity
//
//  Created by Falsy on 6/1/25.
//

import SwiftUI

struct FavoriteItemView: View {
  @ObservedObject var browser: Browser
  @ObservedObject var tab: Tab
  let favorite: Favorite
  @Binding var editingFavorite: Favorite?
  @Binding var showEditDialog: Bool
  @Binding var showContextMenu: Favorite?
  
  @State private var isHovered = false
  @State private var showMenu = false
  @State private var isButtonHovered = false
  
  var body: some View {
    VStack(spacing: 8) {
      // 아이콘
      Circle()
        .fill(Color("FavoriteBG").opacity(0.85))
        .frame(width: 32, height: 32)
        .overlay(
          Text(String(favorite.title.prefix(1).uppercased()))
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(Color("FavoriteText"))
        )
      
      // 제목
      Text(favorite.title)
        .font(.system(size: 14))
        .foregroundColor(Color("UIText"))
        .lineLimit(1)
        .truncationMode(.tail)
        .frame(height: 16)
        .padding(.horizontal, 8)
    }
    .frame(width: 112, height: 112)
    .background(
      // 배경 영역
      RoundedRectangle(cornerRadius: 10)
        .fill(Color("UIText").opacity(isHovered ? 0.06 : 0.03))
    )
    .overlay(
      // ... 메뉴 버튼
      VStack {
        HStack {
          Spacer()
          
          Rectangle()
            .fill(Color.clear)
            .frame(width: 28, height: 28)
            .overlay(
              Group {
                if isHovered {
                  Button(action: {
                    showMenu = true
                    tab.isEditSearch = false
                  }) {
                    Image(systemName: "ellipsis")
                      .font(.system(size: 12, weight: .medium))
                      .foregroundColor(Color("UIText").opacity(0.6))
                      .frame(width: 26, height: 26)
                      .rotationEffect(.degrees(90))
                      .background(
                        Circle()
                          .fill(Color("UIText").opacity(isButtonHovered ? 0.1 : 0))
                      )
                  }
                  .buttonStyle(.plain)
                  .onHover { hovering in
                    withAnimation(.easeInOut(duration: 0.2)) {
                      isButtonHovered = hovering
                    }
                  }
                }
              }
            )
            .popover(isPresented: $showMenu, arrowEdge: .top) {
              FavoriteContextMenu(
                favorite: favorite,
                editingFavorite: $editingFavorite,
                showEditDialog: $showEditDialog,
                showMenu: $showMenu
              )
            }
        }
        .padding(.top, 4)
        .padding(.trailing, 4)
        
        Spacer()
      }
    )
    .onHover { hovering in
      withAnimation(.easeInOut(duration: 0.2)) {
        isHovered = hovering
      }
    }
    .onTapGesture {
      // 즐겨찾기 클릭 시 해당 URL로 이동
      var urlString = favorite.address
      if !urlString.hasPrefix("http://") && !urlString.hasPrefix("https://") {
        urlString = "https://\(urlString)"
      }
      
      if let url = URL(string: urlString) {
        if tab.isInit {
          tab.updateURLBySearch(url: url)
        } else {
          browser.newTab(url)
        }
      }
    }
  }
}
