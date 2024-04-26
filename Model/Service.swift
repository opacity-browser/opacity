//
//  Service.swift
//  Opacity
//
//  Created by Falsy on 2/7/24.
//

import SwiftUI

final class Service: ObservableObject {
  @Published var browsers: [Int:Browser] = [:]
  @Published var blockingLevel: Int = 2
  var dragBrowserNumber: Int?
  var dragTabId: UUID?
  var dragBookmark: Bookmark?
  var dragBookmarkGroup: BookmarkGroup?
  var isMoveTab: Bool = false
}
