package com.yuxiaor.flutter.g_faraday

import android.content.Context
import android.content.Intent
import io.flutter.embedding.android.XFlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import java.io.Serializable

/**
 * Author: Edward
 * Date: 2020-09-01
 * Description:
 */
class FaradayActivity : XFlutterActivity(), ResultProvider {

    private val pageId by lazy { intent.getIntExtra(ID, 0) }
    private var resultListener: ((requestCode: Int, resultCode: Int, data: Intent?) -> Unit)? = null

    companion object {

        private const val ID = "_flutter_id"
        private const val ARGS = "_flutter_args"
        private const val ROUTE = "_flutter_route"

        fun build(context: Context, routeName: String, params: Serializable? = null): Intent {
            val pageId = Faraday.genPageId()
            Faraday.plugin?.onPageCreate(routeName, params, pageId)
            val intent = Intent(context, FaradayActivity::class.java)
            intent.putExtra(ID, pageId)
            intent.putExtra(ARGS, params)
            intent.putExtra(ROUTE, routeName)
            return intent
        }
    }

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        Faraday.plugin?.onPageShow(pageId)
    }

    internal fun buildFlutterPage() {
        val route = intent.getStringExtra(ROUTE)
        require(route != null) { "route must not be null!" }
        val args = intent.getSerializableExtra(ARGS)
        Faraday.plugin?.onPageCreate(route, args, pageId)
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
