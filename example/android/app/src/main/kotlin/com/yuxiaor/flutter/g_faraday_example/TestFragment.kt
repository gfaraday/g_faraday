package com.yuxiaor.flutter.g_faraday_example

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.fragment.app.Fragment

/**
 * Author: Edward
 * Date: 2020-09-07
 * Description:
 */
class TestFragment : Fragment() {


    companion object {

        fun newInstance(text: String): TestFragment {
            return TestFragment().apply {
                arguments = Bundle().apply {
                    putString("text", text)
                }
            }
        }
    }

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        return inflater.inflate(R.layout.frag_test, container, false)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        val textView = view.findViewById<TextView>(R.id.fragText)
        textView.text = arguments?.getString("text")
    }

}