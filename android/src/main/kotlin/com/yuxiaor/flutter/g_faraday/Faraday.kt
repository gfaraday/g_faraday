package com.yuxiaor.flutter.g_faraday

import android.app.Activity
import android.content.Context
import android.content.Intent
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.atomic.AtomicInteger

/**
 * Author: Edward
 * Date: 2020-08-31
 * Description:
 */
object Faraday {

    private val nextCode = AtomicInteger()
    private val activityAwarePlugin = ActivityAwarePlugin()
    internal val faradayPlugin = GFaradayPlugin()

    @JvmStatic
    var engine: FlutterEngine? = null

    /**
     *  start engine
     */
    @JvmStatic
    fun initEngine(context: Context, navigator: FaradayNavigator) {
        engine = FlutterEngine(context)
        faradayPlugin.setNavigator(navigator)
        //注册插件
        registerPlugin(faradayPlugin)
        registerPlugin(activityAwarePlugin)
        //开始执行dart代码，启动引擎
        engine?.dartExecutor?.executeDartEntrypoint(DartExecutor.DartEntrypoint.createDefault())
    }

    /**
     * To handle network form flutter on native side
     */
    @JvmStatic
    fun setNetHandler(handler: MethodChannel.MethodCallHandler) {
        InternalChannels.setNetHandler(handler)
    }

    /**
     * To handle common events form flutter
     */
    @JvmStatic
    fun setCommonHandler(handler: MethodChannel.MethodCallHandler) {
        InternalChannels.setCommonHandler(handler)
    }

    /**
     * register channel
     */
    @JvmStatic
    fun registerChannel(channelName: String, handler: MethodChannel.MethodCallHandler): MethodChannel {
        return MethodChannel(engine?.dartExecutor, channelName).apply {
            setMethodCallHandler(handler)
        }
    }

    /**
     * register plugin
     */
    @JvmStatic
    fun registerPlugin(plugin: FlutterPlugin) {
        engine?.plugins?.add(plugin)
    }

    /**
     * The current flutter container Activity
     */
    @JvmStatic
    fun getCurrentActivity(): Activity? {
        return activityAwarePlugin.binding?.activity
    }

    /**
     * start native Activity,and request for Activity result
     */
    fun startNativeForResult(intent: Intent, callback: (result: HashMap<String, Any?>?) -> Unit) {
        val nextRequestCode = nextCode.getAndIncrement()
        getCurrentActivity()?.startActivityForResult(intent, nextRequestCode)
        ResultListener(activityAwarePlugin) { requestCode, resultCode, data ->
            if (requestCode == nextRequestCode && resultCode == Activity.RESULT_OK) {
                val map = hashMapOf<String, Any?>()
                data?.extras?.keySet()?.forEach {
                    map[it] = data.extras?.get(it)
                }
                callback.invoke(map)
            }
        }
    }

    fun startNativeForResult(intent: Intent, callback: (resultCode: Int, data: Intent?) -> Unit) {
        val nextRequestCode = nextCode.getAndIncrement()
        getCurrentActivity()?.startActivityForResult(intent, nextRequestCode)
        ResultListener(activityAwarePlugin) { requestCode, resultCode, data ->
            if (requestCode == nextRequestCode) {
                callback.invoke(resultCode, data)
            }
        }
    }

    /**
     *  open flutter page
     */
    @JvmStatic
    fun openFlutter(context: Context, routeName: String, params: HashMap<String, Any>? = null) {
        context.startActivity(FaradayActivity.build(context, routeName, params))
    }

    /**
     *  open flutter page,and request for result
     */
    @JvmStatic
    fun openFlutterForResult(activity: Activity, routeName: String, requestCode: Int, params: HashMap<String, Any>? = null) {
        activity.startActivityForResult(FaradayActivity.build(activity, routeName, params), requestCode)
    }


    /**
     * post notification  form native to flutter
     */
    fun postNotification(key: String, arguments: Any?) {
        FaradayNotice.post(key, arguments)
    }

    /**
     * receive notification from flutter
     */
    fun registerNotification(key: String, callback: (arguments: Any?) -> Unit) {
        FaradayNotice.register(key, callback)
    }

    fun unregisterNotification(key: String) {
        FaradayNotice.unregister(key)
    }

}
