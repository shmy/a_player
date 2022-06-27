package tech.shmy.a_player

import android.content.Context
import androidx.annotation.NonNull
import com.aliyun.player.AliPlayerGlobalSettings

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.view.TextureRegistry

/** APlayerPlugin */
class APlayerPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var textureRegistry: TextureRegistry
  private lateinit var binaryMessenger: BinaryMessenger
  private lateinit var context: Context

  init {
    AliPlayerGlobalSettings.setUseHttp2(true);
  }
  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, METHOD_CHANNEL_NAME)
    channel.setMethodCallHandler(this)
    textureRegistry = flutterPluginBinding.textureRegistry
    binaryMessenger = flutterPluginBinding.binaryMessenger
    context = flutterPluginBinding.applicationContext
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "initialize" -> {
        val textureEntry: TextureRegistry.SurfaceTextureEntry = textureRegistry.createSurfaceTexture()
        APlayer(context = context, textureEntry = textureEntry, binaryMessenger = binaryMessenger)
        result.success(textureEntry.id())
      }
      else -> result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
