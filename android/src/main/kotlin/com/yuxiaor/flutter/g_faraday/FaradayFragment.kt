

package com.yuxiaor.flutter.g_faraday

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import io.flutter.embedding.android.*
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.platform.PlatformPlugin
import java.io.Serializable
import java.lang.ref.WeakReference


/**
 * Author: Edward
 * Date: 2020-09-07
 * Description:
 */
class FaradayFragment : FlutterFragment(), ResultProvider, FaradayContainer, ExclusiveAppComponent<Activity> {

    private val pageId by lazy { arguments?.getInt(FaradayConstants.ID) ?: 0 }
    private val routeName by lazy { arguments?.getString(FaradayConstants.ROUTE) ?: "/" }
    private val args by lazy { arguments?.get(FaradayConstants.ARGS) }
    private val backgroundModeName by lazy {
       arguments?.getString(FaradayConstants.BACKGROUND_MODE) ?: FlutterActivityLaunchConfigs.BackgroundMode.opaque.name }

    private var resultListener: ResultListener? = null

    private val gFaradayPlugin: GFaradayPlugin?
        get() = Faraday.engine.gFaradayPlugin()
    private var flutterViewRef = WeakReference<FlutterView?>(null)

    private var isAttached = false
    private var platformPlugin: PlatformPlugin? = null

    companion object {

        const val TAG = "FaradayFragment"
        ///
        /// 1. 注意 fragment 有一个小限制，如果打算使用
        /// FragmentTransaction.add 然后 show/hide 的方式来切换 fragment 那么opaque必须为false
        ///
        /// ❌否则在动画过程中会出现 白屏/黑屏❌
        ///
        @JvmStatic
        fun newInstance(
                routeName: String,
                params: HashMap<String, Any>? = null,
                opaque: Boolean = true,
                backgroundColor: Int? = null,
        ): FaradayFragment {
            val pageId = Faraday.genPageId()
            val bm = (if (opaque) TransparencyMode.opaque else TransparencyMode.transparent).name
            val bundle = Bundle().apply {
                putInt(FaradayConstants.ID, pageId)
                putString(FaradayConstants.ROUTE, routeName)
                putSerializable(FaradayConstants.ARGS, params)
                putString(ARG_FLUTTERVIEW_TRANSPARENCY_MODE, bm)
                if (backgroundColor != null) {
                    putInt(FaradayConstants.SPLASH_SCREEN_BACKGROUND_COLOR, backgroundColor)
                }
            }
            return FaradayFragment().apply { arguments = bundle }
        }
    }

    override fun detachFromFlutterEngine() {
        //
    }

    override fun providePlatformPlugin(
        activity: Activity?,
        flutterEngine: FlutterEngine
    ): PlatformPlugin? {
        return null
    }

    override fun onDestroy() {
        gFaradayPlugin?.onPageDealloc(pageId)
        performDetach()
        super.onDestroy()
    }

    override fun shouldDestroyEngineWithHost(): Boolean {
        return false
    }

    override fun getRenderMode(): RenderMode {
        return RenderMode.texture
    }

    override fun getTransparencyMode(): TransparencyMode {
        return TransparencyMode.transparent
    }

    override fun provideSplashScreen(): SplashScreen? {
        val splashScreen = super.provideSplashScreen()
        if (splashScreen != null) return splashScreen
        return FaradayColorBaseSplashScreen(arguments?.getInt(FaradayConstants.SPLASH_SCREEN_BACKGROUND_COLOR, Color.WHITE))
    }

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        val view = super.onCreateView(inflater, container, savedInstanceState)

        flutterViewRef = WeakReference(view?.flutterView())
        flutterViewRef.get()?.detachFromFlutterEngine()

        return view
    }

    override fun onStart() {
        super.onStart()
        if (!isHidden) {
            showFragment()
        }
    }

    override fun onHiddenChanged(hidden: Boolean) {
        super.onHiddenChanged(hidden)
        if (flutterViewRef.get() == null) return

        if (!hidden) {
            showFragment()
        }
    }

    override fun onPause() {
        super.onPause()
        flutterEngine?.lifecycleChannel?.appIsResumed()
    }

    override fun onResume() {
        super.onResume()
        if (!isHidden) {
            showFragment()
        }
        flutterEngine?.lifecycleChannel?.appIsResumed()
    }

    override fun onStop() {
        super.onStop()
        flutterEngine?.lifecycleChannel?.appIsResumed()
    }

    override fun onDetach() {
        super.onDetach()
        gFaradayPlugin?.onPageDealloc(pageId)
    }

    override fun provideFlutterEngine(context: Context): FlutterEngine? {
        return Faraday.engine
    }

    override fun shouldAttachEngineToActivity(): Boolean {
        return false
    }

    override fun shouldDispatchAppLifecycleState(): Boolean {
        return false
    }

    override fun addResultListener(resultListener: ResultListener) {
        this.resultListener = resultListener

    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        resultListener?.invoke(requestCode, resultCode, data)
        resultListener = null
    }

    private fun showFragment() {
        if (Faraday.getCurrentContainer() != this) {
            Faraday.getCurrentContainer()?.performDetach()
        }
        performAttach()
        gFaradayPlugin?.onPageShow(pageId)
    }

    private fun performAttach() {
        Log.d(TAG, "attach: $this")
        if (!isAttached) {
            assert(flutterEngine != null)
            assert(flutterViewRef.get() != null)

            gFaradayPlugin?.onPageCreate(routeName, args as? Serializable, pageId, backgroundModeName)

            // 0x01
            flutterEngine?.activityControlSurface?.attachToActivity(this, lifecycle)

            // 0x02
            if (platformPlugin == null) {
                platformPlugin = PlatformPlugin(requireActivity(), flutterEngine!!.platformChannel)
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

            if (Faraday.getCurrentContainer() == this) {
                //
                flutterEngine?.activityControlSurface?.detachFromActivity()

                //
                flutterViewRef.get()?.detachFromFlutterEngine()

            }

            isAttached = false
        }
    }

    override fun rebuildFlutterPage() {
        gFaradayPlugin?.onPageCreate(routeName, args as? Serializable, pageId, backgroundModeName)
        gFaradayPlugin?.onPageShow(pageId)
    }

    override fun getAppComponent(): Activity {
       return requireActivity()
    }
}