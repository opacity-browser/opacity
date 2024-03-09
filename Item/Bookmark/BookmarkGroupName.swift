////
////  BookmarkGroupName.swift
////  Opacity
////
////  Created by Falsy on 3/7/24.
////
//
//import SwiftUI
//
//struct BookmarkGroupName: View {
//  @Environment(\.modelContext) var modelContext
//  
//  @Binding var name: String
//  var group: BookmarkGroup
//  @FocusState private var isTextFieldFocused: Bool
//  @State private var isEditName: Bool = false
//  
//  var body: some View {
//    VStack(spacing: 0) {
//      HStack(spacing: 0) {
//        
//        VStack(spacing: 0) {
//          Image(systemName: "folder")
//            .foregroundColor(Color("Icon"))
//            .font(.system(size: 13))
//            .fontWeight(.regular)
//        }
//        .frame(maxWidth: 24, maxHeight: 24)
//        
//        if isEditName {
//          TextField(NSLocalizedString("New Folder", comment: ""), text: $name, onEditingChanged: { isEdit in
//            if !isEdit {
//              isEditName = false
//            }
//          })
//          .frame(height: 30)
//          .font(.system(size: 13))
//          .focused($isTextFieldFocused)
//          .textFieldStyle(.plain)
//          .onSubmit {
//            isTextFieldFocused = false
//            isEditName = false
//          }
//        } else {
//          Text(name)
//            .font(.system(size: 13))
//            .frame(height: 30)
//            .contextMenu {
//              Button(NSLocalizedString("Change Name", comment: "")) {
//                isTextFieldFocused = true
//                isEditName = true
//              }
//              Divider()
//              Button(NSLocalizedString("Delete", comment: "")) {
////                modelContext.delete(group)
//                
////                do {
////                  try modelContext.save()
////                } catch {
////                  print("delete error")
////                }
//              }
//              Divider()
//              Button(NSLocalizedString("Add Folder", comment: "")) {
////                let newBookmarkGroup = BookmarkGroup(parentGroupId: group.id)
////                group.groups.append(newBookmarkGroup)
//              }
//            }
//        }
//        
//        Spacer()
//      }
//      .padding(0)
//      .frame(maxWidth: .infinity)
//      .background(.blue.opacity(0.2))
//    }
//  }
//}
