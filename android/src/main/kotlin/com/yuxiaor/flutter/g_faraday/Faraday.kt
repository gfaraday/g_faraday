package com.yuxiaor.flutter.g_faraday

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.util.Log
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentActivity
import com.yuxiaor.flutter.g_faraday.channels.*
import com.yuxiaor.flutter.g_faraday.channels.CommonChannel
import com.yuxiaor.flutter.g_faraday.channels.NetChannel
import io.flutter.FlutterInjector
import io.flutter.embedding.android.FlutterFragment
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor.DartEntrypoint
import io.flutter.plugin.common.MethodChannel
import java.lang.ref.WeakReference
import java.util.concurrent.atomic.AtomicInteger

interface FaradayContainer {

    // detach from engine
    fun performDetach()

    //
    fun rebuildFlutterPage()
}

/**
 * Author: Edward
 * Date: 2020-08-31
 * Description:
 */
object Faraday {

    lateinit var engine: FlutterEngine
        private set

    private val nextCode = AtomicInteger()

    // router manager
    internal lateinit var navigator: FaradayNavigator

    /**
     *  init engine
     *
     *  @param context Application Context
     *  @param navigator handle native route
     *  @param netHandler handle net request
     *  @param commonHandler common method invoke
     *  @param automaticallyRegisterPlugins If plugins are automatically
     * registered, then they are registered during the execution of this constructor
     *
     *  @return true if plugins registered otherwise return false.
     *
     *  @sample
     *  if (!Faraday.startFlutterEngine(this, MyFlutterNavigator())) {
     *       GeneratedPluginRegister.registerGeneratedPlugins(Faraday.engine)
     *   }
     *
     */
    @JvmStatic
    fun startFlutterEngine(context: Context,
                           navigator: FaradayNavigator,
                           netHandler: NetHandler? = null,
                           commonHandler: MethodChannel.MethodCallHandler? = null,
                           automaticallyRegisterPlugins: Boolean = true,
                           dartEntrypointFunctionName: String = "main"): Boolean {
        // 这个navigator 必须先初始化 不能动
        this.navigator = navigator

        engine = FlutterEngine(context, arrayOf(), automaticallyRegisterPlugins)

        val flutterLoader = FlutterInjector.instance().flutterLoader()

        if (!flutterLoader.initialized()) {
            throw AssertionError(
                    "DartEntrypoints can only be created once a FlutterEngine is created.")
        }
        val entrypoint = DartEntrypoint(flutterLoader.findAppBundlePath(), dartEntrypointFunctionName)

        engine.dartExecutor.executeDartEntrypoint(entrypoint)

        if (netHandler != null) {
            NetChannel(engine.dartExecutor, netHandler)
        }

        if (commonHandler != null) {
            CommonChannel(engine.dartExecutor, commonHandler)
        }

        FaradayNotice.setup(engine.dartExecutor)

        return  false
    }

    internal fun genPageId(): Int {
        return nextCode.getAndIncrement()
    }

    /**
     * The current flutter container Activity
     */
    @JvmStatic
    fun getCurrentContainer(): FaradayContainer? {
        val activity = getCurrentActivity()
        if (activity is FaradayContainer) {
            return activity
        }

        if (activity is FragmentActivity) {
            var frag = activity.supportFragmentManager.fragments.find { it.isVisible }
            if (frag == null) {
                frag = activity.supportFragmentManager.fragments.find { it is FaradayContainer }
            }
            if (frag is FaradayContainer) {
                return frag
            }
        }

        return  null
    }

    fun getCurrentActivity(): Activity? {
        return  engine.gFaradayPlugin()?.binding?.activity
    }
    /**
     * start native Activity,and request for Activity result
     */
    internal fun startNativeForResult(intent: Intent, callback: (result: HashMap<String, Any?>?) -> Unit) {
        val code = nextCode.getAndIncrement()
        startNativeForResult(intent, code) { requestCode, resultCode, data ->
            if (requestCode == code) {
                if (resultCode == Activity.RESULT_OK) {
                    val map = hashMapOf<String, Any?>()
                    data?.extras?.keySet()?.forEach {
                        map[it] = data.extras?.get(it)
                    }
                    callback.invoke(map)
                } else {
                    callback.invoke(null)
                }
            }
        }
    }

    private fun startNativeForResult(intent: Intent, requestCode: Int, callback: ResultListener) {
        val activity = getCurrentContainer()

        if (activity is ResultProvider) {
            activity.addResultListener(callback)
            if (activity is Activity) {
                activity.startScheme(intent, requestCode)
            }
            return
        }

        if (activity is FragmentActivity) {
            val frag = activity.supportFragmentManager.fragments.first { it.isVisible }
            if (frag is ResultProvider) {
                frag.addResultListener(callback)
                frag.startScheme(intent, requestCode)
            }
        }
    }

    private fun Activity.startScheme(intent: Intent, requestCode: Int){
        try {
            startActivityForResult(intent, requestCode)
        }catch (e:Exception){
            Log.e("Faraday", "Route Not Found: '${intent.data}'")
        }
    }

    private fun Fragment.startScheme(intent: Intent, requestCode: Int){
        try {
            startActivityForResult(intent, requestCode)
        }catch (e:Exception){
            Log.e("Faraday", "Route Not Found: '${intent.data}'")
        }
    }
}
