import CarPlay
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Pick the configuration that matches the session role. Returning "Default Configuration"
        // for every role would stop the CarPlay scene from finding its delegate in Info.plist.
        let name = connectingSceneSession.role == .carTemplateApplication
            ? "CarPlay Configuration"
            : "Default Configuration"
        return UISceneConfiguration(name: name, sessionRole: connectingSceneSession.role)
    }
}
