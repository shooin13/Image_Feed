import UIKit
import Kingfisher

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  lazy var avatarImageCache: ImageCache = {
    let cache = ImageCache(name: "AvatarImageCache")
    cache.memoryStorage.config.totalCostLimit = 10 * 1024 * 1024
    cache.diskStorage.config.sizeLimit = 10 * 1024 * 1024
    return cache
  }()
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    avatarImageCache = ImageCache(name: "AvatarImageCache")
    avatarImageCache.memoryStorage.config.totalCostLimit = 10 * 1024 * 1024
    return true
  }
  
  // MARK: UISceneSession Lifecycle
  
  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    let sceneConfiguration = UISceneConfiguration(name: "Main", sessionRole: connectingSceneSession.role)
    sceneConfiguration.delegateClass = SceneDelegate.self
    return sceneConfiguration
  }
  
  func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    
  }
}

