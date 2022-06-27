import Flutter
import UIKit
import AliyunPlayer

public class SwiftAPlayerPlugin: NSObject, FlutterPlugin {
  private var registrar: FlutterPluginRegistrar!
  override init() {
    AliPlayerGlobalSettings.setUseHttp2(true)
    super.init()
  }
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: METHOD_CHANNEL_NAME, binaryMessenger: registrar.messenger())
    let instance = SwiftAPlayerPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    instance.registrar = registrar
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
      if (call.method == "initialize") {
          let textureId: Int64 = APlayer.init(registrar: registrar).textureId()
         result(textureId)
      } else {
          result(FlutterMethodNotImplemented)
      }
  }
}
