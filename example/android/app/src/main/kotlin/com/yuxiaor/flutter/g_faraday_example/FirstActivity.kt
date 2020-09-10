package com.yuxiaor.flutter.g_faraday_example

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.widget.Button
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import com.yuxiaor.flutter.g_faraday.openFlutter
import com.yuxiaor.flutter.g_faraday.utils.getFlutterArgs

/**
 * Author: Edward
 * Date: 2020-09-03
 * Description:
 */
class FirstActivity : AppCompatActivity() {


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        val infoTxt = findViewById<TextView>(R.id.infoTxt)
        val btn1 = findViewById<Button>(R.id.btn1)
        val btn2 = findViewById<Button>(R.id.btn2)

//        val argsFromFlutter = Faraday.getFlutterArgs(intent)
        val argsFromFlutter = intent.getFlutterArgs()
        infoTxt.append("flutter 传过来的参数：${argsFromFlutter}")

        btn1.setOnClickListener {
            openFlutter("first_page", "data" to "data form native FirstActivity") { map ->
                infoTxt.append("\n Flutter 返回的数据：${map}")
            }
        }

        //pop to flutter
        btn2.setOnClickListener {
            setResult(Activity.RESULT_OK, Intent().apply { putExtra("data", "data form android first activity") })
            finish()
        }

    }
}