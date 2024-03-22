package com.yuxiaor.flutter.g_faraday

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.os.Build
import android.os.Bundle
import android.os.PersistableBundle
import android.util.Log
import android.view.View
import android.view.ViewGroup
import com.yuxiaor.flutter.g_faraday.channels.CommonChannel
import com.yuxiaor.flutter.g_faraday.channels.FaradayNotice
import com.yuxiaor.flutter.g_faraday.channels.NetChannel
import io.flutter.embedding.android.ExclusiveAppComponent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.FlutterActivityLaunchConfigs.BackgroundMode
import io.flutter.embedding.android.FlutterView
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.platform.PlatformPlugin
import java.io.Serializable
import java.lang.ref.WeakReference


fun View.flutterView(): FlutterView? {
    if (this is FlutterView) {
        return this
    }
    if (this is ViewGroup) {
        for (i in 0..childCount) {
            val child = getChildAt(i)
            val fv = child.flutterView()
            if (fv != null) {
                return fv
            }
        }
    }
    return  null
}
/**
 * Author: Edward
 * Date: 2020-09-01
 * Description:
 */
open class FaradayActivity : FlutterActivity(), ResultProvider, ExclusiveAppComponent<Activity>, FaradayContainer {

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

            return Intent(context, activityClass).apply {
                putExtra(FaradayConstants.ID, pageId)
                putExtra(FaradayConstants.ARGS, params)
                putExtra(FaradayConstants.ROUTE, routeName)
                putExtra(FaradayConstants.SPLASH_SCREEN_BACKGROUND_COLOR, backgroundColor)
                putExtra(FaradayConstants.BACKGROUND_MODE, bm)
            }
        }

    }

    private val pageId: Int
        get() = intent.getIntExtra(FaradayConstants.ID, 0)

    private val routeName: String
        get() = intent.getStringExtra(FaradayConstants.ROUTE) ?: ""

    private val params: Serializable?
        get() = intent.getSerializableExtra(FaradayConstants.ARGS);

    private val backgroundModeName: String
        get() = intent.getStringExtra(FaradayConstants.BACKGROUND_MODE)?: BackgroundMode.opaque.name

    private var resultListener: ResultListener? = null

    private var isAttached = false
    private var platformPlugin: PlatformPlugin? = null
    private val gFaradayPlugin: GFaradayPlugin?
        get() = Faraday.engine.gFaradayPlugin()
    private var flutterViewRef = WeakReference<FlutterView?>(null)

    override fun onNewIntent(intent: Intent) {
        // 只有在intent 发生实质性变化时才考虑更新flutter页面
        if (intent.getIntExtra(FaradayConstants.ID, -1) != -1) {
            this.intent = intent
        }
        super.onNewIntent(this.intent)
    }

    override fun onCreate(savedInstanceState: Bundle?) {

        if (Faraday.getCurrentActivity() != this) {
            Faraday.getCurrentContainer()?.performDetach()
        }

        super.onCreate(savedInstanceState)

        flutterViewRef = WeakReference(window.decorView.flutterView())

        //
        // dart 侧创建页面
        gFaradayPlugin?.onPageCreate(routeName, params, pageId, backgroundModeName)

        Log.d(TAG, "onCreate: $this")
    }

    override fun detachFromFlutterEngine() {
        // 如果不重写这个方法，delegate会被释放掉
    }

    override fun shouldDestroyEngineWithHost(): Boolean {
        return false
    }

    override fun providePlatformPlugin(
        activity: Activity?,
        flutterEngine: FlutterEngine
    ): PlatformPlugin? {
        // 自己托管 platformPlugin
        return null
    }

    override fun shouldAttachEngineToActivity(): Boolean {
        // 自己管理
        return false;
    }

    override fun shouldDispatchAppLifecycleState(): Boolean {
        return false;
    }

    override fun rebuildFlutterPage() {
        gFaradayPlugin?.onPageCreate(routeName, params, pageId, backgroundModeName)
        gFaradayPlugin?.onPageShow(pageId)
    }

    override fun provideFlutterEngine(context: Context): FlutterEngine? {
        return Faraday.engine
    }

    override fun onResume() {
        super.onResume()

        if (Faraday.getCurrentActivity() != this) {
            Faraday.getCurrentContainer()?.performDetach()
        }

        performAttach()

        //
        flutterEngine?.lifecycleChannel?.appIsResumed()

        //
        gFaradayPlugin?.onPageShow(pageId)

        //
        platformPlugin?.updateSystemUiOverlays()
    }

    override fun onDestroy() {
        gFaradayPlugin?.onPageDealloc(pageId)
        performDetach()
        super.onDestroy()
    }

//    override fun provideSplashScreen(): SplashScreen? {
//        val splashScreen = super.provideSplashScreen()
//        if (splashScreen != null) return splashScreen
//        return FaradayColorBaseSplashScreen(intent?.getIntExtra(FaradayConstants.SPLASH_SCREEN_BACKGROUND_COLOR, Color.WHITE))
//    }

    override fun addResultListener(resultListener: ResultListener) {
        this.resultListener = resultListener
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        resultListener?.invoke(requestCode, resultCode, data)
        resultListener = null
    }

    override fun getAppComponent(): Activity {
        return super.getExclusiveAppComponent().appComponent
    }

    private fun performAttach() {
        Log.d(TAG, "attach: $this")
        if (!isAttached) {
            assert(flutterEngine != null)
            assert(flutterViewRef.get() != null)

            // 0x01
            flutterEngine?.activityControlSurface?.attachToActivity(this, lifecycle)

            flutterViewRef = WeakReference(window.decorView.flutterView())

            // 0x02
            if (platformPlugin == null) {
                platformPlugin = PlatformPlugin(activity, flutterEngine!!.platformChannel, this)
            }

            // 0x03
            flutterViewRef.get()?.attachToFlutterEngine(flutterEngine!!)

            //
            isAttached = true
        }
    }

    override fun performDetach() {
        Log.d(TAG, "detach: $this")
        if (isAttached) {

            // 0x01
            assert(flutterEngine != null)

            //
            platformPlugin?.destroy()
            platformPlugin = null

            if (Faraday.getCurrentActivity() == this) {
                //
                flutterEngine?.activityControlSurface?.detachFromActivity()

                //
                flutterViewRef.get()?.detachFromFlutterEngine()

            }

            isAttached = false
        }
    }
}
