import Flutter
import UIKit

public class BlurhashFfiPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "blurhash_ffi", binaryMessenger: registrar.messenger())
    let instance = BlurhashFfiPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  public static func dummyMethodToEnforceBundling() {
      blurhash_decode([UInt8](), 0, 0, 0, 0)
      blurhash_encode(0, 0, 0, 0, [UInt8](), 0)
  }
}
