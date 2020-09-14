package com.yuxiaor.flutter.g_faraday

import android.content.Context
import android.os.Bundle
import io.flutter.embedding.android.FlutterFragment
import io.flutter.embedding.android.TransparencyMode
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
            val args = hashMapOf(*params).apply {
                this["name"] = route
            }
            val bundle = Bundle().apply {
                putSerializable(Faraday.FLUTTER_ARGS_KEY, args)
                putString(ARG_FLUTTERVIEW_TRANSPARENCY_MODE, TransparencyMode.opaque.name)
            }
            return FaradayFragment().apply { arguments = bundle }
        }
    }


    override fun provideFlutterEngine(context: Context): FlutterEngine? {
        return Faraday.engine
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        val args = arguments?.getSerializable(Faraday.FLUTTER_ARGS_KEY)
        Faraday.onPageCreate(args) {
            seqId = it
        }
        super.onCreate(savedInstanceState)
    }


    override fun onHiddenChanged(hidden: Boolean) {
        if (!hidden) {
            Faraday.onPageShow(seqId)
        } else {
            Faraday.onPageHidden(seqId)
        }
        super.onHiddenChanged(hidden)
    }

    override fun onResume() {
        Faraday.onPageShow(seqId)
        super.onResume()
    }

    override fun onPause() {
        Faraday.onPageHidden(seqId)
        super.onPause()
    }

    override fun onDetach() {
        Faraday.onPageDealloc(seqId)
        super.onDetach()
    }

    override fun onDestroy() {
        Faraday.onPageDealloc(seqId)
        super.onDestroy()
    }

}