package com.yuxiaor.flutter.g_faraday

import android.content.Context
import android.content.Intent
import android.util.Log
import io.flutter.embedding.android.FlutterActivityLaunchConfigs.BackgroundMode
import io.flutter.embedding.android.XFlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import java.io.Serializable

//TODO: 这些key的定义，需要重构
private const val ID = "_flutter_id"
private const val ARGS = "_flutter_args"
private const val ROUTE = "_flutter_route"

// 注意这个key 不能修改， flutter 内部有使用
private const val BACKGROUND_MODE = "background_mode"
private const val TRANSACTION_WITH_ANOTHER = "willTransactionWithAnother"

private const val TAG = "FaradayActivity"

/**
 * Author: Edward
 * Date: 2020-09-01
 * Description:
 */
open class FaradayActivity : XFlutterActivity(), ResultProvider {

    companion object {
        //
        // willTransactionWithAnother 非常重要 如果当前FaradayActivity会直接打开另外一个FaradayFragment或者
        // FaradayActivity 那么
        // 这两个对象 willTransactionWithAnother 都应该设置为true
        //
        //
        // ❌否则在动画过程中会出现 白屏/黑屏❌
        //
        fun build(context: Context,
                  routeName: String,
                  params: Serializable? = null,
                  activityClass: Class<out FaradayActivity> = FaradayActivity::class.java,
                  willTransactionWithAnother: Boolean = false,
                  opaque: Boolean = false
        ) = SingleEngineIntentBuilder(routeName, params,
                activityClass, willTransactionWithAnother, opaque).build(context)
    }

    // 后续考虑支持更多参数, 然后再放开访问权限
    private data class SingleEngineIntentBuilder(val routeName: String,
                                                 val params: Serializable? = null,
                                                 val activityClass: Class<out FaradayActivity>,
                                                 val willTransactionWithAnother: Boolean,
                                                 val opaque: Boolean) {

        // 真正开始Build的时候再生成id
        fun build(context: Context): Intent {

            var bm = (if (opaque) BackgroundMode.opaque else BackgroundMode.transparent).name
            if (willTransactionWithAnother) {
                bm = BackgroundMode.transparent.name
                if (opaque) {
                    Log.w(TAG, "如果当前Activity会直接打开另外一个Flutter Activity那么底层不能使用SurfaceView" +
                            "来渲染，所以这里 BackgroundMode 必须强制为 BackgroundMode.transparent")
                }
            }
            val pageId = Faraday.genPageId()
            // 在flutter端生成对应页面
            Faraday.plugin?.onPageCreate(routeName, params, pageId, bm)

            return Intent(context, activityClass).apply {
                putExtra(ID, pageId)
                putExtra(ARGS, params)
                putExtra(ROUTE, routeName)
                putExtra("background_mode", bm)
                putExtra(TRANSACTION_WITH_ANOTHER, willTransactionWithAnother)
            }
        }

    }

    private val pageId: Int
        get() = intent.getIntExtra(ID, 0)

    private var resultListener: ((requestCode: Int, resultCode: Int, data: Intent?) -> Unit)? = null

    override fun onNewIntent(intent: Intent) {
        this.intent = intent
        super.onNewIntent(intent)
    }

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        Faraday.plugin?.onPageShow(pageId)
    }

    internal fun rebuild() {
        val route = intent.getStringExtra(ROUTE)
        require(route != null) { "route must not be null!" }
        val args = intent.getSerializableExtra(ARGS)
        val bm = intent.getStringExtra(BACKGROUND_MODE)
        require(bm != null)
        Faraday.plugin?.onPageCreate(route, args, pageId, bm)
        Faraday.plugin?.onPageShow(pageId)
    }

    override fun provideFlutterEngine(context: Context): FlutterEngine? {
        return Faraday.engine
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    }

    override fun shouldDestroyEngineWithHost(): Boolean {
        return false
    }

    override fun shouldAddFlutterViewSnapshot(): Boolean {
        return intent.getBooleanExtra(TRANSACTION_WITH_ANOTHER, false)
    }

    override fun onResume() {
        super.onResume()
        Faraday.plugin?.onPageShow(pageId)
    }

    override fun onDestroy() {
        Faraday.plugin?.onPageDealloc(pageId)
        super.onDestroy()
    }

    override fun addResultListener(resultListener: (requestCode: Int, resultCode: Int, data: Intent?) -> Unit) {
        this.resultListener = resultListener
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        resultListener?.invoke(requestCode, resultCode, data)
        resultListener = null
    }
}
