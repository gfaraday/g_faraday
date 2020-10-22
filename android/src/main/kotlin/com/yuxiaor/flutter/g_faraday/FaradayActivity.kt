package com.yuxiaor.flutter.g_faraday

import android.content.Context
import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

/**
 * Author: Edward
 * Date: 2020-09-01
 * Description:
 */
class FaradayActivity : FlutterActivity(), ResultProvider {

    private var seqId: Int? = null
    private var resultListener: ((requestCode: Int, resultCode: Int, data: Intent?) -> Unit)? = null

    companion object {

        private const val ARGS_KEY = "_flutter_args"
        private const val ROUTE_KEY = "_flutter_route"

        fun build(context: Context, routeName: String, params: HashMap<String, Any>? = null): Intent {
            return Intent(context, FaradayActivity::class.java).apply {
                putExtra(ROUTE_KEY, routeName)
                putExtra(ARGS_KEY, params)
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        createFlutterPage()
    }

    internal fun createFlutterPage() {
        val route = intent.getStringExtra(ROUTE_KEY)
        require(route != null) { "route must not be null!" }
        val args = intent.getSerializableExtra(ARGS_KEY)
        Faraday.plugin.onPageCreate(route, args, seqId) {
            seqId = it
            Faraday.plugin.onPageShow(it)
        }
    }

    override fun provideFlutterEngine(context: Context): FlutterEngine? {
        return Faraday.engine
    }


    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        //ignore
    }

    override fun onResume() {
        super.onResume()
        seqId?.let { Faraday.plugin.onPageShow(it) }
    }

    override fun onPause() {
        super.onPause()
        seqId?.let { Faraday.plugin.onPageHidden(it) }
    }

    override fun onDestroy() {
        super.onDestroy()
        seqId?.let { Faraday.plugin.onPageDealloc(it) }
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
