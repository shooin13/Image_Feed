import Foundation

// MARK: - OAuth2TokenStorage

final class OAuth2TokenStorage {
  
  // MARK: - Properties
  
  private let userDefaults = UserDefaults.standard
  private let tokenKey = "BearerToken"
  
  // MARK: - Token Management
  
  var token: String? {
    get {
      print("token get")
      return userDefaults.string(forKey: tokenKey)
    }
    set {
      print("token set")
      userDefaults.setValue(newValue, forKey: tokenKey)
    }
  }
}
