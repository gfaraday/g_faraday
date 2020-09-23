package com.yuxiaor.flutter.g_faraday_example

import android.app.Application
import com.yuxiaor.flutter.g_faraday.Faraday
import com.yuxiaor.flutter.g_faraday_example.faraday.flutterNetBridge

/**
 * Author: Edward
 * Date: 2020-09-02
 * Description:
 */
class App : Application() {

    override fun onCreate() {
        super.onCreate()
        Faraday.startFlutterEngine(MyFlutterNavigator())
    }
}