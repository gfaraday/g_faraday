package com.yuxiaor.flutter.g_faraday

import android.content.Context
import android.os.Bundle
import io.flutter.embedding.android.FlutterFragment
import io.flutter.embedding.engine.FlutterEngine

/**
 * Author: Edward
 * Date: 2020-09-07
 * Description:
 */
class FaradayFragment private constructor() : FlutterFragment() {

    private var seqId = 0


    companion object {

        @JvmStatic
        fun newInstance(route: String, vararg params: Pair<String, Any>): FaradayFragment {
            val args = hashMapOf(*params).apply { this["name"] = route }
            val bundle = Bundle().apply { putSerializable(Faraday.FLUTTER_ARGS_KEY, args) }
            return FaradayFragment().apply { arguments = bundle }
        }
    }


    override fun provideFlutterEngine(context: Context): FlutterEngine? {
        return Faraday.engine
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val args = arguments?.getSerializable(Faraday.FLUTTER_ARGS_KEY)
        Faraday.onPageCreate(args) {
            seqId = it
        }
    }


    override fun onHiddenChanged(hidden: Boolean) {
        super.onHiddenChanged(hidden)
        if (!hidden) {
            Faraday.onPageShow(seqId)
        } else {
            Faraday.onPageHidden(seqId)
        }
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