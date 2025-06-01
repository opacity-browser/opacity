//
//  EmptyFavoriteSlot.swift
//  Opacity
//
//  Created by Falsy on 6/1/25.
//

import SwiftUI

struct EmptyFavoriteSlot: View {
  var body: some View {
    RoundedRectangle(cornerRadius: 10)
      .stroke(style: StrokeStyle(lineWidth: 2, dash: [6, 6]))
      .foregroundColor(Color("UIText").opacity(0.09))
      .frame(width: 112, height: 112)
  }
}
