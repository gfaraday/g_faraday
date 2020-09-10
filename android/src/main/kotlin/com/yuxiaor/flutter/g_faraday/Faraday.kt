package com.yuxiaor.flutter.g_faraday

import android.app.Activity
import android.content.Intent
import androidx.fragment.app.FragmentActivity
import com.yuxiaor.flutter.g_faraday.delegates.DefaultNavigatorDelegate
import com.yuxiaor.flutter.g_faraday.delegates.FaradayNavigator
import com.yuxiaor.flutter.g_faraday.plugins.ActivityAwarePlugin
import com.yuxiaor.flutter.g_faraday.plugins.ResultListener
import com.yuxiaor.flutter.g_faraday.utils.NativeContextProvider
import com.yuxiaor.flutter.g_faraday.utils.getArgs
import com.yuxiaor.flutter.g_faraday.utils.getFlutterArgs
import com.yuxiaor.flutter.g_faraday.utils.startForResult
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.embedding.engine.plugins.FlutterPlugin
import java.io.Serializable
import java.util.concurrent.atomic.AtomicInteger

/**
 * Author: Edward
 * Date: 2020-08-31
 * Description:
 */
object Faraday {

    //native -> flutter  intent args key
    internal const val FLUTTER_ARGS_KEY = "_flutter_args_key"
    const val ARGS_KEY = "_args_key_"
    private val nextCode = AtomicInteger()
    var navigator: FaradayNavigator? = null

    private val activityAwarePlugin = ActivityAwarePlugin()
    private val faradayPlugin = GFaradayPlugin()

    @JvmStatic
    val engine by lazy { FlutterEngine(NativeContextProvider.context) }

    @JvmStatic
    fun startFlutterEngine(navigatorDelegate: FaradayNavigator? = null) {
        this.navigator = navigatorDelegate ?: DefaultNavigatorDelegate()
        //注册插件
        registerPlugin(faradayPlugin)
        registerPlugin(activityAwarePlugin)
        //开始执行dart代码，启动引擎
        engine.dartExecutor.executeDartEntrypoint(DartExecutor.DartEntrypoint.createDefault())
    }

    @JvmStatic
    fun registerPlugin(plugin: FlutterPlugin) {
        engine.plugins.add(plugin)
    }

    @JvmStatic
    fun getCurrentActivity(): Activity? {
        return activityAwarePlugin.binding?.activity
    }

    /**
     * When jumped to native page form a flutter page with args,this method is provided to get the args.
     *  Or you can also call [Intent.getFlutterArgs()] to get args if you are using kotlin.
     */
    @JvmStatic
    fun getFlutterArgs(intent: Intent): Serializable? {
        return intent.getFlutterArgs()
    }


    @JvmStatic
    fun openFlutter(activity: FragmentActivity, url: String, vararg params: Pair<String, Any>, onActivityResult: ((data: HashMap<String, Any?>?) -> Unit)? = null) {
        activity.openFlutter(url, *params) {
            onActivityResult?.invoke(it)
        }
    }

    @JvmStatic
    fun openFlutter(activity: Activity, url: String, vararg params: Pair<String, Any>) {
        activity.openFlutter(url, *params)
    }

    @JvmStatic
    fun openFlutter(activity: Activity, url: String, requestCode: Int, vararg params: Pair<String, Any>) {
        activity.openFlutter(url, requestCode, *params)
    }

    internal fun openActivityForResult(intent: Intent, callback: (result: HashMap<String, Any?>?) -> Unit) {
        val nextRequestCode = nextCode.getAndIncrement()
        getCurrentActivity()?.startActivityForResult(intent, nextRequestCode)
        ResultListener(activityAwarePlugin) { requestCode, resultCode, data ->
            if (requestCode == nextRequestCode && resultCode == Activity.RESULT_OK) {
                callback.invoke(data?.getArgs())
            }
        }
    }


    internal fun onPageCreate(args: Any?, callback: (seqId: Int) -> Unit) {
        faradayPlugin.onPageCreate(args, callback)
    }

    internal fun onPageShow(seqId: Int) {
        faradayPlugin.onPageShow(seqId)
    }

    internal fun onPageHidden(seqId: Int) {
        faradayPlugin.onPageHidden(seqId)
    }

    internal fun onPageDealloc(seqId: Int) {
        faradayPlugin.onPageDealloc(seqId)
    }
}


/**
 * Native to flutter
 * @param url flutter router
 * @param params params from native to flutter
 * @param onActivityResult callback for Activity Result
 */
fun FragmentActivity.openFlutter(url: String, vararg params: Pair<String, Any>, onActivityResult: ((data: HashMap<String, Any?>?) -> Unit)? = null) {
    val args = hashMapOf(*params).apply { this["name"] = url }
    val intent = Intent(this, FaradayActivity::class.java).putExtra(Faraday.FLUTTER_ARGS_KEY, args)
    startForResult(intent) { resultCode, data ->
        if (resultCode == Activity.RESULT_OK) {
            onActivityResult?.invoke(data?.getArgs())
        }
    }
}


/**
 * Native to flutter
 * @param url flutter router
 * @param params params from native to flutter
 *
 * no Activity result
 */
fun Activity.openFlutter(url: String, vararg params: Pair<String, Any>) {
    val args = hashMapOf(*params).apply { this["name"] = url }
    val intent = Intent(this, FaradayActivity::class.java).putExtra(Faraday.FLUTTER_ARGS_KEY, args)
    startActivity(intent)
}


/**
 * Native to flutter
 * @param url flutter router
 * @param params params from native to flutter
 *
 * you need to override [onActivityResult] in your Activity to get the result
 */
fun Activity.openFlutter(url: String, requestCode: Int, vararg params: Pair<String, Any>) {
    val args = hashMapOf(*params).apply { this["name"] = url }
    val intent = Intent(this, FaradayActivity::class.java).putExtra(Faraday.FLUTTER_ARGS_KEY, args)
    startActivityForResult(intent, requestCode)
}

