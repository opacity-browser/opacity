//
//  OpacityScriptHandler.swift
//  Opacity
//
//  Created by Falsy on 4/5/24.
//

import SwiftUI
import SwiftData

final class OpacityScriptHandler {
  @ObservedObject var tab: Tab
  
  init(tab: Tab) {
    self.tab = tab
  }
  
  private func dateFromString(_ dateString: String) -> Date? {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "yyyy-MM"
      dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
      return dateFormatter.date(from: dateString)
  }
  
  private func decodeJSON<T: Decodable>(from jsonString: String, to type: T.Type) throws -> T {
    guard let jsonData = jsonString.data(using: .utf8) else {
      throw NSError(domain: "Invalid JSON", code: 0, userInfo: nil)
    }
    
    let decoder = JSONDecoder()
    let decodedData = try decoder.decode(T.self, from: jsonData)
    return decodedData
  }
  
  private func encodeJSON<T: Encodable>(from instance: T) throws -> String {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    
    let encodedData = try encoder.encode(instance)
    guard let jsonString = String(data: encodedData, encoding: .utf8) else {
      throw NSError(domain: "Invalid JSON", code: 1, userInfo: nil)
    }
    
    return jsonString
  }
  
  
  func messages(name: String, value: String?) {
    var script: String?
    
    if let value = value {
      switch name {
        case "replacePage":
          script = replacePage(value)
          break
        case "goPage":
          script = goPage(value)
          break
        case "getPageStrings":
          script = getPageStrings(value)
          break
        case "addFavorite":
          script = addFavorite(value)
          break
        case "deleteFavorite":
          script = deleteFavorite(value)
          break
        case "setSearchEngine":
          script = setSearchEngine(value)
          break
        case "setScreenMode":
          script = setScreenMode(value)
          break
        case "setRetentionPeriod":
          script = setRetentionPeriod(value)
          break
        case "setIsTrackerBlocking":
          script = setIsTrackerBlocking(value)
          break
        case "setBlockingTracker": // Deprecated
          script = setBlockingTracker(value)
          break
        case "setAdBlocking": // Deprecated
          script = setAdBlocking(value)
          break
        case "getSearchHistoryList":
          script = getSearchHistoryList(value)
          break
        case "getVisitHistoryList":
          script = getVisitHistoryList(value)
          break
        case "deleteSearchHistory":
          script = deleteSearchHistory(value)
          break
        case "deleteVisitHistory":
          script = deleteVisitHistory(value)
          break
        case "deletePermissions":
          script = deletePermissions(value)
          break
        case "updateNotificationPermissions":
          script = updateNotificationPermissions(value)
        default: break
      }
    } else {
      switch name {
        case "getGeneralSettings":
          script = getGeneralSettings()
          break
        case "getGeneralSettingList":
          script = getGeneralSettingList()
          break
        case "getLocationPermisions":
          script = getLocationPermisions()
          break
        case "getNotificationPermisions":
          script = getNotificationPermisions()
          break
        case "getFavoriteList":
          script = getFavoriteList()
          break
        case "getFrequentList":
          script = getFrequentList()
          break
        case "deleteAllSearchHistory":
          script = deleteAllSearchHistory()
          break
        case "deleteAllVisitHistory":
          script = deleteAllVisitHistory()
          break
        default: break
      }
    }
    
    if let webview = tab.webview, let script = script {
      webview.evaluateJavaScript(script, completionHandler: nil)
    }
  }

  func deleteAllSearchHistory() -> String {
    SearchManager.deleteAllSearchHistory()
    return """
      window.opacityResponse.deleteAllSearchHistory({
        data: "success"
      })
    """
  }
  
  func deleteAllVisitHistory() -> String {
    VisitManager.deleteAllVisitHistory()
    return """
      window.opacityResponse.deleteAllVisitHistory({
        data: "success"
      })
    """
  }
  
  func updateNotificationPermissions(_ updateParmas: String) -> String {
    do {
      let params = try decodeJSON(from: updateParmas, to: UpdatePermissionParams.self)
      if let uuid = UUID(uuidString: params.id) {
        PermissionManager.updatePermisionById(id: uuid, isDenied: params.isDenied)
      }
      return """
        window.opacityResponse.updateNotificationPermissions({
          data: "success"
        })
      """
    } catch {
      print("JSONDecodeError updateNotificationPermissions")
    }
    return """
      window.opacityResponse.updateNotificationPermissions({
        data: "error"
      })
    """
  }
  
