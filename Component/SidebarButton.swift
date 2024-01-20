//
//  SidebarButton.swift
//  Opacity
//
//  Created by Falsy on 1/18/24.
//

import SwiftUI

struct SidebarButton: View {
  var body: some View {
    Button(action: toggleSidebar, label: {
      Image(systemName: "sidebar.leading")
    })
  }
  
  private func toggleSidebar() {
    NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
  }
}