package com.yuxiaor.flutter.g_faraday

import android.content.Context
import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.TransparencyMode
import io.flutter.embedding.android.XFlutterFragment
import io.flutter.embedding.engine.FlutterEngine

/**
 * Author: Edward
 * Date: 2020-09-07
 * Description:
 */
class FaradayFragment : XFlutterFragment(), ResultProvider {

    private val pageId by lazy { arguments?.getInt(ID) ?: 0 }
    private var resultListener: ((requestCode: Int, resultCode: Int, data: Intent?) -> Unit)? = null

    companion object {

        private const val ID = "_flutter_id"
        private const val ARGS = "_flutter_args"
        private const val ROUTE = "_flutter_route"

        // 需要重构
        @JvmStatic
        fun newInstance(routeName: String, params: HashMap<String, Any>? = null, opaque: Boolean = true): FaradayFragment {
            val pageId = Faraday.genPageId()
            val bm = (if (opaque) TransparencyMode.opaque else TransparencyMode.transparent).name
            Faraday.plugin?.onPageCreate(routeName, params, pageId, bm)
            val bundle = Bundle().apply {
                putInt(ID, pageId)
                putString(ROUTE, routeName)
                putSerializable(ARGS, params)
                putString(ARG_FLUTTERVIEW_TRANSPARENCY_MODE, bm)
            }
            return FaradayFragment().apply { arguments = bundle }
        }
    }

    internal fun rebuild() {
        val route = arguments?.getString(ROUTE)
        require(route != null) { "route must not be null!" }
        val args = arguments?.getSerializable(ARGS)
        val bm = arguments?.getString(ARG_FLUTTERVIEW_TRANSPARENCY_MODE)
        require(bm != null)
        Faraday.plugin?.onPageCreate(route, args, pageId, bm)
        Faraday.plugin?.onPageShow(pageId)
    }

    override fun provideFlutterEngine(context: Context): FlutterEngine? {
        return Faraday.engine
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

    override fun addResultListener(resultListener: (requestCode: Int, resultCode: Int, data: Intent?) -> Unit) {
        this.resultListener = resultListener

    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        resultListener?.invoke(requestCode, resultCode, data)
        resultListener = null
    }
}