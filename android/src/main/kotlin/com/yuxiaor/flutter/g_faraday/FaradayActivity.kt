package com.yuxiaor.flutter.g_faraday

import android.content.Context
import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import java.io.Serializable

/**
 * Author: Edward
 * Date: 2020-09-01
 * Description:
 */
class FaradayActivity : FlutterActivity(), ResultProvider {

    private val plugin by lazy { Faraday.getPlugin() }
    private var seqId: Int? = null
    private var resultListener: ((requestCode: Int, resultCode: Int, data: Intent?) -> Unit)? = null

    companion object {

        private const val ARGS_KEY = "_flutter_args"
        private const val ROUTE_KEY = "_flutter_route"

        fun build(context: Context, routeName: String, params: Serializable? = null): Intent {
            return Intent(context, FaradayActivity::class.java).apply {
                putExtra(ROUTE_KEY, routeName)
                putExtra(ARGS_KEY, params)
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        flutterEngine?.let { Faraday.registerPlugins(it) }
        createFlutterPage()
    }

    internal fun createFlutterPage() {
        val route = intent.getStringExtra(ROUTE_KEY)
        require(route != null) { "route must not be null!" }
        val args = intent.getSerializableExtra(ARGS_KEY)
        plugin?.onPageCreate(route, args, seqId) {
            seqId = it
            plugin?.onPageShow(it)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        //ignore
    }

    override fun onResume() {
        super.onResume()
        Faraday.currentActivity = this
        seqId?.let { plugin?.onPageShow(it) }
    }

    override fun onPause() {
        super.onPause()
        Faraday.currentActivity = null
        seqId?.let { plugin?.onPageHidden(it) }
    }

    override fun onDestroy() {
        super.onDestroy()
        seqId?.let { plugin?.onPageDealloc(it) }
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
