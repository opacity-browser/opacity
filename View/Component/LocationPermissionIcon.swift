//
//  LocationPermissionIcon.swift
//  Opacity
//
//  Created by Falsy on 8/11/24.
//

import SwiftUI

struct LocationPermissionIcon: View {
  @ObservedObject var tab: Tab
  
  @State private var isLocationHover: Bool = false
  @State private var isLocationDialog: Bool = false
  
  var body: some View {
    VStack(spacing: 0) {
      VStack(spacing: 0) {
        Image(systemName: "location")
          .foregroundColor(Color("Icon"))
          .font(.system(size: 14))
          .fontWeight(.regular)
      }
      .frame(maxWidth: 24, maxHeight: 24)
      .background(isLocationHover ? .gray.opacity(0.2) : .gray.opacity(0))
      .clipShape(RoundedRectangle(cornerRadius: 6))
      .onHover { hover in
        withAnimation {
          isLocationHover = hover
        }
      }
      .onTapGesture {
        DispatchQueue.main.async {
          isLocationDialog.toggle()
        }
      }
      .popover(isPresented: $isLocationDialog, arrowEdge: .bottom) {
        LocationHostDialog(tab: tab, onClose: {
          DispatchQueue.main.async {
            tab.isUpdateLocation = true
            isLocationDialog = false
          }
        })
      }
    }
    .onAppear {
      self.isLocationDialog = tab.isLocationDialogByHost
    }
    .onChange(of: tab.isLocationDialogByHost) { _, nV in
      DispatchQueue.main.async {
        if nV != self.isLocationDialog {
          self.isLocationDialog = nV
        }
      }
    }
    .onChange(of: isLocationDialog) { _, nV in
      DispatchQueue.main.async {
        if nV != tab.isLocationDialogByHost {
          tab.isLocationDialogByHost = nV
        }
      }
    }
  }
}
