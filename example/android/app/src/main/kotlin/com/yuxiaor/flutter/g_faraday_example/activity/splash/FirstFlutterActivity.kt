package com.yuxiaor.flutter.g_faraday_example.activity.splash

import android.content.Context
import android.os.Bundle
import com.yuxiaor.flutter.g_faraday.Faraday
import com.yuxiaor.flutter.g_faraday.FaradayActivity

class FirstFlutterActivity : FaradayActivity() {

    companion object {
        fun build(context: Context) = builder("home", null, FirstFlutterActivity::class.java).build(context)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        Faraday.registerNotification("GlobalNotification") {
            // 弹一个通知
            // 然后 倒计时 5秒 发送下面的通知到 flutter

            Faraday.postNotification("NotificationFromNative", "Hi, + 安卓版本号")
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        Faraday.unregisterNotification("GlobalNotification")
    }
}