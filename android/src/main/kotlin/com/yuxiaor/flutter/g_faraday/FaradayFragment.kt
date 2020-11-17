package com.yuxiaor.flutter.g_faraday

import android.content.Context
import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterFragment
import io.flutter.embedding.android.TransparencyMode

/**
 * Author: Edward
 * Date: 2020-09-07
 * Description:
 */
class FaradayFragment : FlutterFragment(), ResultProvider {

    private var seqId: Int? = null
    private var resultListener: ((requestCode: Int, resultCode: Int, data: Intent?) -> Unit)? = null

    companion object {

        private const val ARGS_KEY = "_flutter_args"
        private const val ROUTE_KEY = "_flutter_route"

        fun newInstance(routeName: String, params: HashMap<String, Any>? = null): FaradayFragment {
            val bundle = Bundle().apply {
                putString(ROUTE_KEY, routeName)
                putSerializable(ARGS_KEY, params)
                putString(ARG_FLUTTERVIEW_TRANSPARENCY_MODE, TransparencyMode.opaque.name)
            }
            return FaradayFragment().apply { arguments = bundle }
        }
    }

    override fun onAttach(context: Context) {
        super.onAttach(context)
        flutterEngine?.let { Faraday.registerPlugins(it) }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        createFlutterPage()
    }

    internal fun createFlutterPage() {
        val route = arguments?.getString(ROUTE_KEY)
        require(route != null) { "route must not be null!" }
        val args = arguments?.getSerializable(ARGS_KEY)
        Faraday.plugin?.onPageCreate(route, args, seqId) {
            seqId = it
            Faraday.plugin?.onPageShow(it)
        }
    }

    override fun onHiddenChanged(hidden: Boolean) {
        if (!hidden) {
            seqId?.let { Faraday.plugin?.onPageShow(it) }
        } else {
            seqId?.let { Faraday.plugin?.onPageHidden(it) }
        }
        super.onHiddenChanged(hidden)
    }

    override fun onResume() {
        super.onResume()
        seqId?.let { Faraday.plugin?.onPageShow(it) }
    }

    override fun onPause() {
        super.onPause()
        seqId?.let { Faraday.plugin?.onPageHidden(it) }
    }

    override fun onDetach() {
        super.onDetach()
        seqId?.let { Faraday.plugin?.onPageDealloc(it) }
    }

    override fun onDestroy() {
        super.onDestroy()
        seqId?.let { Faraday.plugin?.onPageDealloc(it) }
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