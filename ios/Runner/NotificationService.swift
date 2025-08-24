import Foundation
import UserNotifications
import Firebase
import FirebaseMessaging

class NotificationService: NSObject {
    static let shared = NotificationService()
    
    // Register for push notifications
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { granted, error in
                print("Push Notification permission granted: \(granted)")
                if let error = error {
                    print("Error requesting notification permissions: \(error)")
                }
            }
        )
        
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    // Handle FCM token
    func handleFCMToken(_ token: String) {
        print("FCM Token: \(token)")
        // Send token to your backend
        sendTokenToBackend(token)
    }
    
    private func sendTokenToBackend(_ token: String) {
        // Call Flutter method channel to send token to backend via API
        guard let flutterViewController = UIApplication.shared.windows.first?.rootViewController as? FlutterViewController else { return }
        
        let channel = FlutterMethodChannel(
            name: "ai.assetworks.notifications",
            binaryMessenger: flutterViewController.binaryMessenger
        )
        
        channel.invokeMethod("updateFCMToken", arguments: ["token": token])
    }
    
    // Schedule local notification
    func scheduleLocalNotification(
        title: String,
        body: String,
        identifier: String,
        timeInterval: TimeInterval = 5
    ) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: timeInterval,
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    // Clear all notifications
    func clearAllNotifications() {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    // Handle notification actions
    func setupNotificationCategories() {
        // Action for widget notifications
        let viewAction = UNNotificationAction(
            identifier: "VIEW_WIDGET",
            title: "View Widget",
            options: [.foreground]
        )
        
        let likeAction = UNNotificationAction(
            identifier: "LIKE_WIDGET",
            title: "Like",
            options: []
        )
        
        let dismissAction = UNNotificationAction(
            identifier: "DISMISS",
            title: "Dismiss",
            options: [.destructive]
        )
        
        // Category for widget notifications
        let widgetCategory = UNNotificationCategory(
            identifier: "WIDGET_NOTIFICATION",
            actions: [viewAction, likeAction, dismissAction],
            intentIdentifiers: [],
            options: []
        )
        
        // Category for follow notifications
        let followCategory = UNNotificationCategory(
            identifier: "FOLLOW_NOTIFICATION",
            actions: [viewAction, dismissAction],
            intentIdentifiers: [],
            options: []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([
            widgetCategory,
            followCategory
        ])
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension NotificationService: UNUserNotificationCenterDelegate {
    
    // Handle notification when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .sound, .badge])
        } else {
            completionHandler([.alert, .sound, .badge])
        }
    }
    
    // Handle notification tap
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        
        // Handle different action identifiers
        switch response.actionIdentifier {
        case "VIEW_WIDGET":
            handleViewWidget(userInfo: userInfo)
        case "LIKE_WIDGET":
            handleLikeWidget(userInfo: userInfo)
        case UNNotificationDefaultActionIdentifier:
            handleDefaultAction(userInfo: userInfo)
        default:
            break
        }
        
        completionHandler()
    }
    
    private func handleViewWidget(userInfo: [AnyHashable: Any]) {
        if let widgetId = userInfo["widget_id"] as? String {
            // Navigate to widget via Flutter
            notifyFlutter(method: "openWidget", arguments: ["widgetId": widgetId])
        }
    }
    
    private func handleLikeWidget(userInfo: [AnyHashable: Any]) {
        if let widgetId = userInfo["widget_id"] as? String {
            // Like widget via Flutter
            notifyFlutter(method: "likeWidget", arguments: ["widgetId": widgetId])
        }
    }
    
    private func handleDefaultAction(userInfo: [AnyHashable: Any]) {
        // Handle default notification tap
        notifyFlutter(method: "notificationTapped", arguments: userInfo)
    }
    
    private func notifyFlutter(method: String, arguments: Any?) {
        guard let flutterViewController = UIApplication.shared.windows.first?.rootViewController as? FlutterViewController else { return }
        
        let channel = FlutterMethodChannel(
            name: "ai.assetworks.notifications",
            binaryMessenger: flutterViewController.binaryMessenger
        )
        
        channel.invokeMethod(method, arguments: arguments)
    }
}