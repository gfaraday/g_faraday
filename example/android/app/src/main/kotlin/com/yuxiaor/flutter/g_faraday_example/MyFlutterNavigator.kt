package com.yuxiaor.flutter.g_faraday_example

import android.app.Activity
import android.content.Intent
import android.net.Uri
import com.yuxiaor.flutter.g_faraday.Faraday
import com.yuxiaor.flutter.g_faraday.FaradayActivity
import com.yuxiaor.flutter.g_faraday.FaradayNavigator
import java.io.Serializable

/**
 * Author: Edward
 * Date: 2020-09-14
 * Description:
 */
class MyFlutterNavigator : FaradayNavigator {

    companion object {
        const val KEY_ARGS = "_args"
    }

    /**
     * Open native page
     * @param name route name
     * @param arguments data from flutter page to native page
     * @param callback  onActivityResult callback
     */
    override fun push(name: String, arguments: Serializable?, options: HashMap<String, *>?, callback: (result: HashMap<String, *>?) -> Unit) {
        val isFlutter = options?.get("flutter") == true
        if (isFlutter) {
            Faraday.getCurrentActivity()?.apply {
                startActivity(FaradayActivity.build(this, name, arguments))
            }
            return
        }
        val intent = Intent(Intent.ACTION_VIEW)
        intent.data = Uri.parse(name)
        intent.putExtra(KEY_ARGS, arguments)
        Faraday.startNativeForResult(intent, callback)
    }

    /**
     * Close container Activity when flutter pops the last page
     * @param result data from flutter to native
     */
    override fun pop(result: Serializable?) {
        val activity = Faraday.getCurrentActivity() ?: return
        if (result != null) {
            activity.setResult(Activity.RESULT_OK, Intent().apply { putExtra(KEY_ARGS, result) })
        }
        activity.finish()
    }

    /**
     * 是否允许滑动返回
     */
    override fun enableSwipeBack(enable: Boolean) {
    }

}