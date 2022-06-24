import Flutter
import UIKit

public class SwiftAPlayerPlugin: NSObject, FlutterPlugin {
  private var registrar: FlutterPluginRegistrar!
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "a_player", binaryMessenger: registrar.messenger())
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