  func deletePermissions(_ permissionIds: String) -> String? {
    do {
      let deletePermissionIds = try decodeJSON(from: permissionIds, to: [String].self)
      for id in deletePermissionIds {
        if let uuid = UUID(uuidString: id) {
          PermissionManager.deletePermisionById(uuid)
        }
      }
      return """
        window.opacityResponse.deletePermissions({
          data: "success"
        })
      """
    } catch {
      print("JSONDecodeError deletePermissions")
    }
    return """
      window.opacityResponse.deletePermissions({
        data: "error"
      })
    """
  }
  
  func deleteVisitHistory(_ historyIds: String) -> String? {
    do {
      let deleteHistoryIds = try decodeJSON(from: historyIds, to: [String].self)
      for id in deleteHistoryIds {
        if let uuid = UUID(uuidString: id) {
          VisitManager.deleteVisitHistoryById(uuid)
        }
      }
      return """
        window.opacityResponse.deleteVisitHistory({
          data: "success"
        })
      """
    } catch {
      print("JSONDecodeError deleteVisitHistory")
    }
    return """
      window.opacityResponse.deleteVisitHistory({
        data: "error"
      })
    """
  }
  
  func deleteSearchHistory(_ historyIds: String) -> String? {
    do {
      let deleteHistoryIds = try decodeJSON(from: historyIds, to: [String].self)
      for id in deleteHistoryIds {
        if let uuid = UUID(uuidString: id) {
          SearchManager.deleteSearchHistoryById(uuid)
        }
      }
      return """
        window.opacityResponse.deleteSearchHistory({
          data: "success"
        })
      """
    } catch {
      print("JSONDecodeError deleteSearchHistory")
    }
    return """
      window.opacityResponse.deleteSearchHistory({
        data: "error"
      })
    """
  }
  
