package com.yuxiaor.flutter.g_faraday.utils

import android.content.Intent
import android.os.Bundle
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentActivity
import java.util.concurrent.atomic.AtomicInteger

/**
 * Author: Edward
 * Date: 2020-09-02
 * Description:
 */

/**
 * Start Activity for result with args.
 */
inline fun <reified T> FragmentActivity.startForResult(vararg param: Pair<String, Any?>, noinline callback: (resultCode: Int, data: Intent?) -> Unit) {
    startForResult(Intent(this, T::class.java).fillArgs(param), callback)
}

/**
 * Start Activity for result with Intent
 */
fun FragmentActivity.startForResult(intent: Intent, callback: (resultCode: Int, data: Intent?) -> Unit) {
    ResultFragment.get(this).startForResult(intent, callback)
}


internal class ResultFragment private constructor() : Fragment() {

    companion object {
        private const val TAG = "ResultFragment"
        fun get(activity: FragmentActivity): ResultFragment {
            val manager = activity.supportFragmentManager
            var fragment = manager.findFragmentByTag(TAG)
            if (fragment == null) {
                fragment = ResultFragment()
                manager.beginTransaction().add(fragment, TAG).commitAllowingStateLoss()
                manager.executePendingTransactions()
            }
            return fragment as ResultFragment
        }
    }

    private val nextLocalRequestCode = AtomicInteger()
    private val resultMap = mutableMapOf<Int, (Int, Intent?) -> Unit>()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        retainInstance = true
    }

    fun startForResult(intent: Intent, listener: (Int, Intent?) -> Unit) {
        val requestCode = nextLocalRequestCode.getAndIncrement()
        resultMap[requestCode] = listener
        startActivityForResult(intent, requestCode)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        val listener = resultMap.remove(requestCode)
        listener?.invoke(resultCode, data)
    }
}