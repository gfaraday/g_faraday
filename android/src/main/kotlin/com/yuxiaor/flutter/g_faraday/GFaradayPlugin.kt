package com.yuxiaor.flutter.g_faraday

import android.content.Intent
import androidx.annotation.NonNull
import androidx.fragment.app.FragmentActivity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import java.io.Serializable

/** GFaradayPlugin */
class GFaradayPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

    private val channel by lazy {
        MethodChannel(Faraday.engine.dartExecutor, "g_faraday").apply {
            setMethodCallHandler(this@GFaradayPlugin)
        }
    }

    private var navigator: FaradayNavigator? = null
    internal var binding: ActivityPluginBinding? = null

    fun setup(navigator: FaradayNavigator) {
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

    internal fun onPageCreate(route: String, args: Any?, seq: Int?, callback: (seqId: Int) -> Unit) {
        val data = hashMapOf<String, Any>()
        data["name"] = route
        if (args != null) {
            data["args"] = args
        }
        data["seq"] = seq ?: -1
        channel.invoke("pageCreate", data) {
            callback.invoke(it as Int)
        }
    }

    internal fun onPageShow(seqId: Int) {
        channel.invokeMethod("pageShow", seqId)
    }

    internal fun onPageHidden(seqId: Int) {
        channel.invokeMethod("pageHidden", seqId)
    }

    internal fun onPageDealloc(seqId: Int) {
        channel.invokeMethod("pageDealloc", seqId)
    }


    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }


    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        this.binding = binding
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    }


    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    }

    override fun onDetachedFromActivity() {
        this.binding = null
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


class ResultListener(private val callback: (requestCode: Int, resultCode: Int, data: Intent?) -> Unit) : PluginRegistry.ActivityResultListener {

    init {
        Faraday.plugin.binding?.addActivityResultListener(this)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        callback.invoke(requestCode, resultCode, data)
        Faraday.plugin.binding?.removeActivityResultListener(this)
        return false
    }

}