import Foundation
import ActivityKit
import SwiftUI
import WidgetKit
import Flutter

// MARK: - Live Activity Manager
@available(iOS 16.1, *)
class LiveActivityManager: NSObject {
    static let shared = LiveActivityManager()
    
    // Active activities tracking
    private var widgetCreationActivity: Activity<WidgetCreationAttributes>?
    private var portfolioActivity: Activity<PortfolioActivityAttributes>?
    private var analysisActivity: Activity<AnalysisActivityAttributes>?
    
    // MARK: - Widget Creation Live Activity
    
    func startWidgetCreationActivity(prompt: String, username: String) throws {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            throw LiveActivityError.notEnabled
        }
        
        let attributes = WidgetCreationAttributes(
            widgetTitle: "Creating Widget",
            username: username
        )
        
        let initialState = WidgetCreationAttributes.ContentState(
            status: "Analyzing your prompt...",
            progress: 0.1,
            icon: "wand.and.stars",
            color: "blue"
        )
        
        let activity = try Activity<WidgetCreationAttributes>.request(
            attributes: attributes,
            contentState: initialState,
            pushType: nil
        )
        
        widgetCreationActivity = activity
        print("Started Widget Creation Live Activity: \(activity.id)")
    }
    
    func updateWidgetCreationProgress(stage: String, progress: Double, detail: String? = nil) async {
        guard let activity = widgetCreationActivity else { return }
        
        let (status, icon, color) = getStageDetails(stage: stage, detail: detail, progress: progress)
        
        let updatedState = WidgetCreationAttributes.ContentState(
            status: status,
            progress: progress,
            icon: icon,
            color: color
        )
        
        await activity.update(using: updatedState)
    }
    
    func endWidgetCreationActivity(success: Bool, widgetTitle: String? = nil) async {
        guard let activity = widgetCreationActivity else { return }
        
        let finalState = WidgetCreationAttributes.ContentState(
            status: success ? "Widget Created: \(widgetTitle ?? "Success")!" : "Creation Failed",
            progress: 1.0,
            icon: success ? "checkmark.circle.fill" : "xmark.circle.fill",
            color: success ? "green" : "red"
        )
        
        await activity.end(using: finalState, dismissalPolicy: .after(Date().addingTimeInterval(5)))
        widgetCreationActivity = nil
    }
    
    // MARK: - Portfolio Live Activity
    
    func startPortfolioActivity(portfolioName: String, username: String, initialValue: Double) throws {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            throw LiveActivityError.notEnabled
        }
        
        let attributes = PortfolioActivityAttributes(
            portfolioName: portfolioName,
            username: username
        )
        
        let initialState = PortfolioActivityAttributes.ContentState(
            totalValue: initialValue,
            dayChange: 0,
            percentChange: 0,
            isPositive: true,
            lastUpdate: Date()
        )
        
        let activity = try Activity<PortfolioActivityAttributes>.request(
            attributes: attributes,
            contentState: initialState,
            pushType: .token
        )
        
        portfolioActivity = activity
        print("Started Portfolio Live Activity: \(activity.id)")
    }
    
    func updatePortfolioValue(totalValue: Double, dayChange: Double, percentChange: Double) async {
        guard let activity = portfolioActivity else { return }
        
        let updatedState = PortfolioActivityAttributes.ContentState(
            totalValue: totalValue,
            dayChange: dayChange,
            percentChange: percentChange,
            isPositive: dayChange >= 0,
            lastUpdate: Date()
        )
        
        await activity.update(using: updatedState)
    }
    
    func endPortfolioActivity() async {
        guard let activity = portfolioActivity else { return }
        
        let finalState = PortfolioActivityAttributes.ContentState(
            totalValue: activity.contentState.totalValue,
            dayChange: activity.contentState.dayChange,
            percentChange: activity.contentState.percentChange,
            isPositive: activity.contentState.isPositive,
            lastUpdate: Date()
        )
        
        await activity.end(using: finalState, dismissalPolicy: .immediate)
        portfolioActivity = nil
    }
    
    // MARK: - Analysis Live Activity
    
    func startAnalysisActivity(analysisType: String, username: String, totalFiles: Int) throws {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            throw LiveActivityError.notEnabled
        }
        
        let attributes = AnalysisActivityAttributes(
            analysisType: analysisType,
            username: username
        )
        
        let initialState = AnalysisActivityAttributes.ContentState(
            status: "Uploading files...",
            progress: 0.0,
            filesProcessed: 0,
            totalFiles: totalFiles
        )
        
        let activity = try Activity<AnalysisActivityAttributes>.request(
            attributes: attributes,
            contentState: initialState,
            pushType: nil
        )
        
        analysisActivity = activity
        print("Started Analysis Live Activity: \(activity.id)")
    }
    
    func updateAnalysisProgress(status: String, filesProcessed: Int, totalFiles: Int) async {
        guard let activity = analysisActivity else { return }
        
        let progress = totalFiles > 0 ? Double(filesProcessed) / Double(totalFiles) : 0.0
        
        let updatedState = AnalysisActivityAttributes.ContentState(
            status: status,
            progress: progress,
            filesProcessed: filesProcessed,
            totalFiles: totalFiles
        )
        
        await activity.update(using: updatedState)
    }
    
    func endAnalysisActivity(success: Bool, resultMessage: String? = nil) async {
        guard let activity = analysisActivity else { return }
        
        let finalState = AnalysisActivityAttributes.ContentState(
            status: success ? (resultMessage ?? "Analysis Complete!") : "Analysis Failed",
            progress: 1.0,
            filesProcessed: activity.contentState.totalFiles,
            totalFiles: activity.contentState.totalFiles
        )
        
        await activity.end(using: finalState, dismissalPolicy: .after(Date().addingTimeInterval(5)))
        analysisActivity = nil
    }
    
    // MARK: - Helper Methods
    
    private func getStageDetails(stage: String, detail: String?, progress: Double) -> (status: String, icon: String, color: String) {
        switch stage {
        case "analyzing":
            return (detail ?? "Analyzing your request...", "waveform", "blue")
        case "generating":
            return (detail ?? "Generating widget...", "sparkles", "purple")
        case "optimizing":
            return (detail ?? "Optimizing design...", "paintbrush.fill", "orange")
        case "finalizing":
            return (detail ?? "Finalizing widget...", "checkmark.circle", "green")
        case "complete":
            return (detail ?? "Widget created!", "checkmark.circle.fill", "green")
        case "error":
            return (detail ?? "An error occurred", "xmark.circle.fill", "red")
        default:
            return (detail ?? "Processing...", "gear", "blue")
        }
    }
    
    func endAllActivities() async {
        // End all active activities
        for activity in Activity<WidgetCreationAttributes>.activities {
            await activity.end(dismissalPolicy: .immediate)
        }
        for activity in Activity<PortfolioActivityAttributes>.activities {
            await activity.end(dismissalPolicy: .immediate)
        }
        for activity in Activity<AnalysisActivityAttributes>.activities {
            await activity.end(dismissalPolicy: .immediate)
        }
        
        widgetCreationActivity = nil
        portfolioActivity = nil
        analysisActivity = nil
    }
    
    // MARK: - Flutter Platform Channel Handler
    
    func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }
        
        Task {
            do {
                switch call.method {
                case "startWidgetCreation":
                    let prompt = args["prompt"] as? String ?? ""
                    let username = args["username"] as? String ?? "User"
                    try startWidgetCreationActivity(prompt: prompt, username: username)
                    result(true)
                    
                case "updateWidgetCreation":
                    let stage = args["stage"] as? String ?? "processing"
                    let progress = args["progress"] as? Double ?? 0.0
                    let detail = args["detail"] as? String
                    await updateWidgetCreationProgress(stage: stage, progress: progress, detail: detail)
                    result(true)
                    
                case "endWidgetCreation":
                    let success = args["success"] as? Bool ?? false
                    let widgetTitle = args["widgetTitle"] as? String
                    await endWidgetCreationActivity(success: success, widgetTitle: widgetTitle)
                    result(true)
                    
                case "startPortfolio":
                    let portfolioName = args["portfolioName"] as? String ?? "My Portfolio"
                    let username = args["username"] as? String ?? "User"
                    let initialValue = args["initialValue"] as? Double ?? 0.0
                    try startPortfolioActivity(portfolioName: portfolioName, username: username, initialValue: initialValue)
                    result(true)
                    
                case "updatePortfolio":
                    let totalValue = args["totalValue"] as? Double ?? 0.0
                    let dayChange = args["dayChange"] as? Double ?? 0.0
                    let percentChange = args["percentChange"] as? Double ?? 0.0
                    await updatePortfolioValue(totalValue: totalValue, dayChange: dayChange, percentChange: percentChange)
                    result(true)
                    
                case "endPortfolio":
                    await endPortfolioActivity()
                    result(true)
                    
                case "startAnalysis":
                    let analysisType = args["analysisType"] as? String ?? "Document Analysis"
                    let username = args["username"] as? String ?? "User"
                    let totalFiles = args["totalFiles"] as? Int ?? 1
                    try startAnalysisActivity(analysisType: analysisType, username: username, totalFiles: totalFiles)
                    result(true)
                    
                case "updateAnalysis":
                    let status = args["status"] as? String ?? "Processing..."
                    let filesProcessed = args["filesProcessed"] as? Int ?? 0
                    let totalFiles = args["totalFiles"] as? Int ?? 1
                    await updateAnalysisProgress(status: status, filesProcessed: filesProcessed, totalFiles: totalFiles)
                    result(true)
                    
                case "endAnalysis":
                    let success = args["success"] as? Bool ?? false
                    let resultMessage = args["resultMessage"] as? String
                    await endAnalysisActivity(success: success, resultMessage: resultMessage)
                    result(true)
                    
                case "endAllActivities":
                    await endAllActivities()
                    result(true)
                    
                default:
                    result(FlutterMethodNotImplemented)
                }
            } catch {
                result(FlutterError(code: "LIVE_ACTIVITY_ERROR", message: error.localizedDescription, details: nil))
            }
        }
    }
}

// MARK: - Error Types

enum LiveActivityError: LocalizedError {
    case notEnabled
    case notSupported
    case invalidParameters
    
    var errorDescription: String? {
        switch self {
        case .notEnabled:
            return "Live Activities are not enabled. Please enable them in Settings."
        case .notSupported:
            return "Live Activities require iOS 16.1 or later."
        case .invalidParameters:
            return "Invalid parameters provided for Live Activity."
        }
    }
}