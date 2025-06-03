//
//  FavoriteContextMenu.swift
//  Opacity
//
//  Created by Falsy on 6/1/25.
//

import SwiftUI

struct FavoriteContextMenu: View {
  let favorite: Favorite
  @Binding var editingFavorite: Favorite?
  @Binding var showEditDialog: Bool
  @Binding var showMenu: Bool
  
  @State private var isEditHover: Bool = false
  @State private var isDeleteHover: Bool = false
  
  var body: some View {
    VStack(spacing: 0) {
      VStack(spacing: 0) {
        
        HStack(spacing: 0) {
          Text(NSLocalizedString("Edit", comment: ""))
            .font(.system(size: 12))
            .padding(.leading, 5)
          Spacer()
        }
        .padding(5)
        .padding(.vertical, 2)
        .onHover { hovering in
          isEditHover = hovering
        }
        .background(Color("SearchBarBG").opacity(isEditHover ? 0.5 : 0))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .onTapGesture {
          DispatchQueue.main.async {
            editingFavorite = favorite
            showEditDialog = true
            showMenu = false
          }
        }
        
        Divider()
          .padding(.vertical, 4)
        
        HStack(spacing: 0) {
          Text(NSLocalizedString("Delete", comment: ""))
            .font(.system(size: 12))
            .padding(.leading, 5)
          Spacer()
        }
        .padding(5)
        .padding(.vertical, 2)
        .onHover { hovering in
          isDeleteHover = hovering
        }
        .background(Color("SearchBarBG").opacity(isDeleteHover ? 0.5 : 0))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .onTapGesture {
          DispatchQueue.main.async {
            deleteFavorite(favorite)
            showMenu = false
          }
        }
        
      }
      .padding(5)
    }
    .frame(width: 120)
    .background(GeometryReader { geometry in
      Color("DialogBG")
          .frame(width: geometry.size.width,
                  height: geometry.size.height + 100)
          .frame(width: geometry.size.width,
                  height: geometry.size.height,
                  alignment: .bottom)
    })
  }
  
  private func deleteFavorite(_ favorite: Favorite) {
    let success = FavoriteManager.deleteFavoriteById(favorite.id.uuidString)
    if success {
      print("Favorite deleted successfully")
    }
  }
}
