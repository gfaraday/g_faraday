package com.yuxiaor.flutter.g_faraday_example.activity.splash

import android.content.Context
import com.yuxiaor.flutter.g_faraday.FaradayActivity

class FirstFlutterActivity : FaradayActivity() {

    companion object {
        fun build(context: Context) = build(context, "home", null, FirstFlutterActivity::class.java)
    }
}