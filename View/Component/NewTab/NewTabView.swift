//
//  NewTabView.swift
//  Opacity
//
//  Created by Falsy on 6/1/25.
//

import SwiftUI
import SwiftData

struct NewTabView: View {
  @Query(sort: \Favorite.createDate, order: .forward) var favorites: [Favorite]
  @Environment(\.modelContext) var modelContext
  
  @ObservedObject var browser: Browser
  @ObservedObject var tab: Tab
  
  @State private var showEditDialog = false
  @State private var editingFavorite: Favorite?
  @State private var showContextMenu: Favorite?
  
  private let maxFavorites = 6
  
  var body: some View {
    ZStack {
      // 배경
      Color("SearchBarBG")
        .ignoresSafeArea()
      
      GeometryReader { geometry in
        VStack(spacing: 0) {
          Spacer()
          
          // 로고
          Image("MainLogo")
            .resizable()
            .frame(width: 80, height: 80)
          
          Spacer()
            .frame(height: 80)
          
          // 반응형 즐겨찾기 그리드
          FavoriteGrid(
            favorites: favorites,
            browser: browser,
            tab: tab,
            editingFavorite: $editingFavorite,
            showEditDialog: $showEditDialog,
            showContextMenu: $showContextMenu,
            maxFavorites: maxFavorites,
            containerWidth: geometry.size.width
          )
          
          Spacer()
        }
      }
    }
    .overlay(
      // 편집 다이얼로그
      Group {
        if showEditDialog {
          Color.black.opacity(0.3)
            .ignoresSafeArea()
            .onTapGesture {
              showEditDialog = false
              editingFavorite = nil
            }
          
          FavoriteEditDialog(
            isPresented: $showEditDialog,
            editingFavorite: $editingFavorite
          )
        }
      }
    )
  }
}
