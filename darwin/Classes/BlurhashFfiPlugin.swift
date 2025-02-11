#if os(iOS)
  import Flutter
#elseif os(macOS)
  import FlutterMacOS
#else
  #error("Unsupported platform.")
#endif

public class BlurhashFfiPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {

  }

  public static func dummyMethodToEnforceBundling() {
      blurhash_decode([UInt8](), 0, 0, 0, 0)
      blurhash_encode(0, 0, 0, 0, [UInt8](), 0)
  }
}
