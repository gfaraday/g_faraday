package com.yuxiaor.flutter.g_faraday

import android.app.Activity
import androidx.annotation.NonNull
import androidx.fragment.app.FragmentActivity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.Serializable

/** GFaradayPlugin */
class GFaradayPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

    private var channel: MethodChannel? = null
    private var navigator: FaradayNavigator? = null
    private var binding: ActivityPluginBinding? = null

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "getPlatformVersion" -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
            "pushNativePage" -> {
                val name = call.argument<String>("name")
                require(name != null) { "page route name should not be null" }
                val arguments = call.argument<Serializable>("arguments")
                val options = call.argument<HashMap<String, *>>("options")
                navigator?.push(name, arguments, options) { result.success(it) }
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
                navigator?.enableSwipeBack(!disable)
                result.success(null)
            }
            "reCreateLastPage" -> {
                when (val activity = Faraday.getCurrentActivity()) {
                    is FaradayActivity -> {
                        activity.createFlutterPage()
                    }
                    is FragmentActivity -> {
                        val fragment = activity.supportFragmentManager.fragments.first { it.isVisible }
                        if (fragment is FaradayFragment) {
                            fragment.createFlutterPage()
                        }
                    }
                }
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    fun getBindingActivity(): Activity? {
        return binding?.activity
    }

    internal fun onPageCreate(route: String, args: Any?, seq: Int?, callback: (seqId: Int) -> Unit) {
        val data = hashMapOf<String, Any>()
        data["name"] = route
        if (args != null) {
            data["args"] = args
        }
        data["seq"] = seq ?: -1
        channel?.invoke("pageCreate", data) {
            callback.invoke(it as Int)
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


    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        this.navigator = Faraday.navigator
        channel = MethodChannel(binding.binaryMessenger, "g_faraday")
        channel?.setMethodCallHandler(this)
        Faraday.onAttachPlugin(this, binding.binaryMessenger)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel?.setMethodCallHandler(null)
    }


    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        this.binding = binding
    }

    override fun onDetachedFromActivity() {
        this.binding = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    }

    override fun onDetachedFromActivityForConfigChanges() {
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