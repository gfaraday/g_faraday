package com.yuxiaor.flutter.g_faraday_example.activity.splash

import android.content.Context
import android.os.Build
import android.os.Bundle
import android.window.SplashScreenView
import com.yuxiaor.flutter.g_faraday.Faraday
import com.yuxiaor.flutter.g_faraday.FaradayActivity
import com.yuxiaor.flutter.g_faraday.channels.postNotification
import com.yuxiaor.flutter.g_faraday.channels.registerNotification
import com.yuxiaor.flutter.g_faraday.channels.unregisterNotification
import com.yuxiaor.flutter.g_faraday_example.widget.NotificationDialog


class FirstFlutterActivity : FaradayActivity() {

    companion object {
        fun build(context: Context) = builder<FirstFlutterActivity>("home", null, true).build(context)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        Faraday.registerNotification("GlobalNotification") {
            showNotification()
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            // Disable the Android splash screen fade out animation to avoid
            // a flicker before the similar frame is drawn in Flutter.
            splashScreen
                .setOnExitAnimationListener { splashScreenView: SplashScreenView -> splashScreenView.remove() }
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