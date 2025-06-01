//
//  AddFavoriteButton.swift
//  Opacity
//
//  Created by Falsy on 6/1/25.
//

import  SwiftUI

struct AddFavoriteButton: View {
  @Binding var showEditDialog: Bool
  @Binding var editingFavorite: Favorite?
  
  @State private var isHovered = false
  
  var body: some View {
    VStack(spacing: 8) {
      Button(action: {
        editingFavorite = nil
        showEditDialog = true
      }) {
        Image(systemName: "plus")
          .font(.system(size: 18))
          .foregroundColor(Color("UIText").opacity(0.8))
          .frame(width: 112, height: 112)
          .background(
            // 배경 영역
            RoundedRectangle(cornerRadius: 10)
              .fill(Color("UIText").opacity(isHovered ? 0.06 : 0.03))
          )
      }
      .buttonStyle(.plain)
    }
    .onHover { hovering in
      withAnimation(.easeInOut(duration: 0.2)) {
        isHovered = hovering
      }
    }
  }
}

