package com.yuxiaor.flutter.g_faraday_example.faraday

import android.app.Activity
import android.content.Intent
import android.graphics.Color
import android.net.Uri
import com.yuxiaor.flutter.g_faraday.Faraday
import com.yuxiaor.flutter.g_faraday.FaradayActivity
import com.yuxiaor.flutter.g_faraday.FaradayNavigator
import com.yuxiaor.flutter.g_faraday.Options
import com.yuxiaor.flutter.g_faraday_example.activity.SingleTaskFlutterActivity
import com.yuxiaor.flutter.g_faraday_example.basic.FlutterToNativeActivity
import com.yuxiaor.flutter.g_faraday_example.basic.Native2FlutterActivity
import com.yuxiaor.flutter.g_faraday_example.basic.TabContainerActivity
import com.yuxiaor.flutter.g_faraday_example.basic.TransparentBackgroundFlutterActivity
import java.io.Serializable

const val KEY_ARGS = "_args"

object CustomNavigator : FaradayNavigator {

    override fun create(name: String, arguments: Serializable?, options: Options): Intent? {
        val context = Faraday.getCurrentActivity() ?: return null

        if (options.isFlutterRoute) {
            // standard
//            Faraday.getCurrentActivity()?.startActivity(FaradayActivity.build(this, name, arguments))

            // singleTop 模式
//            val intent = FaradayActivity.build(this, name, args, activityClass = SingleTopFlutterActivity::class.java, willTransactionWithAnother = true)
//            Faraday.getCurrentActivity()?.startActivity(intent)

            // singleTask 模式
            val builder = FaradayActivity.builder(name, arguments, false)

            // 你看到的绿色的闪屏就是这个
            builder.backgroundColor = Color.WHITE
            builder.activityClass = SingleTaskFlutterActivity::class.java

            return builder.build(context);
        }


        when (name) {
            "flutter2native" -> {
                return Intent(context, FlutterToNativeActivity::class.java)
            }
            "native2flutter" -> {
                return Intent(context, Native2FlutterActivity::class.java)
            }
            "tabContainer" -> {
                return Intent(context, TabContainerActivity::class.java)
            }
            else -> {
                val intent = Intent(Intent.ACTION_VIEW)
                intent.data = Uri.parse(name)
                intent.putExtra(KEY_ARGS, arguments)
                return intent
            }
        }

    }

    override fun pop(result: Serializable?) {
        val activity = Faraday.getCurrentActivity() ?: return
        if (result != null) {
            activity.setResult(Activity.RESULT_OK, Intent().apply { putExtra(KEY_ARGS, result) })
        }
        activity.onBackPressed()

        if (activity is TransparentBackgroundFlutterActivity) {
            activity.overridePendingTransition(0, 0)
        }
    }

    override fun enableSwipeBack(enable: Boolean) {

    }
}