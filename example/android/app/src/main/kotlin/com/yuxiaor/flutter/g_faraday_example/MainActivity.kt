package com.yuxiaor.flutter.g_faraday_example

import android.annotation.SuppressLint
import android.content.Intent
import android.os.Bundle
import android.widget.Button
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import com.yuxiaor.flutter.g_faraday.openFlutter

class MainActivity : AppCompatActivity() {


    @SuppressLint("SetTextI18n")
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        val infoTxt = findViewById<TextView>(R.id.infoTxt)
        val btn1 = findViewById<Button>(R.id.btn1)
        val btn2 = findViewById<Button>(R.id.btn2)

        //push to flutter
        btn1.setOnClickListener {
            openFlutter("home", "data" to "data form native MainActivity") { map ->
                infoTxt.append("\n Flutter 返回的数据：${map}")
            }
        }

        btn2.text = "flutter fragment"
        btn2.setOnClickListener {
            startActivity(Intent(this, FragmentPage::class.java))
        }
    }
}
