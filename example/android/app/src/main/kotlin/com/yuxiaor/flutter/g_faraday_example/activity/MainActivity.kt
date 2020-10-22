package com.yuxiaor.flutter.g_faraday_example.activity

import android.annotation.SuppressLint
import android.content.Intent
import android.os.Bundle
import android.widget.Button
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import com.yuxiaor.flutter.g_faraday.Faraday
import com.yuxiaor.flutter.g_faraday_example.R

class MainActivity : AppCompatActivity() {

    private val infoTxt by lazy { findViewById<TextView>(R.id.infoTxt) }
    private val btn1 by lazy { findViewById<Button>(R.id.btn1) }
    private val btn2 by lazy { findViewById<Button>(R.id.btn2) }

    @SuppressLint("SetTextI18n")
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        //push to flutter
        btn1.setOnClickListener {
            Faraday.openFlutterForResult(this, "home", 1, hashMapOf("data" to "data form native MainActivity"))
        }

        //flutter fragment demo
        btn2.text = "flutter fragment"
        btn2.setOnClickListener {
            startActivity(Intent(this, FragActivity::class.java))
        }
    }

    /**
     * on flutter result
     */
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        val map = hashMapOf<String, Any?>()
        data?.extras?.keySet()?.forEach {
            map[it] = data.extras?.get(it)
        }

        infoTxt.append("\n Flutter 返回的数据：${map}")
    }
}
