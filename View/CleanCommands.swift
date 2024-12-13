//
//  CleanCommands.swift
//  Opacity
//
//  Created by Falsy on 12/13/24.
//

import SwiftUI

struct CleanCommands: Commands {
  @ObservedObject var appDelegate: AppDelegate
  
  init(appDelegate: AppDelegate) {
    self.appDelegate = appDelegate
  }
  
  var body: some Commands {
    CommandGroup(replacing: .saveItem) {
      
    }
    
    CommandGroup(replacing: .appSettings) {
      
    }
  }
}
