package com.yuxiaor.flutter.g_faraday

import android.content.Context
import android.content.Intent
import io.flutter.embedding.android.FlutterActivityLaunchConfigs.BackgroundMode
import io.flutter.embedding.android.XFlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import java.io.Serializable

private const val ID = "_flutter_id"
private const val ARGS = "_flutter_args"
private const val ROUTE = "_flutter_route"
// 注意这个key 不能修改， flutter 内部有使用
private const val BACKGROUND_MODE = "background_mode"

/**
 * Author: Edward
 * Date: 2020-09-01
 * Description:
 */
open class FaradayActivity : XFlutterActivity(), ResultProvider {

    companion object {
        fun build(context: Context,
                         routeName: String,
                         params: Serializable? = null,
                         activityClass: Class<out FaradayActivity> = FaradayActivity::class.java,
                         opaque: Boolean = true
        ) = SingleEngineIntentBuilder(routeName, params, activityClass, opaque).build(context)
    }

    // 后续考虑支持更多参数, 然后再放开访问权限
    private data class SingleEngineIntentBuilder (val routeName: String,
                                         val params: Serializable? = null,
                                         val activityClass: Class<out FaradayActivity>,
                                         val opaque: Boolean) {

        // 真正开始Build的时候再生成id
        fun build(context: Context): Intent {

            val bm = (if (opaque) BackgroundMode.opaque else BackgroundMode.transparent).name
            val pageId = Faraday.genPageId()
            // 在flutter端生成对应页面
            Faraday.plugin?.onPageCreate(routeName, params, pageId, bm)

            return Intent(context, activityClass).apply {
                putExtra(ID, pageId)
                putExtra(ARGS, params)
                putExtra(ROUTE, routeName)
                putExtra("background_mode", bm)
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
