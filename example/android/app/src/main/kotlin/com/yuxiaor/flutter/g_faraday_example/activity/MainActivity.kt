package com.yuxiaor.flutter.g_faraday_example.activity

import android.os.Bundle
import android.os.Handler
import androidx.appcompat.app.AppCompatActivity
import com.yuxiaor.flutter.g_faraday.Faraday
import com.yuxiaor.flutter.g_faraday.FaradayActivity
import com.yuxiaor.flutter.g_faraday_example.R
import com.yuxiaor.flutter.g_faraday_example.activity.splash.FirstFlutterActivity
import com.yuxiaor.flutter.g_faraday_example.faraday.CustomNavigator
import io.flutter.embedding.engine.plugins.util.GeneratedPluginRegister

class MainActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
    }

    override fun onStart() {
        super.onStart()

        if (!Faraday.initEngine(this, CustomNavigator)) {
            GeneratedPluginRegister.registerGeneratedPlugins(Faraday.engine)
        }

        // 跳转到 flutter `home` 路由
        val intent = FirstFlutterActivity.build(this)

        // 直接打开flutter 页面
        startActivity(intent)

        //
        finish()

        // 阻止动画
        overridePendingTransition(0, 0)

    }
}
