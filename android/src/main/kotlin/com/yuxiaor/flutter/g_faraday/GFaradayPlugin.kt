package com.yuxiaor.flutter.g_faraday

import android.util.Log
import androidx.annotation.NonNull
import androidx.fragment.app.FragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.Serializable
import java.lang.ref.WeakReference

fun FlutterEngine.gFaradayPlugin(): GFaradayPlugin? {
    return plugins.get(GFaradayPlugin::class.java) as? GFaradayPlugin
}

/** GFaradayPlugin */
class GFaradayPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

    companion object {
        private const val TAG = "GFaradayPlugin"
    }

    private lateinit var channel: MethodChannel

    private val navigator: FaradayNavigator
        get() = Faraday.navigator

    internal var binding: ActivityPluginBinding? = null

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        Log.d(TAG, "onMethodCall: ${call.method}")
        //
        when (call.method) {
            "pushNativePage" -> {
                val name = call.argument<String>("name")
                require(name != null) { "page route name should not be null" }
                val arguments = call.argument<Serializable>("arguments")
                val options = call.argument<HashMap<String, *>>("options")
                navigator.create(name, arguments, Options(options))?.let {
                    Faraday.startNativeForResult(it) { nativeResult ->
                        result.success(nativeResult)
                    }
                }
            }
            "popContainer" -> {
                val arg = call.arguments
                navigator.pop(arg as? Serializable)
                if (arg != null && arg !is Serializable) {
                    print("=========返回值丢失，返回值类型 $arg")
                }
                result.success(null)
            }
            "disableHorizontalSwipePopGesture" -> {
                val disable = call.arguments as? Boolean ?: false
                print(if (!disable) "enable" else "disable" + " Horizontal Swipe PopGesture")
                navigator.enableSwipeBack(!disable)
                result.success(null)
            }
            "reCreateLastPage" -> {
                Faraday.getCurrentContainer()?.rebuildFlutterPage()
                result.success(true)
            }
            else -> result.notImplemented()
        }
    }

    internal fun onPageCreate(route: String, args: Serializable?, id: Int, backgroundMode: String) {
        val data = hashMapOf<String, Any>()
        data["name"] = route
        if (args != null) {
            data["args"] = args
        }
        data["id"] = id
        data["background_mode"] = backgroundMode
        channel.invokeMethod("pageCreate", data, object: Result {
            override fun success(result: Any?) {
                print(result)
            }

            override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                print(errorMessage)
            }

            override fun notImplemented() {
                print("notImplemented")
            }

        })
    }

    internal fun onPageShow(seqId: Int) {
        channel.invokeMethod("pageShow", seqId)
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
        channel = MethodChannel(binding.binaryMessenger, "g_faraday")
        channel.resizeChannelBuffer(2)
        channel.setMethodCallHandler(this)
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    }

    override fun onDetachedFromActivity() {
        this.binding = null
    }

    override fun onDetachedFromActivityForConfigChanges() {
    }
}