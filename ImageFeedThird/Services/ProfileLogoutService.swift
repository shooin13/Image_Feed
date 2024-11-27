import Foundation
import WebKit

// MARK: - ProfileLogoutService

final class ProfileLogoutService {
  
  // MARK: - Shared Instance
  static let shared = ProfileLogoutService()
  
  private init() { }
  
  // MARK: - Logout
  
  func logout() {
    cleanCookies()
    resetServices()
    clearToken()
  }
  
  // MARK: - Private Methods
  
  private func cleanCookies() {
    HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
    WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
      records.forEach { record in
        WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
      }
    }
    print("Cookies and website data cleared")
  }
  
  private func resetServices() {
    ProfileService.shared.resetProfile()
    ProfileImageService.shared.resetAvatarURL()
    ImagesListService.shared.resetPhotos()
    print("Services reset completed")
  }
  
  private func clearToken() {
    OAuth2TokenStorage().token = nil
    print("Token cleared")
  }
}
