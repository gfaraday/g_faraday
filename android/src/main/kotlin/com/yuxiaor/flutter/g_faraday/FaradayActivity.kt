package com.yuxiaor.flutter.g_faraday

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.XFlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import java.io.Serializable

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

        fun build(context: Context, routeName: String, params: Serializable? = null): Intent {
            return Intent(context, FaradayActivity::class.java).apply {
                putExtra(ROUTE_KEY, routeName)
                putExtra(ARGS_KEY, params)
            }
        }
    }

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        createFlutterPage()
    }

    internal fun createFlutterPage() {
        val route = intent.getStringExtra(ROUTE_KEY)
        require(route != null) { "route must not be null!" }
        val args = intent.getSerializableExtra(ARGS_KEY)
        Faraday.plugin?.onPageCreate(route, args, seqId) {
            seqId = it
            Faraday.plugin?.onPageShow(it)
        }
    }

    override fun provideFlutterEngine(context: Context): FlutterEngine? {
        return Faraday.engine
    }

//    override fun detachFromFlutterEngine() {
//        // 阻止 engine release 相关资源
//    }

//    override fun shouldAttachEngineToActivity(): Boolean {
//        return false
//    }
//
//    override fun shouldDestroyEngineWithHost(): Boolean {
//        return false
//    }
//
    override fun onResume() {
//        flutterEngine?.activityControlSurface?.attachToActivity(this, lifecycle)
        super.onResume()
        seqId?.let { Faraday.plugin?.onPageShow(it) }
    }

    override fun onStart() {

        super.onStart()
    }

//
//    override fun onStop() {
//        super.onStop()
//        if (isChangingConfigurations) {
//            flutterEngine?.activityControlSurface?.detachFromActivityForConfigChanges()
//        } else {
//            flutterEngine?.activityControlSurface?.detachFromActivity()
//        }
//
//    }

    override fun onDestroy() {
        seqId?.let { Faraday.plugin?.onPageDealloc(it) }
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
