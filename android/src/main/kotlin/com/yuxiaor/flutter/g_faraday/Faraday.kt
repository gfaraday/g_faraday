package com.yuxiaor.flutter.g_faraday

import android.app.Activity
import android.content.Context
import android.content.Intent
import androidx.fragment.app.FragmentActivity
import com.yuxiaor.flutter.g_faraday.channels.CommonChannel
import com.yuxiaor.flutter.g_faraday.channels.FaradayNotice
import com.yuxiaor.flutter.g_faraday.channels.NetChannel
import com.yuxiaor.flutter.g_faraday.channels.NetHandler
import io.flutter.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel
import java.lang.ref.WeakReference
import java.util.concurrent.atomic.AtomicInteger

/**
 * Author: Edward
 * Date: 2020-08-31
 * Description:
 */
object Faraday {

    private val nextCode = AtomicInteger()

    @JvmStatic
    lateinit var engine: FlutterEngine
        private set

    internal var pluginRef: WeakReference<GFaradayPlugin>? = null
    internal val plugin: GFaradayPlugin?
        get() = pluginRef?.get()

    internal lateinit var navigator: FaradayNavigator

    /**
     *  init engine
     *
     *  @param context Application Context
     *  @param navigator handle native route
     *  @param automaticallyRegisterPlugins If plugins are automatically
     * registered, then they are registered during the execution of this constructor
     *
     *  @return true if plugins registered otherwise return false.
     *
     *  @sample
     *  if (!Faraday.initEngine(this, MyFlutterNavigator())) {
     *       GeneratedPluginRegister.registerGeneratedPlugins(Faraday.engine)
     *   }
     *
     */
    @JvmStatic
    fun initEngine(context: Context, navigator: FaradayNavigator, automaticallyRegisterPlugins: Boolean = true): Boolean {
        // 这个navigator 必须先初始化 不能动
        this.navigator = navigator
        engine = FlutterEngine(context, null, automaticallyRegisterPlugins)
        engine.dartExecutor.executeDartEntrypoint(DartExecutor.DartEntrypoint.createDefault())
        return pluginRef != null;
    }

    /**
     * To handle network form flutter on native side
     */
    @JvmStatic
    fun setNetHandler(handler: NetHandler) {
        NetChannel(engine.dartExecutor, handler)
    }

    /**
     * To handle common events form flutter
     */
    @JvmStatic
    fun setCommonHandler(handler: MethodChannel.MethodCallHandler) {
        CommonChannel(engine.dartExecutor, handler)
    }

    internal fun genPageId(): Int {
        return nextCode.getAndIncrement()
    }

    /**
     * The current flutter container Activity
     */
    @JvmStatic
    fun getCurrentActivity(): Activity? {
        return plugin?.binding?.activity
    }

    /**
     * start native Activity,and request for Activity result
     */
    fun startNativeForResult(intent: Intent, callback: (result: HashMap<String, Any?>?) -> Unit) {
        val code = nextCode.getAndIncrement()
        startNativeForResult(intent, code) { requestCode, resultCode, data ->
            if (requestCode == code && resultCode == Activity.RESULT_OK) {
                val map = hashMapOf<String, Any?>()
                data?.extras?.keySet()?.forEach {
                    map[it] = data.extras?.get(it)
                }
                callback.invoke(map)
            }
        }
    }

    @JvmStatic
    fun startNativeForResult(intent: Intent, requestCode: Int, callback: (requestCode: Int, resultCode: Int, data: Intent?) -> Unit) {
        val activity = getCurrentActivity()

        if (activity is ResultProvider) {
            activity.addResultListener(callback)
            activity.startActivityForResult(intent, requestCode)
            return
        }

        if (activity is FragmentActivity) {
            val frag = activity.supportFragmentManager.fragments.first { it.isVisible }
            if (frag is ResultProvider) {
                frag.addResultListener(callback)
                frag.startActivityForResult(intent, requestCode)
            }
        }
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
