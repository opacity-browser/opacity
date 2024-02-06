//
//  TestContentView.swift
//  FriedEgg
//
//  Created by Falsy on 2/5/24.
//

import SwiftUI

struct TestContentView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        .onDrag {
          return NSItemProvider(object: NSString(string: ""))
        }
    }
}

#Preview {
    TestContentView()
}
