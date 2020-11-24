package com.yuxiaor.flutter.g_faraday_example.activity

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import com.yuxiaor.flutter.g_faraday.FaradayActivity
import com.yuxiaor.flutter.g_faraday_example.R

class MainActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
    }

    override fun onResume() {
        super.onResume()

        // 跳转到 flutter `home` 路由
        val intent = FaradayActivity.build(this, "home", willTransactionWithAnother = true)

        // 直接打开flutter 页面
        startActivityForResult(intent, 1)
    }
}
