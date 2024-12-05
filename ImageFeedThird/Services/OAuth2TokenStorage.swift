import Foundation
import SwiftKeychainWrapper

// MARK: - OAuth2TokenStorage

final class OAuth2TokenStorage {
  // MARK: - Properties
  
  private let tokenKey = "BearerToken"
  
  // MARK: - Token Management
  
  var token: String? {
    get {
      print("Получение токена из хранилища")
      return KeychainWrapper.standard.string(forKey: tokenKey)
    }
    set {
      if let newValue = newValue {
        print("Сохранение токена в хранилище")
        KeychainWrapper.standard.set(newValue, forKey: tokenKey)
      } else {
        print("Удаление токена из хранилища")
        KeychainWrapper.standard.removeObject(forKey: tokenKey)
      }
    }
  }
}
