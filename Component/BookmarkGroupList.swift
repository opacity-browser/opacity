////
////  BookmarkList.swift
////  Opacity
////
////  Created by Falsy on 3/7/24.
////
//
//import SwiftUI
//
//struct BookmarkGroupList: View {
//  var bookmarkGroups: [BookmarkGroup]
//
//  var body: some View {
//    VStack(spacing: 0) {
//      ForEach(bookmarkGroups) { targetGroup in
//        VStack(spacing: 0) {
//          ExpandList(title: {
//            HStack(spacing: 0) {
//              BookmarkGroupName(name: Bindable(targetGroup).name, group: targetGroup)
//            }
//          }, content: {
//            HStack(spacing: 0) {
//              BookmarkGroupList(bookmarkGroups: targetGroup.groups)
////              BookmarkGroupList(parentGroupId: targetGroup.id, depth: depth + 1)
//            }
////            HStack(spacing: 0) {
////              BookmarkList(bookmarks: targetGroup.bookmarks)
////            }
//          })
//        }
//        .frame(maxWidth: .infinity)
//        .padding(.leading, 10)
//        .background(.red.opacity(0.1))
//      }
//    }
//  }
//}
