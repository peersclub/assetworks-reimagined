import Flutter
import UIKit
import ActivityKit
import Firebase
import FirebaseMessaging
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // Setup Dynamic Island channel
    setupDynamicIslandChannel()
    
    // Setup Push Notifications
    setupPushNotifications(application)
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  private func setupDynamicIslandChannel() {
    guard let controller = window?.rootViewController as? FlutterViewController else { return }
    
    let dynamicIslandChannel = FlutterMethodChannel(
      name: "ai.assetworks.dynamicisland",
      binaryMessenger: controller.binaryMessenger
    )
    
    dynamicIslandChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
      // Check iOS version for Dynamic Island support
      if #available(iOS 16.1, *) {
        DynamicIslandManager.shared.handleMethodCall(call, result: result)
      } else {
        // Fallback for older iOS versions
        result(FlutterError(code: "UNSUPPORTED", message: "Dynamic Island requires iOS 16.1+", details: nil))
      }
    }
  }
  
  private func setupPushNotifications(_ application: UIApplication) {
    // Configure Firebase
    if FirebaseApp.app() == nil {
      FirebaseApp.configure()
    }
    
    // Setup messaging delegate
    Messaging.messaging().delegate = self
    
    // Register for notifications
    NotificationService.shared.registerForPushNotifications()
    NotificationService.shared.setupNotificationCategories()
    
    // Setup notification channel for Flutter
    setupNotificationChannel()
  }
  
  private func setupNotificationChannel() {
    guard let controller = window?.rootViewController as? FlutterViewController else { return }
    
    let notificationChannel = FlutterMethodChannel(
      name: "ai.assetworks.notifications",
      binaryMessenger: controller.binaryMessenger
    )
    
    notificationChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
      // Notification implementation pending native setup
      result(FlutterMethodNotImplemented)
    }
  }
  
  // MARK: - Push Notification Delegates
  
  override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    Messaging.messaging().apnsToken = deviceToken
  }
  
  override func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print("Failed to register for remote notifications: \(error)")
  }
}

// MARK: - MessagingDelegate
extension AppDelegate: MessagingDelegate {
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    guard let token = fcmToken else { return }
    print("FCM Token: \(token)")
    NotificationService.shared.handleFCMToken(token)
  }
}
