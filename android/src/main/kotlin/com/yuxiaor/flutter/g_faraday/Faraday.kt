package com.yuxiaor.flutter.g_faraday

import android.app.Activity
import android.content.Context
import android.content.Intent
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.atomic.AtomicInteger

/**
 * Author: Edward
 * Date: 2020-08-31
 * Description:
 */
object Faraday {

    private val nextCode = AtomicInteger()

    @JvmStatic
    internal lateinit var engine: FlutterEngine
        private set

    internal val plugin: GFaradayPlugin by lazy {
        engine.plugins.get(GFaradayPlugin::class.java) as GFaradayPlugin
    }

    /**
     *  init engine
     */
    @JvmStatic
    fun initEngine(context: Context, navigator: FaradayNavigator) {
        engine = FlutterEngine(context)
        plugin.setup(navigator)
        engine.dartExecutor.executeDartEntrypoint(DartExecutor.DartEntrypoint.createDefault())
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
     * The current flutter container Activity
     */
    @JvmStatic
    fun getCurrentActivity(): Activity? {
        return plugin.binding?.activity
    }

    /**
     * start native Activity,and request for Activity result
     */
    fun startNativeForResult(intent: Intent, callback: (result: HashMap<String, Any?>?) -> Unit) {
        val nextRequestCode = nextCode.getAndIncrement()
        getCurrentActivity()?.startActivityForResult(intent, nextRequestCode)
        ResultListener { requestCode, resultCode, data ->
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
        ResultListener { requestCode, resultCode, data ->
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
