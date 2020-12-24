package com.yuxiaor.flutter.g_faraday_example.basic

import android.content.Intent
import android.graphics.Color
import android.os.Bundle
import android.widget.Button
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import com.yuxiaor.flutter.g_faraday.FaradayActivity
import com.yuxiaor.flutter.g_faraday_example.R
import com.yuxiaor.flutter.g_faraday_example.faraday.KEY_ARGS
import java.util.*

class Native2FlutterActivity: AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_native2flutter)

        findViewById<Button>(R.id.button).setOnClickListener {
            val intent = FaradayActivity.builder(routeName = "native2flutter", Date().toString()).build(this)
            startActivityForResult(intent, 1)
        }

        findViewById<Button>(R.id.transparentButton).setOnClickListener {
            val intent = TransparentBackgroundFlutterActivity.build(this)
            startActivity(intent)
            // 阻止动画
            overridePendingTransition(0, 0)
        }

        actionBar?.title = "Native2Flutter"
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        data?.extras.let {
            val textView = findViewById<TextView>(R.id.result)
            if (it != null) {
                textView.text = it.get(KEY_ARGS)?.toString()
                textView.setTextColor(Color.RED)
            } else {
                textView.text = null
            }
        }
    }
}