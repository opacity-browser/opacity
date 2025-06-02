//
//  BookmarkFolderDropdown.swift
//  Opacity
//
//  Created by Falsy on 6/3/25.
//

import SwiftUI

struct BookmarkFolderDropdown: View {
  @Binding var selectedId: UUID?
  let bookmarkGroups: [BookmarkGroup]
  
  private var sortedGroups: [BookmarkGroup] {
    bookmarkGroups
      .sorted { $0.index < $1.index }
      .sorted { $0.depth < $1.depth }
  }
  
  private var selectedGroupName: String {
    guard let selectedId = selectedId,
          let group = bookmarkGroups.first(where: { $0.id == selectedId }) else {
      return "----"
    }
    
    return group.name
  }
  
  var body: some View {
    Menu {
      ForEach(sortedGroups, id: \.id) { group in
        Button {
          selectedId = group.id
        } label: {
          HStack {
            Text(group.name)
            
            if selectedId == group.id {
              Spacer()
              Image(systemName: "checkmark")
                .foregroundColor(Color("Point"))
            }
          }
        }
      }
    } label: {
      HStack(spacing: 0) {
        Text(selectedGroupName)
          .font(.system(size: 12))
          .foregroundColor(Color("UIText"))
          .lineLimit(1)
          .truncationMode(.tail)
        
        Spacer()
        
        Image(systemName: "chevron.up.chevron.down")
          .font(.system(size: 10))
          .foregroundColor(Color("Icon"))
      }
      .padding(.horizontal, 8)
      .padding(.vertical, 6)
      .background(
        RoundedRectangle(cornerRadius: 4)
          .fill(Color("SearchBarBG"))
          .stroke(Color("UIBorder"), lineWidth: 0.5)
      )
    }
    .buttonStyle(.plain)
  }
}
