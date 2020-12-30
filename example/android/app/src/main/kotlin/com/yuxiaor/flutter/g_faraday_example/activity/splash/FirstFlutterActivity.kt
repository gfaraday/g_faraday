package com.yuxiaor.flutter.g_faraday_example.activity.splash

import android.content.Context
import android.os.Build
import android.os.Bundle
import com.yuxiaor.flutter.g_faraday.Faraday
import com.yuxiaor.flutter.g_faraday.FaradayActivity
import com.yuxiaor.flutter.g_faraday_example.widget.NotificationDialog

class FirstFlutterActivity : FaradayActivity() {

    companion object {
        fun build(context: Context) = builder<FirstFlutterActivity>("home", null, false).build(context)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        Faraday.registerNotification("GlobalNotification") {
            showNotification()
        }
    }

    private fun showNotification() {
        NotificationDialog(this, "Notification from Flutter").apply {
            setOnDismissListener {
                Faraday.postNotification("NotificationFromNative", "Hi, Android ${Build.VERSION.RELEASE}")
            }
        }.show()
    }

    override fun onDestroy() {
        super.onDestroy()
        Faraday.unregisterNotification("GlobalNotification")
    }
}