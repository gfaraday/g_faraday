package com.yuxiaor.flutter.g_faraday

import androidx.annotation.NonNull
import androidx.fragment.app.FragmentActivity
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.Serializable
import java.lang.ref.WeakReference

/** GFaradayPlugin */
class GFaradayPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

    private lateinit var channel: MethodChannel

    private var navigator: FaradayNavigator? = null
    internal var binding: ActivityPluginBinding? = null

    private  var pageCount = 0;

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
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

    internal fun onPageCreate(route: String, args: Any?, seq: Int?, callback: (seqId: Int) -> Unit) {
        val data = hashMapOf<String, Any>()
        data["name"] = route
        if (args != null) {
            data["args"] = args
        }
        data["seq"] = seq ?: -1
        pageCount++
        channel.invoke("pageCreate", data) {
            callback.invoke(it as Int)
        }
    }

    internal fun onPageShow(seqId: Int) {
        channel.invokeMethod("pageShow", seqId)
    }

    internal fun onPageDealloc(seqId: Int) {
        pageCount--
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
        channel.setMethodCallHandler(this);
        this.navigator = Faraday.navigator
        Faraday.pluginRef = WeakReference(this)
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