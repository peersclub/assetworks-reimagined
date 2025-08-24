import Foundation
import ActivityKit
import SwiftUI
import WidgetKit

// MARK: - Activity Attributes
struct WidgetCreationAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var status: String
        var progress: Double
        var icon: String
        var color: String
    }
    
    var widgetTitle: String
    var username: String
}

// MARK: - Dynamic Island Manager
@available(iOS 16.1, *)
class DynamicIslandManager: NSObject {
    static let shared = DynamicIslandManager()
    private var currentActivity: Activity<WidgetCreationAttributes>?
    
    // Start a new Live Activity
    func startActivity(title: String, username: String, status: String, progress: Double) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        
        let attributes = WidgetCreationAttributes(
            widgetTitle: title,
            username: username
        )
        
        let contentState = WidgetCreationAttributes.ContentState(
            status: status,
            progress: progress,
            icon: "wand.and.stars",
            color: "blue"
        )
        
        do {
            let activity = try Activity<WidgetCreationAttributes>.request(
                attributes: attributes,
                contentState: contentState,
                pushType: nil
            )
            currentActivity = activity
            print("Started Live Activity: \(activity.id)")
        } catch {
            print("Failed to start Live Activity: \(error)")
        }
    }
    
    // Update existing Live Activity
    func updateActivity(status: String, progress: Double, icon: String = "wand.and.stars") {
        Task {
            guard let activity = currentActivity else { return }
            
            let updatedState = WidgetCreationAttributes.ContentState(
                status: status,
                progress: progress,
                icon: icon,
                color: progress >= 1.0 ? "green" : "blue"
            )
            
            await activity.update(using: updatedState)
        }
    }
    
    // End Live Activity
    func endActivity(finalStatus: String) {
        Task {
            guard let activity = currentActivity else { return }
            
            let finalState = WidgetCreationAttributes.ContentState(
                status: finalStatus,
                progress: 1.0,
                icon: "checkmark.circle.fill",
                color: "green"
            )
            
            await activity.end(using: finalState, dismissalPolicy: .after(Date().addingTimeInterval(5)))
            currentActivity = nil
        }
    }
    
    // Clear all activities
    func clearAllActivities() {
        Task {
            for activity in Activity<WidgetCreationAttributes>.activities {
                await activity.end(dismissalPolicy: .immediate)
            }
            currentActivity = nil
        }
    }
}

// MARK: - Flutter Platform Channel Handler
@available(iOS 16.1, *)
extension DynamicIslandManager {
    func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }
        
        switch call.method {
        case "initialize":
            result(true)
            
        case "startLiveActivity":
            if let type = args["type"] as? String,
               let data = args["data"] as? [String: Any] {
                let title = data["title"] as? String ?? "Widget Creation"
                let username = data["username"] as? String ?? "User"
                let status = data["status"] as? String ?? "Starting..."
                let progress = data["progress"] as? Double ?? 0.0
                
                startActivity(title: title, username: username, status: status, progress: progress)
                result(true)
            } else {
                result(FlutterError(code: "MISSING_DATA", message: "Missing activity data", details: nil))
            }
            
        case "updateLiveActivity":
            if let data = args["data"] as? [String: Any] {
                let status = data["status"] as? String ?? ""
                let progress = data["progress"] as? Double ?? 0.0
                let icon = data["icon"] as? String ?? "wand.and.stars"
                
                updateActivity(status: status, progress: progress, icon: icon)
                result(true)
            } else {
                result(FlutterError(code: "MISSING_DATA", message: "Missing update data", details: nil))
            }
            
        case "endLiveActivity":
            let finalStatus = args["status"] as? String ?? "Complete!"
            endActivity(finalStatus: finalStatus)
            result(true)
            
        case "updateStatus":
            if let status = args["status"] as? String {
                updateActivity(status: status, progress: 0.5)
                result(true)
            } else {
                result(FlutterError(code: "MISSING_STATUS", message: "Status is required", details: nil))
            }
            
        case "showProgress":
            if let task = args["task"] as? String,
               let progress = args["progress"] as? Double {
                updateActivity(status: task, progress: progress)
                result(true)
            } else {
                result(FlutterError(code: "MISSING_DATA", message: "Task and progress required", details: nil))
            }
            
        case "showNotification":
            // This would trigger a notification-style update
            if let title = args["title"] as? String,
               let body = args["body"] as? String {
                updateActivity(status: "\(title): \(body)", progress: 0.0, icon: "bell.fill")
                result(true)
            } else {
                result(FlutterError(code: "MISSING_DATA", message: "Title and body required", details: nil))
            }
            
        case "clear":
            clearAllActivities()
            result(true)
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}