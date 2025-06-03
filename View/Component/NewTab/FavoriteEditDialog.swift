//
//  FavoriteEditDialog.swift
//  Opacity
//
//  Created by Falsy on 6/1/25.
//

import SwiftUI
import SwiftData

struct FavoriteEditDialog: View {
  @Query var favorites: [Favorite]
  @Environment(\.modelContext) var modelContext
  
  @Binding var isPresented: Bool
  @Binding var editingFavorite: Favorite?
  
  @State private var title: String = ""
  @State private var address: String = ""
  @FocusState private var isTitleFocused: Bool
  
  var body: some View {
    VStack(spacing: 0) {
      // 제목
      HStack {
        Text(editingFavorite != nil ? NSLocalizedString("Edit Favorite", comment: "") : NSLocalizedString("Add Favorite", comment: ""))
          .font(.system(size: 14, weight: .semibold))
          .foregroundColor(Color("UIText"))
        Spacer()
      }
      .padding(.bottom, 20)
      
      // 제목 입력
      VStack(alignment: .leading, spacing: 8) {
        Text(NSLocalizedString("Title", comment: ""))
          .font(.system(size: 12))
          .foregroundColor(Color("UIText"))
        
        TextField("", text: $title)
          .textFieldStyle(.plain)
          .padding(.horizontal, 8)
          .padding(.vertical, 6)
          .background(Color("SearchBarBG"))
          .cornerRadius(4)
          .focused($isTitleFocused)
      }
      .padding(.bottom, 12)
      
      // 주소 입력
      VStack(alignment: .leading, spacing: 8) {
        Text(NSLocalizedString("Address", comment: ""))
          .font(.system(size: 12))
          .foregroundColor(Color("UIText"))
        
        TextField("", text: $address)
          .textFieldStyle(.plain)
          .padding(.horizontal, 8)
          .padding(.vertical, 6)
          .background(Color("SearchBarBG"))
          .cornerRadius(4)
      }
      .padding(.bottom, 20)
      
      // 버튼들
      HStack(spacing: 12) {
        Button(NSLocalizedString("Cancel", comment: "")) {
          closeDialog()
        }
        .buttonStyle(CancelButtonStyle())
        
        Button(NSLocalizedString("Save", comment: "")) {
          saveFavorite()
        }
        .buttonStyle(SaveButtonStyle())
      }
    }
    .padding(20)
    .frame(width: 320)
    .background(Color("DialogBG"))
    .cornerRadius(8)
    .shadow(color: .black.opacity(0.2), radius: 10)
    .onAppear {
      if let favorite = editingFavorite {
        title = favorite.title
        address = favorite.address
      }
      
      // 다이얼로그가 나타날 때 타이틀 필드에 포커스
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        isTitleFocused = true
      }
    }
  }
  
  private func closeDialog() {
    isPresented = false
    editingFavorite = nil
    title = ""
    address = ""
  }
  
  private func saveFavorite() {
    guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
          !address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
      return
    }
    
    if let favorite = editingFavorite {
      // 편집
      favorite.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
      favorite.address = address.trimmingCharacters(in: .whitespacesAndNewlines)
    } else {
      // 새로 추가
      let newFavorite = Favorite(
        title: title.trimmingCharacters(in: .whitespacesAndNewlines),
        address: address.trimmingCharacters(in: .whitespacesAndNewlines)
      )
      modelContext.insert(newFavorite)
    }
    
    closeDialog()
  }
}
