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
    private var navigator: FaradayNavigator? = null

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

    fun setNavigator(navigator: FaradayNavigator) {
        this.navigator = navigator
    }


    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "getPlatformVersion" -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
            "pushNativePage" -> {
                val name = call.argument<String>("name")
                require(name != null) { "page route name should not be null" }
                navigator?.push(name, call.argument("arguments")) { result.success(it) }
            }
            "popContainer" -> {
                val arg = call.arguments
                navigator?.pop(arg as? Serializable)
                if (arg != null && arg !is Serializable) {
                    print("=========返回值丢失，返回值类型 $arg")
                }
                result.success(null)
            }
            "disableHorizontalSwipePopGesture" -> {
                val disable = call.arguments as? Boolean ?: false
                print(if (!disable) "enable" else "disable" + " Horizontal Swipe PopGesture")
                navigator?.onSwipeBack(!disable)
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    internal fun onPageCreate(route: String, args: Any?, callback: (seqId: Int) -> Unit) {
        val data = hashMapOf<String, Any>()
        data["name"] = route
        if (args != null) {
            data["arguments"] = args
        }
        channel?.invoke("pageCreate", data) {
            val seqId = it as Int
            callback.invoke(seqId)
        }
    }

    internal fun onPageShow(seqId: Int) {
        channel?.invokeMethod("pageShow", seqId)
    }

    internal fun onPageHidden(seqId: Int) {
        channel?.invokeMethod("pageHidden", seqId)
    }

    internal fun onPageDealloc(seqId: Int) {
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
