import Foundation
import SwiftKeychainWrapper

// MARK: - OAuth2TokenStorage

final class OAuth2TokenStorage {
  
  // MARK: - Properties
  
  private let tokenKey = "BearerToken"
  
  // MARK: - Token Management
  
  var token: String? {
    get {
      print("token get")
      return KeychainWrapper.standard.string(forKey: tokenKey)
    }
    set {
      print("token set")
      if let newValue {
        KeychainWrapper.standard.set(newValue, forKey: tokenKey)
      } else {
        KeychainWrapper.standard.removeObject(forKey: tokenKey)
      }
    }
  }
}
