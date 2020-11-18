package com.yuxiaor.flutter.g_faraday_example.activity

import android.os.Bundle
import android.widget.RadioButton
import androidx.appcompat.app.AppCompatActivity
import androidx.fragment.app.Fragment
import com.yuxiaor.flutter.g_faraday.FaradayFragment
import com.yuxiaor.flutter.g_faraday_example.R
import com.yuxiaor.flutter.g_faraday_example.fragment.TestFragment

/**
 * Author: Edward
 * Date: 2020-09-07
 * Description:
 */
class FragActivity : AppCompatActivity() {

    private var tempFragment: Fragment? = null
    private val flutterFrag1 = FaradayFragment.newInstance("home")
    private val flutterFrag2 = FaradayFragment.newInstance("flutter_frag")
    private val nativeFrag1 = TestFragment.newInstance("native frag 1")
    private val nativeFrag2 = TestFragment.newInstance("native frag 2")

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_fragment)

        val tab1 = findViewById<RadioButton>(R.id.tab1)
        val tab2 = findViewById<RadioButton>(R.id.tab2)
        val tab3 = findViewById<RadioButton>(R.id.tab3)
        val tab4 = findViewById<RadioButton>(R.id.tab4)

        tab1.setOnClickListener { switchFragment(flutterFrag1, "F1") }
        tab2.setOnClickListener { switchFragment(flutterFrag2, "F2") }
        tab3.setOnClickListener { switchFragment(nativeFrag1, "N1") }
        tab4.setOnClickListener { switchFragment(nativeFrag2, "N2") }

        switchFragment(flutterFrag1, "F1")
    }


    private fun switchFragment(fragment: Fragment, tag: String) {
        if (tempFragment == fragment) return

        val transaction = supportFragmentManager.beginTransaction()
        if (!fragment.isAdded) {
            transaction.add(R.id.frag, fragment, tag)
        }

        transaction.show(fragment)
        tempFragment?.let { transaction.hide(it) }
        tempFragment = fragment
        transaction.commitNow()
    }
}