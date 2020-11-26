package com.yuxiaor.flutter.g_faraday

import android.content.Intent
import java.io.Serializable

/**
 * Author: Edward
 * Date: 2020-09-02
 * Description:
 */

interface FaradayNavigator {

    /**
     * create native Intent
     */
    fun create(name: String, arguments: Serializable?, options: HashMap<String, *>?): Intent?

    /**
     * finish flutter container Activity
     */
    fun pop(result: Serializable?)

    /**
     * 是否允许滑动返回
     */
    fun enableSwipeBack(enable: Boolean)
}
