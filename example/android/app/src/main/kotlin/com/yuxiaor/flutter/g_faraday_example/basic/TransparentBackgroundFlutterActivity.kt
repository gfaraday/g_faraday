package com.yuxiaor.flutter.g_faraday_example.basic

import android.content.Context
import android.graphics.Color
import com.yuxiaor.flutter.g_faraday.FaradayActivity

class TransparentBackgroundFlutterActivity: FaradayActivity() {
    companion object {
        fun build(context: Context) = builder<TransparentBackgroundFlutterActivity>("transparent_flutter",
                backgroundColor = Color.TRANSPARENT).build(context)
    }
}