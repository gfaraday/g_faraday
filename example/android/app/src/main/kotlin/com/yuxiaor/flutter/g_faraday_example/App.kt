package com.yuxiaor.flutter.g_faraday_example

import android.app.Activity
import android.app.Application
import android.content.Intent
import android.net.Uri
import com.yuxiaor.flutter.g_faraday.Faraday
import com.yuxiaor.flutter.g_faraday.FaradayActivity
import com.yuxiaor.flutter.g_faraday.FaradayNavigator
import io.flutter.plugins.GeneratedPluginRegistrant
import java.io.Serializable

/**
 * Author: Edward
 * Date: 2020-09-02
 * Description:
 */
class App : Application(), FaradayNavigator {

    override fun onCreate() {
        super.onCreate()
        if (!Faraday.initEngine(this, this)) {
            GeneratedPluginRegistrant.registerWith(Faraday.engine)
        }
    }

    override fun push(name: String, arguments: Serializable?, options: HashMap<String, *>?, callback: (result: HashMap<String, *>?) -> Unit) {
        val isFlutterRoute = options?.get("is_flutter_route") == true
        if (isFlutterRoute) {
            //打开另一个flutter容器Activity
            Faraday.getCurrentActivity()?.startActivity(FaradayActivity.build(this, name, arguments))
            return
        }

        val intent = Intent(Intent.ACTION_VIEW)
        intent.data = Uri.parse(name)
        intent.putExtra(MyFlutterNavigator.KEY_ARGS, arguments)
        Faraday.startNativeForResult(intent, callback)
    }

    override fun pop(result: Serializable?) {
        val activity = Faraday.getCurrentActivity() ?: return
        if (result != null) {
            activity.setResult(Activity.RESULT_OK, Intent().apply { putExtra(MyFlutterNavigator.KEY_ARGS, result) })
        }
        activity.finish()
    }

    override fun enableSwipeBack(enable: Boolean) {

    }
}