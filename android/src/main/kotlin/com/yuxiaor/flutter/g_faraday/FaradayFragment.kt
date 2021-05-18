package com.yuxiaor.flutter.g_faraday

import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.os.Bundle
import io.flutter.embedding.android.RenderMode
import io.flutter.embedding.android.SplashScreen
import io.flutter.embedding.android.TransparencyMode
import io.flutter.embedding.android.XFlutterFragment
import io.flutter.embedding.engine.FlutterEngine

/**
 * Author: Edward
 * Date: 2020-09-07
 * Description:
 */
class FaradayFragment : XFlutterFragment(), ResultProvider {

    private val pageId by lazy { arguments?.getInt(FaradayConstants.ID) ?: 0 }
    private var resultListener: ResultListener? = null

    companion object {
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
            Faraday.plugin?.onPageCreate(routeName, params, pageId, bm)
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

    override fun onAttach(context: Context) {
        rebuildFlutterPage()
        super.onAttach(context)
    }

    internal fun rebuildFlutterPage() {
        val route = arguments?.getString(FaradayConstants.ROUTE)
        require(route != null) { "route must not be null!" }
        val args = arguments?.getSerializable(FaradayConstants.ARGS)
        val bm = arguments?.getString(ARG_FLUTTERVIEW_TRANSPARENCY_MODE)
        require(bm != null)
        Faraday.plugin?.onPageCreate(route, args, pageId, bm)
        Faraday.plugin?.onPageShow(pageId)
    }

    override fun getRenderMode(): RenderMode {
        return RenderMode.texture
    }

    override fun getTransparencyMode(): TransparencyMode {
        return TransparencyMode.transparent
    }

    override fun provideFlutterEngine(context: Context): FlutterEngine? {
        return Faraday.engine
    }

    override fun provideSplashScreen(): SplashScreen? {
        val splashScreen = super.provideSplashScreen()
        if (splashScreen != null) return splashScreen
        return FaradayColorBaseSplashScreen(arguments?.getInt(FaradayConstants.SPLASH_SCREEN_BACKGROUND_COLOR, Color.WHITE))
    }

    override fun onStart() {
        super.onStart()
        if (!isHidden) {
            Faraday.plugin?.onPageShow(pageId)
        }
    }

    override fun onHiddenChanged(hidden: Boolean) {
        super.onHiddenChanged(hidden)
        if (!hidden) {
            Faraday.plugin?.onPageShow(pageId)
        }
    }

    override fun onResume() {
        super.onResume()
        if (!isHidden) {
            Faraday.plugin?.onPageShow(pageId)
        }
    }

    override fun onDetach() {
        super.onDetach()
        Faraday.plugin?.onPageDealloc(pageId)
    }

    override fun shouldAttachEngineToActivity(): Boolean {
        return true
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