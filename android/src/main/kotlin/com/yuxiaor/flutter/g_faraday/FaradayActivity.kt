package com.yuxiaor.flutter.g_faraday

import android.content.Context
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

/**
 * Author: Edward
 * Date: 2020-09-01
 * Description:
 */
class FaradayActivity : FlutterActivity() {

    private var seqId = 0

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        //native -> flutter  args
        val args = intent.getSerializableExtra(Faraday.FLUTTER_ARGS_KEY)
        Faraday.onPageCreate(args) {
            seqId = it
        }
    }

    override fun provideFlutterEngine(context: Context): FlutterEngine? {
        return Faraday.engine
    }

    override fun onResume() {
        super.onResume()
        Faraday.onPageShow(seqId)
    }


    override fun onPause() {
        super.onPause()
        Faraday.onPageHidden(seqId)

    }

    override fun onDestroy() {
        super.onDestroy()
        Faraday.onPageDealloc(seqId)
    }


}