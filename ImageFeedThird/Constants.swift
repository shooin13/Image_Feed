import Foundation
import Kingfisher

// MARK: - Constants

enum Constants {
  static let accessKey = "sxag6w_pOMqE-cNeFfQiIWSVzRUcJ1M04pDKw7L5gR4"
  static let secretKey = "p2V7BnQobsI82ci7EMtZkBixDKXuB7JVQ_5gTtIN6S4"
  static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
  static let accessScope = "public+read_user+write_likes"
  
  static let defaultBaseURL: URL = {
    if let url = URL(string: "https://api.unsplash.com/") {
      return url
    } else {
      fatalError("Ошибка: недопустимый URL")
    }
  }()
  
  static let avatarImageCache: ImageCache = {
    let cache = ImageCache(name: "AvatarImageCache")
    cache.memoryStorage.config.totalCostLimit = 10 * 1024 * 1024
    cache.diskStorage.config.sizeLimit = 10 * 1024 * 1024
    return cache
  }()
}
