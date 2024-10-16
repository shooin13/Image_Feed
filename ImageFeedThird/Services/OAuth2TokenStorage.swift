import Foundation

final class OAuth2TokenStorage {
  private let userDefaults = UserDefaults.standard
  private let tokenKey = "BearerToken"
  
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
