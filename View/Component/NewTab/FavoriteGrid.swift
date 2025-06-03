//
//  FavoriteGrid.swift
//  Opacity
//
//  Created by Falsy on 6/1/25.
//

import SwiftUI
import SwiftData

struct FavoriteGrid: View {
  let favorites: [Favorite]
  @ObservedObject var browser: Browser
  @ObservedObject var tab: Tab
  @Binding var editingFavorite: Favorite?
  @Binding var showEditDialog: Bool
  @Binding var showContextMenu: Favorite?
  let maxFavorites: Int
  let containerWidth: CGFloat
  
  // 윈도우 크기에 따라 레이아웃 결정
  private var shouldUseDoubleRow: Bool {
    // 윈도우 너비가 900px 미만이면 2행 3열로 변경
    containerWidth < 900
  }
  
  private var columns: Int {
    shouldUseDoubleRow ? 3 : 6
  }
  
  private var itemSpacing: CGFloat {
    shouldUseDoubleRow ? 24 : 18
  }
  
  var body: some View {
    HStack(spacing: 20) {
      Spacer()
      if shouldUseDoubleRow {
        // 2행 3열 레이아웃
        VStack {
          // 첫 번째 행
          HStack(spacing: itemSpacing) {
            ForEach(0..<3, id: \.self) { index in
              if index < favorites.count {
                FavoriteItemView(
                  browser: browser,
                  tab: tab,
                  favorite: favorites[index],
                  editingFavorite: $editingFavorite,
                  showEditDialog: $showEditDialog,
                  showContextMenu: $showContextMenu
                )
              } else if index == favorites.count && favorites.count < maxFavorites {
                AddFavoriteButton(showEditDialog: $showEditDialog, editingFavorite: $editingFavorite)
              } else {
                EmptyFavoriteSlot()
              }
            }
          }
          
          // 두 번째 행 (필요한 경우에만)
          if favorites.count > 3 || (favorites.count == 3 && favorites.count < maxFavorites) {
            HStack(spacing: itemSpacing) {
              ForEach(0..<3, id: \.self) { index in
                let favoriteIndex = index + 3
                if favoriteIndex < favorites.count {
                  FavoriteItemView(
                    browser: browser,
                    tab: tab,
                    favorite: favorites[favoriteIndex],
                    editingFavorite: $editingFavorite,
                    showEditDialog: $showEditDialog,
                    showContextMenu: $showContextMenu
                  )
                } else if favoriteIndex == favorites.count && favorites.count < maxFavorites {
                  AddFavoriteButton(showEditDialog: $showEditDialog, editingFavorite: $editingFavorite)
                } else {
                  EmptyFavoriteSlot()
                }
              }
            }
          }
        }
      } else {
        // 1행 6열 레이아웃
        HStack(spacing: itemSpacing) {
          Spacer()
          ForEach(0..<6, id: \.self) { index in
            if index < favorites.count {
              FavoriteItemView(
                browser: browser,
                tab: tab,
                favorite: favorites[index],
                editingFavorite: $editingFavorite,
                showEditDialog: $showEditDialog,
                showContextMenu: $showContextMenu
              )
            } else if index == favorites.count && favorites.count < maxFavorites {
              AddFavoriteButton(showEditDialog: $showEditDialog, editingFavorite: $editingFavorite)
            } else {
              EmptyFavoriteSlot()
            }
          }
          Spacer()
        }
      }
      Spacer()
    }
  }
}
