//
//  BookmarkList.swift
//  Opacity
//
//  Created by Falsy on 3/7/24.
//

import SwiftUI
import SwiftData

struct BookmarkList: View {
  @Environment(\.modelContext) var modelContext
  @Query var allBookmarks: [Bookmark]
  @Query(filter: #Predicate<Bookmark> {
    $0.parent == nil
  }) var bookmarks: [Bookmark]
  
  func deleteBookmark(_ target: Bookmark) {
    if let childBookmark = target.children {
      for childTarget in childBookmark {
        deleteBookmark(childTarget)
      }
      modelContext.delete(target)
    }
  }
  
  var body: some View {
    VStack {
      OutlineGroup(bookmarks, children: \.children) { bookmark in
        Text(bookmark.title)
          .contextMenu {
            Button(NSLocalizedString("Add Folder", comment: "")) {
              let newBookmark = Bookmark(title: "test", parent: bookmark)
              newBookmark.title = "\(newBookmark.id)"
              if let _ = bookmark.children {
                bookmark.children?.append(newBookmark)
              }
            }
            Divider()
            Button(NSLocalizedString("Delete", comment: "")) {
              deleteBookmark(bookmark)
              do {
                try modelContext.save()
              } catch {
                print("delete error")
              }
            }
          }
      }
      
      Divider()
        .padding(10)
      
      ForEach(allBookmarks) { test in
        VStack {
          HStack {
            Text(test.title)
            if let children = test.children {
              Text("is child - \(children.count)")
            } else {
              Text("no child")
            }
            if let _ = test.parent {
              Text("is parent true")
            } else {
              Text("is parent false")
            }
          }
          if let children = test.children {
            Divider()
              .padding(.top, 5)
            ForEach(children) { test2 in
              HStack {
                Text(test2.title)
                if let _ = test2.parent {
                  Text("is parent true")
                } else {
                  Text("is parent false")
                }
              }
              
            }
          }
        }
        .background(.red.opacity(0.2))
        .padding(5)
      }
    }
  }
}

//struct BookmarkFolder: View {
//  @Environment(\.modelContext) var modelContext
//  var bookmark: Bookmark
//  
//  var body: some View {
//    Text(bookmark.title)
//      .contextMenu {
//        Button(NSLocalizedString("Add Folder", comment: "")) {
//          let newBookmark = Bookmark(parentId: bookmark.id)
//          newBookmark.title = "\(newBookmark.id)"
//          
////          modelContext.insert(newBookmark)
////          do {
////            try modelContext.save()
////          } catch {
////            print("save error")
////          }
//          
//          if let _ = bookmark.children {
//            bookmark.children = [newBookmark]
//          } else {
//            bookmark.children?.append(newBookmark)
//          }
//          
////          newBookmark.children = []
////          if let children = bookmark.children {
////            bookmark.children = [newBookmark]
////          } else {
////            bookmark.children?.append(newBookmark)
////          }
////          do {
////            try modelContext.save()
////          } catch {
////            print("save error")
////          }
//        }
//        
//        Divider()
//        
//        Button(NSLocalizedString("Delete", comment: "")) {
////          modelContext.delete(bookmark)
//        }
//      }
//  }
//}

//struct BookmarkRow: View {
//  var bookmark: Bookmark
//  
//  var body: some View {
//    HStack {
//      Text(bookmark.title)
//      Spacer()
//      if let urlString = bookmark.url, let url = URL(string: urlString) {
//        Link(destination: url) {
//          Image(systemName: "link")
//        }
//      }
//    }
//  }
//}
