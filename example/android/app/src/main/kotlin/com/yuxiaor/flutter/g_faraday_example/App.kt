package com.yuxiaor.flutter.g_faraday_example

import android.app.Application
import com.yuxiaor.flutter.g_faraday.Faraday
import io.flutter.plugins.GeneratedPluginRegistrant

/**
 * Author: Edward
 * Date: 2020-09-02
 * Description:
 */
class App : Application() {

    override fun onCreate() {
        super.onCreate()
        if (!Faraday.initEngine(this, MyFlutterNavigator())) {
            GeneratedPluginRegistrant.registerWith(Faraday.engine)
        }
    }
}