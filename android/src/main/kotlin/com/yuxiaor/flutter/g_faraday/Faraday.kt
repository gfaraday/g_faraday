package com.yuxiaor.flutter.g_faraday

import android.app.Activity
import android.content.Context
import android.content.Intent
import androidx.fragment.app.FragmentActivity
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
    internal var pluginRef: WeakReference<GFaradayPlugin>? = null
    internal val plugin: GFaradayPlugin?
        get() = pluginRef?.get()

    internal lateinit var navigator: FaradayNavigator
    internal var netHandler: MethodChannel.MethodCallHandler? = null
    internal var commonHandler: MethodChannel.MethodCallHandler? = null

    fun init(navigator: FaradayNavigator, netHandler: MethodChannel.MethodCallHandler? = null, commonHandler: MethodChannel.MethodCallHandler? = null) {
        this.navigator = navigator
        this.netHandler = netHandler
        this.commonHandler = commonHandler
    }

//    internal fun provideEngine(context: Context): FlutterEngine {
//        val engine = FlutterEngine(context, null, true)
//        registerPlugins(engine)
//        engine.dartExecutor.executeDartEntrypoint(DartExecutor.DartEntrypoint.createDefault())
//        return engine
//    }

    internal fun registerPlugins(engine: FlutterEngine) {
        try {
            val generatedPluginRegistrant = Class.forName("io.flutter.plugins.GeneratedPluginRegistrant")
            val registrationMethod = generatedPluginRegistrant.getDeclaredMethod("registerWith", FlutterEngine::class.java)
            registrationMethod.invoke(null, engine)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    /**
     * The current flutter container Activity
     */
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
     *  open flutter page
     */
    fun openFlutter(context: Context, routeName: String, params: HashMap<String, Any>? = null) {
        context.startActivity(FaradayActivity.build(context, routeName, params))
    }

    /**
     *  open flutter page,and request for result
     */
    fun openFlutterForResult(activity: Activity, routeName: String, requestCode: Int, params: HashMap<String, Any>? = null) {
        activity.startActivityForResult(FaradayActivity.build(activity, routeName, params), requestCode)
    }
}
