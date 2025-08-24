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
      if #available(iOS 16.1, *) {
        DynamicIslandManager.shared.handleMethodCall(call, result: result)
      } else {
        result(FlutterError(code: "UNSUPPORTED", message: "Dynamic Island requires iOS 16.1+", details: nil))
      }
    }
  }
  
  private func setupPushNotifications(_ application: UIApplication) {
    // Initialize Firebase
    FirebaseApp.configure()
    
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
      switch call.method {
      case "requestPermission":
        NotificationService.shared.registerForPushNotifications()
        result(true)
      case "scheduleNotification":
        if let args = call.arguments as? [String: Any],
           let title = args["title"] as? String,
           let body = args["body"] as? String {
          NotificationService.shared.scheduleLocalNotification(
            title: title,
            body: body,
            identifier: UUID().uuidString
          )
          result(true)
        } else {
          result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
        }
      case "clearNotifications":
        NotificationService.shared.clearAllNotifications()
        result(true)
      default:
        result(FlutterMethodNotImplemented)
      }
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
