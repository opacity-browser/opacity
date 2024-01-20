//
//  ImageLoader.swift
//  Opacity
//
//  Created by Falsy on 1/20/24.
//

import SwiftUI
import Combine

final class ImageLoader: ObservableObject {
  @Published var image: NSImage?
  
  func loadImage(url: URL) {
    self.downloadImage(url: url) { image in
      self.image = image
    }
  }
  
  func downloadImage(url: URL, completion: @escaping (NSImage?) -> Void) {
    URLSession.shared.dataTask(with: url) { data, response, error in
      guard let data = data, let image = NSImage(data: data) else {
        DispatchQueue.main.async {
          completion(nil)
        }
        return
      }
      DispatchQueue.main.async {
        completion(image)
      }
    }.resume()
  }
}
