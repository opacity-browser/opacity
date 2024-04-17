//
//  Download.swift
//  Opacity
//
//  Created by Falsy on 4/15/24.
//

import SwiftUI
import Combine

class Download: ObservableObject {
  var id: UUID
  var url: URL
  var createAt: Date
  
//  @Published var downloadProgress: Double = 0.0
  @Published var isDownloading = false
  
  init(url: URL) {
    self.id = UUID()
    self.url = url
    self.createAt = Date.now
  }
  
  var cancellable: AnyCancellable?
  var cancellables = Set<AnyCancellable>()

  func downloadFile() {
    guard let downloadsPath = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first else {
      print("Could not find the downloads directory")
      return
    }
    
    let destinationURL = downloadsPath.appendingPathComponent(url.lastPathComponent)
    let request = URLRequest(url: url)
    self.isDownloading = true
    
    cancellable = URLSession.shared.dataTaskPublisher(for: request)
      .tryMap { output -> Data in
        guard let response = output.response as? HTTPURLResponse, response.statusCode == 200 else {
          throw URLError(.badServerResponse)
        }
        return output.data
      }
      .sink(receiveCompletion: { completion in
        switch completion {
          case .finished:
            print("Download finished")
          case .failure(let error):
            print("Download failed with error: \(error)")
        }
        self.isDownloading = false
      }, receiveValue: { data in
        do {
          try data.write(to: destinationURL, options: .atomicWrite)
          print("File saved to \(destinationURL)")
        } catch {
          print("Error saving file: \(error)")
        }
      })
      
    cancellable?.store(in: &cancellables)
  }
  
  func cancelDownload() {
    cancellable?.cancel()
    isDownloading = false
  }
}
