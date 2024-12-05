import UIKit
import Kingfisher

// MARK: - AppDelegate

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
  // MARK: - Application Lifecycle
  
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return true
  }
  
  func application(
    _ application: UIApplication,
    configurationForConnecting connectingSceneSession: UISceneSession,
    options: UIScene.ConnectionOptions
  ) -> UISceneConfiguration {
    let sceneConfiguration = UISceneConfiguration(name: "Main", sessionRole: connectingSceneSession.role)
    sceneConfiguration.delegateClass = SceneDelegate.self
    return sceneConfiguration
  }
  
  func application(
    _ application: UIApplication,
    didDiscardSceneSessions sceneSessions: Set<UISceneSession>
  ) {
    // Handle discarded sessions if needed
  }
}
