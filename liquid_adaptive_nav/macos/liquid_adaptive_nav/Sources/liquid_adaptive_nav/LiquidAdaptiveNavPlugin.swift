import Cocoa
import FlutterMacOS

public class LiquidAdaptiveNavPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "com.kauscoder.liquid_adaptive_nav/methods",
      binaryMessenger: registrar.messenger
    )
    let instance = LiquidAdaptiveNavPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result(FlutterMethodNotImplemented)
  }
}
