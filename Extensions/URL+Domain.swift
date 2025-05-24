//
//  URL+Domain.swift
//  Opacity
//
//  Created by Falsy on 5/24/25.
//

import Foundation

extension URL {
  var mainDomain: String? {
    guard let host = self.host else { return nil }
    return host
  }
}
