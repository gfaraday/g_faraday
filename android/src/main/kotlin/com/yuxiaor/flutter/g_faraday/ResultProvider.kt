package com.yuxiaor.flutter.g_faraday

import android.content.Intent

/**
 * Author: Edward
 * Date: 2020-10-22
 * Description:
 */
interface ResultProvider {
    fun addResultListener(resultListener: ((requestCode: Int, resultCode: Int, data: Intent?) -> Unit))
}