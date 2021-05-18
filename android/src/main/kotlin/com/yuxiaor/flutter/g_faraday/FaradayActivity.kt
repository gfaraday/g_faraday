package com.yuxiaor.flutter.g_faraday

import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.util.Log
import io.flutter.embedding.android.FlutterActivityLaunchConfigs.BackgroundMode
import io.flutter.embedding.android.SplashScreen
import io.flutter.embedding.android.XFlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import java.io.Serializable

/**
 * Author: Edward
 * Date: 2020-09-01
 * Description:
 */
open class FaradayActivity : XFlutterActivity(), ResultProvider {

    companion object {

        private const val TAG = "FaradayActivity"

        fun builder(routeName: String, params: Serializable? = null, opaque: Boolean = true) = builder<FaradayActivity>(routeName, params, opaque)

        // opaque: Boolean = false 效率会差一些
        // 除非你有 非常非常非常 明确的理由，否则不要动他
        //
        //
        // 目前只有一种特定情况 opaque 需要设置为false
        //
        // 假如有一个`FaradayActivity`(假设为A)会使用新的容器打开flutter页面(假设为B)
        // 那么在 build A activity 的intent时 需要设置 `opaque = false` 否则在跳转时 页面会闪烁
        //
        inline fun <reified T : FaradayActivity> builder(
                routeName: String,
                params: Serializable? = null,
                opaque: Boolean = false,
                backgroundColor: Int? = null,
        ) = SingleEngineIntentBuilder(routeName, params, T::class.java, opaque, backgroundColor)
    }

    // 后续考虑支持更多参数, 然后再放开访问权限
    data class SingleEngineIntentBuilder(val routeName: String,
                                         val params: Serializable?,
                                         var activityClass: Class<out FaradayActivity>,
                                         var opaque: Boolean,
                                         var backgroundColor: Int?) {

        // 真正开始Build的时候再生成id
        fun build(context: Context): Intent {

            val bm = (if (opaque) BackgroundMode.opaque else BackgroundMode.transparent).name

            val pageId = Faraday.genPageId()

            // 在flutter端生成对应页面
            Log.v(TAG, "will create page: $routeName")
            Faraday.plugin?.onPageCreate(routeName, params, pageId, bm)

            return Intent(context, activityClass).apply {
                putExtra(FaradayConstants.ID, pageId)
                putExtra(FaradayConstants.ARGS, params)
                putExtra(FaradayConstants.ROUTE, routeName)
                putExtra(FaradayConstants.SPLASH_SCREEN_BACKGROUND_COLOR, backgroundColor)
                putExtra("background_mode", bm)
            }
        }

    }

    private val pageId: Int
        get() = intent.getIntExtra(FaradayConstants.ID, 0)

    val routeName: String
        get() = intent.getStringExtra(FaradayConstants.ROUTE) ?: ""
    val params: Serializable?
        get() = intent.getSerializableExtra(FaradayConstants.ARGS);

    private var resultListener: ResultListener? = null

    override fun onNewIntent(intent: Intent) {
        // 只有在intent 发生实质性变化时才考虑更新flutter页面
        if (intent.getIntExtra(FaradayConstants.ID, -1) != -1) {
            this.intent = intent
        }
        super.onNewIntent(this.intent)
    }

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        Faraday.plugin?.onPageShow(pageId)
    }

    internal fun rebuildFlutterPage() {
        val route = intent.getStringExtra(FaradayConstants.ROUTE)
        require(route != null) { "route must not be null!" }
        val args = intent.getSerializableExtra(FaradayConstants.ARGS)
        val bm = intent.getStringExtra(FaradayConstants.BACKGROUND_MODE)
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

    override fun provideSplashScreen(): SplashScreen? {
        val splashScreen = super.provideSplashScreen()
        if (splashScreen != null) return splashScreen
        return FaradayColorBaseSplashScreen(intent?.getIntExtra(FaradayConstants.SPLASH_SCREEN_BACKGROUND_COLOR, Color.WHITE))
    }

    override fun addResultListener(resultListener: ResultListener) {
        this.resultListener = resultListener
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        resultListener?.invoke(requestCode, resultCode, data)
        resultListener = null
    }
}
