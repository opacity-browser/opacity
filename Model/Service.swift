//
//  Service.swift
//  FriedEgg
//
//  Created by Falsy on 2/7/24.
//

import SwiftUI

final class Service: ObservableObject {
  @Published var browsers: [Int:Browser] = [:]
  @Published var dragTabId: UUID?
  @Published var isMoveTab: Bool = false
}
