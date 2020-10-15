package com.yuxiaor.flutter.g_faraday

import android.app.Activity
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
class FaradayActivity : FlutterActivity() {

    internal var seqId: Int? = null

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
        val args = intent.getSerializableExtra(ARGS_KEY)
        Faraday.plugin.onPageCreate(route, args) {
            seqId = it
            Faraday.plugin.onPageShow(it)
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        val route = intent.getStringExtra(ROUTE_KEY)
        val args = intent.getSerializableExtra(ARGS_KEY)
        Faraday.plugin.onPageCreate(route, args) {
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
}


/**
 * Native to flutter
 * @param routeName flutter router
 * @param params params from native to flutter
 */
fun Context.openFlutter(routeName: String, vararg params: Pair<String, Any>) {
    startActivity(FaradayActivity.build(this, routeName, hashMapOf(*params)))
}


/**
 * Native to flutter
 * @param routeName flutter router
 * @param params params from native to flutter
 *
 * You need to override [Activity.onActivityResult] in your Activity to get the result
 */
fun Activity.openFlutterForResult(routeName: String, requestCode: Int, vararg params: Pair<String, Any>) {
    startActivityForResult(FaradayActivity.build(this, routeName, hashMapOf(*params)), requestCode)
}

