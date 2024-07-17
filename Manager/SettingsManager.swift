//
//  SettingsManager.swift
//  Opacity
//
//  Created by Falsy on 4/5/24.
//

import SwiftUI
import SwiftData

class SettingsManager {
  @MainActor static func getGeneralSettings() -> GeneralSetting? {
    var descriptor = FetchDescriptor<GeneralSetting>()
    descriptor.fetchLimit = 1
    do {
      if let generalSettings = try AppDelegate.shared.opacityModelContainer.mainContext.fetch(descriptor).first {
        return generalSettings
      }
    } catch {
      print("ModelContainerError getGeneralSettings")
    }
    return nil
  }
  
  @MainActor static func setSearchEngine(_ value: String) {
    var descriptor = FetchDescriptor<GeneralSetting>()
    descriptor.fetchLimit = 1
    if let searchEngine = SearchEngineList(rawValue: value) {
      do {
        if let browserSettings = try AppDelegate.shared.opacityModelContainer.mainContext.fetch(descriptor).first {
          browserSettings.searchEngine = searchEngine.rawValue
        }
      } catch {
        print("ModelContainerError setSearchEngine")
      }
    }
  }
  
  @MainActor static func setScreenMode(_ value: String) {
    var descriptor = FetchDescriptor<GeneralSetting>()
    descriptor.fetchLimit = 1
    if let screenMode = ScreenModeList(rawValue: value) {
      do {
        if let browserSettings = try AppDelegate.shared.opacityModelContainer.mainContext.fetch(descriptor).first {
          browserSettings.screenMode = screenMode.rawValue
        }
      } catch {
        print("ModelContainerError setScreenMode")
      }
    }
  }
  
  @MainActor static func setRetentionPeriod(_ value: String) {
    var descriptor = FetchDescriptor<GeneralSetting>()
    descriptor.fetchLimit = 1
    if let period = DataRententionPeriodList(rawValue: value) {
      do {
        if let browserSettings = try AppDelegate.shared.opacityModelContainer.mainContext.fetch(descriptor).first {
          browserSettings.retentionPeriod = period.rawValue
        }
      } catch {
        print("ModelContainerError setRetentionPeriod")
      }
    }
  }
  
  @MainActor static func setIsTrackerBlocking(_ value: Bool) {
    var descriptor = FetchDescriptor<GeneralSetting>()
    descriptor.fetchLimit = 1
    do {
      if let browserSettings = try AppDelegate.shared.opacityModelContainer.mainContext.fetch(descriptor).first {
        browserSettings.isTrackerBlocking = value
      }
    } catch {
      print("ModelContainerError isTrackerBlocking")
    }
  }
  
  // Deprecated
  @MainActor static func setBlockingTracker(_ value: String) {
    var descriptor = FetchDescriptor<GeneralSetting>()
    descriptor.fetchLimit = 1
    if let blockingTracker = BlockingTrakerList(rawValue: value) {
      do {
        if let browserSettings = try AppDelegate.shared.opacityModelContainer.mainContext.fetch(descriptor).first {
          browserSettings.blockingLevel = blockingTracker.rawValue
        }
      } catch {
        print("ModelContainerError setBlockTracker")
      }
    }
  }
  
  // Deprecated
  @MainActor static func setAdBlocking(_ value: Bool) {
    var descriptor = FetchDescriptor<GeneralSetting>()
    descriptor.fetchLimit = 1
    do {
      if let browserSettings = try AppDelegate.shared.opacityModelContainer.mainContext.fetch(descriptor).first {
        browserSettings.adBlocking = value
      }
    } catch {
      print("ModelContainerError setAdBlocking")
    }
  }
}
