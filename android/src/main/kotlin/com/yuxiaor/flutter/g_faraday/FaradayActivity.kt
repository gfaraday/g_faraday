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

        fun builder(routeName: String, params: Serializable? = null) = builder<FaradayActivity>(routeName, params)

        // opaque: Boolean = false 效率会差一些
        // 除非你有 非常非常非常 明确的理由，否则不要动他
        inline fun <reified T : FaradayActivity> builder(
                routeName: String,
                params: Serializable? = null,
                opaque: Boolean = true,
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

    private val pageId by lazy { intent.getIntExtra(FaradayConstants.ID, 0) }

    private var resultListener: ((requestCode: Int, resultCode: Int, data: Intent?) -> Unit)? = null

    override fun onNewIntent(intent: Intent) {
        this.intent = intent
        super.onNewIntent(intent)
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

    override fun addResultListener(resultListener: (requestCode: Int, resultCode: Int, data: Intent?) -> Unit) {
        this.resultListener = resultListener
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        resultListener?.invoke(requestCode, resultCode, data)
        resultListener = null
    }
}
