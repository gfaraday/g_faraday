package com.yuxiaor.flutter.g_faraday_example.basic

import android.content.Intent
import android.os.Bundle
import android.widget.Button
import androidx.appcompat.app.AppCompatActivity
import com.yuxiaor.flutter.g_faraday.Faraday
import com.yuxiaor.flutter.g_faraday.FaradayActivity
import com.yuxiaor.flutter.g_faraday.channels.popToAnchor
import com.yuxiaor.flutter.g_faraday_example.R
import java.util.*

/**
 * Author: Edward
 * Date: 2020-11-26
 * Description:
 */
class FlutterToNativeActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_flutter2native)
        findViewById<Button>(R.id.btn).setOnClickListener {
            val intent = Intent()
            intent.putExtra("date", Date().toString())
            setResult(RESULT_OK, intent)
            finish()
        }
        findViewById<Button>(R.id.popButton).setOnClickListener {
            Faraday.popToAnchor("home")
        }
        actionBar?.title = "Flutter2Native"
    }

}