//
//  ImageViewer.swift
//  Opacity
//
//  Created by Falsy on 1/20/24.
//

import SwiftUI

struct Favicon: View {
  @ObservedObject var imageLoader = ImageLoader()
  let url: URL

  init(url: URL) {
    self.url = url
    imageLoader.loadImage(url: url)
  }

  var body: some View {
    if let image = imageLoader.image {
      Image(nsImage: image)
        .resizable() // 이미지 크기 조절 가능하게 함
        .aspectRatio(contentMode: .fill)
        .frame(maxWidth: 14, maxHeight: 14)
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .clipped()
    }
  }
}