  func getVisitHistoryList(_ yearMonth: String) -> String? {
    if let targetDate = dateFromString(yearMonth) {
      let descriptor = FetchDescriptor<VisitHistory>()
      do {
        let calendar = Calendar.current
        let visitHistoryList = try AppDelegate.shared.opacityModelContainer.mainContext.fetch(descriptor)

        var firstDateString = ""
        if let firstData = visitHistoryList.first {
          let firstDateYearMonth = calendar.dateComponents([.year, .month], from: firstData.createDate)
          if let fYear = firstDateYearMonth.year, let fMonth = firstDateYearMonth.month {
            let padStartMonth = String(describing: fMonth).count == 2 ? String(describing: fMonth) : "0\(String(describing: fMonth))"
            firstDateString = "\(String(describing: fYear))-\(padStartMonth)"
          }
        }
        let filterHistoryList = visitHistoryList.filter {
          let components = calendar.dateComponents([.year, .month], from: $0.createDate)
          let targetComponents = calendar.dateComponents([.year, .month], from: targetDate)
          return components.year == targetComponents.year && components.month == targetComponents.month
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        var visitHistories: [VisitHistorySettings] = []
        for sh in filterHistoryList {
          visitHistories.append(VisitHistorySettings(id: sh.id, title: sh.visitHistoryGroup?.title, url: sh.visitHistoryGroup!.url, createDate: dateFormatter.string(from: sh.createDate)))
        }
        let jsonString = try encodeJSON(from: visitHistories)
        return """
          window.opacityResponse.getVisitHistoryList({
            data: {
              firstDate: "\(firstDateString)",
              list: \(jsonString)
            }
          })
        """
      } catch {
        print("JSONEncodeError getVisitHistoryList")
      }
    }
      
    return """
      window.opacityResponse.getVisitHistoryList({
        data: "error"
      })
    """
  }
  
  func getSearchHistoryList(_ yearMonth: String) -> String? {
    if let targetDate = dateFromString(yearMonth) {
      let descriptor = FetchDescriptor<SearchHistory>()
      
      do {
        let calendar = Calendar.current
        let searchHistoryList = try AppDelegate.shared.opacityModelContainer.mainContext.fetch(descriptor)
        
        var firstDateString = ""
        if let firstData = searchHistoryList.first {
          let firstDateYearMonth = calendar.dateComponents([.year, .month], from: firstData.createDate)
          if let fYear = firstDateYearMonth.year, let fMonth = firstDateYearMonth.month {
            let padStartMonth = String(describing: fMonth).count == 2 ? String(describing: fMonth) : "0\(String(describing: fMonth))"
            firstDateString = "\(String(describing: fYear))-\(padStartMonth)"
          }
        }
        let filterHistoryList = searchHistoryList.filter {
          let components = calendar.dateComponents([.year, .month], from: $0.createDate)
          let targetComponents = calendar.dateComponents([.year, .month], from: targetDate)
          return components.year == targetComponents.year && components.month == targetComponents.month
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        var searchHistories: [SearchHistorySettings] = []
        for sh in filterHistoryList {
          searchHistories.append(SearchHistorySettings(id: sh.id, searchText: sh.searchHistoryGroup!.searchText, createDate: dateFormatter.string(from: sh.createDate)))
        }
        
        let jsonString = try encodeJSON(from: searchHistories)
        return """
          window.opacityResponse.getSearchHistoryList({
            data: {
              firstDate: "\(firstDateString)",
              list: \(jsonString)
            }
          })
        """
      } catch {
        print("JSONEncodeError getSearchHistoryList")
      }
    }
      
    return """
      window.opacityResponse.getSearchHistoryList({
        data: "error"
      })
    """
  }
  
  func setIsTrackerBlocking(_ value: String) -> String? {
    guard let boolValue = Bool(value) else {
      return """
        window.opacityResponse.setIsTrackerBlocking({
          data: "error"
        })
      """
    }
    SettingsManager.setIsTrackerBlocking(boolValue)
    AppDelegate.shared.service.isTrackerBlocking = boolValue
    return """
    window.opacityResponse.setIsTrackerBlocking({
      data: "success"
    })
  """
  }
  
  // Deprecated
  func setBlockingTracker(_ value: String) -> String? {
    SettingsManager.setBlockingTracker(value)
    AppDelegate.shared.service.blockingLevel = value
    return """
    window.opacityResponse.setBlockingTracker({
      data: "success"
    })
  """
  }
  
  // Deprecated
  func setAdBlocking(_ value: String) -> String? {
    guard let boolValue = Bool(value) else {
      return """
        window.opacityResponse.setAdBlocking({
          data: "error"
        })
      """
    }
    
    SettingsManager.setAdBlocking(boolValue)
    AppDelegate.shared.service.isAdBlocking = boolValue
    return """
      window.opacityResponse.setAdBlocking({
        data: "success"
      })
    """
  }
  
  func setRetentionPeriod(_ value: String) -> String? {
    SettingsManager.setRetentionPeriod(value)
    return """
      window.opacityResponse.setRetentionPeriod({
        data: "success"
      })
    """
  }
  
  func setScreenMode(_ value: String) -> String? {
    SettingsManager.setScreenMode(value)
    return """
      window.opacityResponse.setScreenMode({
        data: "success"
      })
    """
  }
  
  func setSearchEngine(_ value: String) -> String? {
    SettingsManager.setSearchEngine(value)
    return """
      window.opacityResponse.setSearchEngine({
        data: "success"
      })
    """
  }
  
  func deleteFavorite(_ favoriteId: String) -> String? {
    let isSuccess = FavoriteManager.deleteFavoriteById(favoriteId)
    
    if isSuccess {
      return """
      window.opacityResponse.deleteFavorite({
        data: "success"
      })
    """
    }
    
    return """
      window.opacityResponse.deleteFavorite({
        data: "error"
      })
    """
  }
  
  func addFavorite(_ favoriteData: String) -> String? {
    do {
      let favoriteItem = try decodeJSON(from: favoriteData, to: FavoriteItemParams.self)
      let favorite = Favorite(title: favoriteItem.title, address: favoriteItem.address)
      let isSuccess = FavoriteManager.addFavorite(favorite)
      
      if isSuccess {
        return """
        window.opacityResponse.addFavorite({
          data: "success"
        })
      """
      }
    } catch {
      print("JSONDecodeError addFavorite")
    }
    
    return """
      window.opacityResponse.addFavorite({
        data: "error"
      })
    """
  }
  
  func getFrequentList() -> String? {
    do {
      if let visitHistoryGroupList = VisitManager.getFrequentList() {
        var jsonDataList: [FavoriteItem] = []
        for visitHistoryGroup in visitHistoryGroupList {
          jsonDataList.append(FavoriteItem(id: visitHistoryGroup.id, title: visitHistoryGroup.title ?? "", address: visitHistoryGroup.url))
        }
        
        let jsonString = try encodeJSON(from: jsonDataList)
        return """
          window.opacityResponse.getFrequentList({
            data: \(jsonString)
          })
        """
      }
    } catch {
      print("JSONEncodeError getFrequentList")
    }
    
    return """
      window.opacityResponse.getFrequentList({
        data: "error"
      })
    """
  }
  
  func getFavoriteList() -> String? {
    do {
      if let favoriteList = FavoriteManager.getFavoriteList() {
        var jsonDataList: [FavoriteItem] = []
        for favorite in favoriteList {
          jsonDataList.append(FavoriteItem(id: favorite.id, title: favorite.title, address: favorite.address))
        }
        
        let jsonString = try encodeJSON(from: jsonDataList)
        return """
          window.opacityResponse.getFavoriteList({
            data: \(jsonString)
          })
        """
      }
    } catch {
      print("JSONEncodeError getFavoriteList")
    }
    
    return """
      window.opacityResponse.getFavoriteList({
        data: "error"
      })
    """
  }
  
  func getLocationPermisions() -> String? {
    if let locaitonPermitions = PermissionManager.getLocationPermisions() {
      var jsonDataList: [PermissionItem] = []
      for noti in locaitonPermitions {
        jsonDataList.append(PermissionItem(id: noti.id, domain: noti.domain, permission: noti.permission, isDenied: noti.isDenied))
      }
      do {
        let jsonString = try encodeJSON(from: jsonDataList)
        return """
          window.opacityResponse.getLocationPermisions({
            data: \(jsonString)
          })
        """
      } catch {
        print("JSONEncodeError getLocationPermisions")
      }
    }

    return """
      window.opacityResponse.getLocationPermisions({
        data: "error"
      })
    """
  }
  
  func getNotificationPermisions() -> String? {
    if let notificationPermitions = PermissionManager.getNotificationPermisions() {
      var jsonDataList: [PermissionItem] = []
      for noti in notificationPermitions {
        jsonDataList.append(PermissionItem(id: noti.id, domain: noti.domain, permission: noti.permission, isDenied: noti.isDenied))
      }
      do {
        let jsonString = try encodeJSON(from: jsonDataList)
        return """
          window.opacityResponse.getNotificationPermisions({
            data: \(jsonString)
          })
        """
      } catch {
        print("JSONEncodeError getNotificationPermisions")
      }
    }

    return """
      window.opacityResponse.getNotificationPermisions({
        data: "error"
      })
    """
  }
  
  func getGeneralSettingList() -> String? {
    var searchEngineList: [SettingListItem] = []
    var screenModeList: [SettingListItem] = []
    var periodList: [SettingListItem] = []
    
    for engine in SEARCH_ENGINE_LIST {
      searchEngineList.append(SettingListItem(id: engine.name, name: engine.name))
    }
    for screenModeItem in SCREEN_MODE_LIST {
      screenModeList.append(SettingListItem(id: screenModeItem, name: NSLocalizedString(screenModeItem, comment: "")))
    }
    for periodItem in RETENTION_PERIOD_LIST {
      periodList.append(SettingListItem(id: periodItem, name: NSLocalizedString(periodItem, comment: "")))
    }
    
    do {
      let searchString = try encodeJSON(from: searchEngineList)
      let screenModeString = try encodeJSON(from: screenModeList)
      let periodString = try encodeJSON(from: periodList)
      return """
        window.opacityResponse.getGeneralSettingList({
          data: {
            searchEngine: \(searchString),
            screenMode: \(screenModeString),
            retentionPeriod: \(periodString)
          }
        })
     """
    } catch {
      print("JSONEncodeError getGeneralSettingList")
    }
    
    return """
      window.opacityResponse.getGeneralSettingList({
        data: "error"
      })
    """
  }
  
  func getPageStrings(_ pageName: String) -> String? {
    switch pageName {
      case "new-tab":
        return """
        window.opacityResponse.getPageStrings({
          data: {
            "Favorite": '\(NSLocalizedString("Favorite", comment: ""))',
            "Frequent": '\(NSLocalizedString("Frequent", comment: ""))',
            "Add Favorite": '\(NSLocalizedString("Add Favorite", comment: ""))',
            "Title": '\(NSLocalizedString("Title", comment: ""))',
            "Address": '\(NSLocalizedString("Address", comment: ""))',
            "Add": '\(NSLocalizedString("Add", comment: ""))',
            "Cancel": '\(NSLocalizedString("Cancel", comment: ""))',
            "An error occurred": '\(NSLocalizedString("An error occurred", comment: ""))',
            "Please enter title or address": '\(NSLocalizedString("Please enter title or address", comment: ""))',
          }
        })
      """
      case "settings":
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
          return """
          window.opacityResponse.getPageStrings({
            data: {
              "Settings": '\(NSLocalizedString("Settings", comment: ""))',
              "General": '\(NSLocalizedString("General", comment: ""))',
              "Search History": '\(NSLocalizedString("Search History", comment: ""))',
              "Visit History": '\(NSLocalizedString("Visit History", comment: ""))',
              "Permission": '\(NSLocalizedString("Permission", comment: ""))',
              "Search Engine": '\(NSLocalizedString("Search Engine", comment: ""))',
              "Screen Mode": '\(NSLocalizedString("Screen Mode", comment: ""))',
              "History Data Retention Period": '\(NSLocalizedString("History Data Retention Period", comment: ""))',
              "View More": '\(NSLocalizedString("View More", comment: ""))',
              "$n were selected.": '\(NSLocalizedString("$n were selected.", comment: ""))',
              "Delete": '\(NSLocalizedString("Delete", comment: ""))',
              "Cancel": '\(NSLocalizedString("Cancel", comment: ""))',
              "An error occurred": '\(NSLocalizedString("An error occurred", comment: ""))',
              "Notification": '\(NSLocalizedString("Notification", comment: ""))',
              "Location": '\(NSLocalizedString("Location", comment: ""))',
              "allowed": '\(NSLocalizedString("allowed", comment: ""))',
              "denied": '\(NSLocalizedString("denied", comment: ""))',
              "There is no domain with permissions set.": '\(NSLocalizedString("There is no domain with permissions set.", comment: ""))',
              "There is no search history.": '\(NSLocalizedString("There is no search history.", comment: ""))',
              "There is no visit history.": '\(NSLocalizedString("There is no visit history.", comment: ""))',
              "Tracker Blocking": '\(NSLocalizedString("Tracker Blocking", comment: ""))',
              "Learn More": '\(NSLocalizedString("Learn More", comment: ""))',
              "Clear All": '\(NSLocalizedString("Clear All", comment: ""))',
              "Library": '\(NSLocalizedString("Library", comment: ""))',
              "This is a library used in service development.": '\(NSLocalizedString("This is a library used in service development.", comment: ""))',
              "version": "\(version)"
            }
          })
        """
        }
      default:
        print("ParameterError getPageStrings")
    }
    
    return """
      window.opacityResponse.getPageStrings({
        data: "error"
      })
    """
  }
  
  func replacePage(_ address: String) -> String? {
    
    tab.webviewIsError = false
    return """
      window.location.replace("\(address)")
    """
  }
  
  func goPage(_ address: String) -> String? {
    let newAddress = tab.changeKeywordToURL(address)
    tab.updateURLBySearch(url: URL(string: newAddress)!)
    
    return """
      window.opacityResponse.goPage({
        data: "success"
      })
    """
  }
  
  func getGeneralSettings() -> String? {
    if let browserSettings = SettingsManager.getGeneralSettings() {
      return """
        window.opacityResponse.getGeneralSettings({
          data: {
            searchEngine: {
              id: "\(browserSettings.searchEngine)",
              name: "\(NSLocalizedString(browserSettings.searchEngine, comment: ""))"
            },
            screenMode: {
              id: "\(browserSettings.screenMode)",
              name: "\(NSLocalizedString(browserSettings.screenMode, comment: ""))"
            },
            retentionPeriod: {
              id: "\(browserSettings.retentionPeriod)",
              name: "\(NSLocalizedString(browserSettings.retentionPeriod, comment: ""))"
            },
            isTrackerBlocking: \(browserSettings.isTrackerBlocking)
          }
        })
      """
    }
    
    return """
      window.opacityResponse.getGeneralSettings({
        data: "error"
      })
    """
  }
  
}
