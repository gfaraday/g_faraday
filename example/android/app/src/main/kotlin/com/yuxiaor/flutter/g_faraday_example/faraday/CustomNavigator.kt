package com.yuxiaor.flutter.g_faraday_example.faraday

import android.app.Activity
import android.content.Intent
import android.graphics.Color
import android.net.Uri
import com.yuxiaor.flutter.g_faraday.Faraday
import com.yuxiaor.flutter.g_faraday.FaradayActivity
import com.yuxiaor.flutter.g_faraday.FaradayNavigator
import com.yuxiaor.flutter.g_faraday_example.activity.SingleTaskFlutterActivity
import com.yuxiaor.flutter.g_faraday_example.basic.FlutterToNativeActivity
import java.io.Serializable

private const val KEY_ARGS = "_args"

object CustomNavigator : FaradayNavigator {

    private var count = 0

    override fun create(name: String, arguments: Serializable?, options: HashMap<String, *>?): Intent? {
        val context = Faraday.getCurrentActivity() ?: return null
        val isFlutterRoute = options?.get("is_flutter_route") == true
        if (isFlutterRoute) {
            //打开另一个flutter容器Activity
            count++
            val args = hashMapOf<String, Any>("count" to count)

            // standard
//            Faraday.getCurrentActivity()?.startActivity(FaradayActivity.build(this, name, arguments))

            // singleTop 模式
//            val intent = FaradayActivity.build(this, name, args, activityClass = SingleTopFlutterActivity::class.java, willTransactionWithAnother = true)
//            Faraday.getCurrentActivity()?.startActivity(intent)

            // singleTask 模式
            val builder = FaradayActivity.builder(name, args)

            // 你看到的绿色的闪屏就是这个
            builder.backgroundColor = Color.GREEN
            builder.activityClass = SingleTaskFlutterActivity::class.java

            return builder.build(context);
        }


        if (name == "flutter2native") {
            return Intent(context, FlutterToNativeActivity::class.java)
        }

        val intent = Intent(Intent.ACTION_VIEW)
        intent.data = Uri.parse(name)
        intent.putExtra(KEY_ARGS, arguments)
        return intent
    }

    override fun pop(result: Serializable?) {
        val activity = Faraday.getCurrentActivity() ?: return
        if (result != null) {
            activity.setResult(Activity.RESULT_OK, Intent().apply { putExtra(KEY_ARGS, result) })
        }
        activity.finish()
    }

    override fun enableSwipeBack(enable: Boolean) {

    }
}