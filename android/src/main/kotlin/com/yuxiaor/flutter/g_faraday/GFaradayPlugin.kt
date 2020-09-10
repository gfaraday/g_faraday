package com.yuxiaor.flutter.g_faraday

import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import java.io.Serializable

/** GFaradayPlugin */
class GFaradayPlugin : FlutterPlugin, MethodCallHandler {
    private var channel: MethodChannel? = null

    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), "g_faraday")
            channel.setMethodCallHandler(GFaradayPlugin())

        }
    }

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.flutterEngine.dartExecutor, "g_faraday")
        channel?.setMethodCallHandler(this)
    }


    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "getPlatformVersion" -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
            "pushNativePage" -> {
                val name = call.argument<String>("name")
                require(name != null) { "page route name should not be null" }
                Faraday.navigator?.push(name, call.argument("arguments")) { result.success(it) }
            }
            "popContainer" -> {
                val arg = call.arguments
                Faraday.navigator?.pop(arg as? Serializable)
                if (arg != null && arg !is Serializable) {
                    print("=========返回值丢失，返回值类型 $arg")
                }
                result.success(null)
            }
            "disableHorizontalSwipePopGesture" -> {
                val disable = call.arguments as? Boolean ?: false
                print(if (!disable) "enable" else "disable" + " Horizontal Swipe PopGesture")
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    fun onPageCreate(args: Any?, callback: (seqId: Int) -> Unit) {
        channel?.invoke("pageCreate", args) {
            val seqId = it as Int
            callback.invoke(seqId)
        }
    }

    fun onPageShow(seqId: Int) {
        channel?.invokeMethod("pageShow", seqId)
    }

    fun onPageHidden(seqId: Int) {
        channel?.invokeMethod("pageHidden", seqId)
    }

    fun onPageDealloc(seqId: Int) {
        channel?.invokeMethod("pageDealloc", seqId)
    }


    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel?.setMethodCallHandler(null)
    }


    private fun MethodChannel.invoke(method: String, arguments: Any?, callback: ((result: Any?) -> Unit)? = null) {
        invokeMethod(method, arguments, object : Result {

            override fun notImplemented() {
            }

            override fun error(errorCode: String?, errorMessage: String?, errorDetails: Any?) {
            }

            override fun success(result: Any?) {
                callback?.invoke(result)
            }
        })
    }
}
