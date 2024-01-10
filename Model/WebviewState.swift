//
//  WebviewState.swift
//  Opacity
//
//  Created by Falsy on 1/10/24.
//

import SwiftUI

class WebviewState: ObservableObject {
    @Published var webURL: String
    @Published var inputURL: String
    @Published var viewURL: String
    @Published var title: String = "new tabs"
    
    @Published var goToPage: Bool
    @Published var goBack: Bool
    @Published var goForward: Bool
    
    init(webURL: String = DEFAULT_URL, goToPage: Bool = false, goBack: Bool = false, goForward: Bool = false) {
        self.webURL = webURL
        self.inputURL = webURL
        self.viewURL = StringURL.shortURL(url: webURL)
        self.goToPage = goToPage
        self.goBack = goBack
        self.goForward = goForward
    }
}
