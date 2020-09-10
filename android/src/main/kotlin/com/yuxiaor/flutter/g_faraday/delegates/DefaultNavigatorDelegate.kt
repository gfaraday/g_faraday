package com.yuxiaor.flutter.g_faraday.delegates

import android.app.Activity
import android.content.Intent
import android.net.Uri
import com.yuxiaor.flutter.g_faraday.Faraday
import java.io.Serializable

/**
 * Author: Edward
 * Date: 2020-09-02
 * Description:
 */

/**
 * Default Navigator Delegate
 */
class DefaultNavigatorDelegate : FaradayNavigator {

    /**
     * Open native page
     * @param name route name
     * @param arguments data from flutter page to native page
     * @param callback  onActivityResult callback
     */
    override fun push(name: String, arguments: Serializable?, callback: (result: HashMap<String, Any?>?) -> Unit) {
        val intent = Intent(Intent.ACTION_VIEW)
        intent.data = Uri.parse(name)
        intent.putExtra(Faraday.ARGS_KEY, arguments)
        Faraday.openActivityForResult(intent, callback)
    }

    /**
     * Close container Activity when flutter pops the last page
     * @param result data from flutter to native
     */
    override fun pop(result: Serializable?) {
        val activity = Faraday.getCurrentActivity() ?: return
        if (result != null) {
            activity.setResult(Activity.RESULT_OK, Intent().apply { putExtra(Faraday.ARGS_KEY, result) })
        }
        activity.finish()
    }

}

