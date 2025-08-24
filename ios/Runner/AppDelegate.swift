import Flutter
import UIKit
import ActivityKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // Setup Dynamic Island channel
    setupDynamicIslandChannel()
    
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
}
