package com.yuxiaor.flutter.g_faraday_example

import android.app.Application
import com.yuxiaor.flutter.g_faraday.Faraday
import com.yuxiaor.flutter.g_faraday_example.faraday.CustomNavigator
import io.flutter.embedding.engine.plugins.util.GeneratedPluginRegister

/**
 * Author: Edward
 * Date: 2020-09-02
 * Description:
 */
class App : Application() {
    override fun onCreate() {
        super.onCreate()
        if (!Faraday.initEngine(this, CustomNavigator)) {
            GeneratedPluginRegister.registerGeneratedPlugins(Faraday.engine)
        }
    }
}
