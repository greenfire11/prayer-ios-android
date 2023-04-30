import UIKit
import Flutter
import workmanager
import flutter_local_notifications
@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    static func registerPlugins(with registry: FlutterPluginRegistry) {
                GeneratedPluginRegistrant.register(with: registry)
           }

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
        AppDelegate.registerPlugins(with: registry)
      }
      WorkmanagerPlugin.setPluginRegistrantCallback { registry in
                  // The following code will be called upon WorkmanagerPlugin's registration.
                  // Note : all of the app's plugins may not be required in this context ;
                  // instead of using GeneratedPluginRegistrant.register(with: registry),
                  // you may want to register only specific plugins.
                  GeneratedPluginRegistrant.register(with: registry)
              }

      if #available(iOS 10.0, *) {
        UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
      }
    AppDelegate.registerPlugins(with: self)// Register the app's plugins in the context of a normal run
        
        
    WorkmanagerPlugin.registerTask(withIdentifier: "be.tramckrijte.workmanagerExample.simpleTask")
    UIApplication.shared.setMinimumBackgroundFetchInterval(TimeInterval(60*15))

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
