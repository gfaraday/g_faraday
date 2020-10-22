package com.yuxiaor.flutter.g_faraday

import java.io.Serializable

/**
 * Author: Edward
 * Date: 2020-09-02
 * Description:
 */

interface FaradayNavigator {

    /**
     * open native Activity
     */
    fun push(name: String, arguments: Serializable?, options: HashMap<String, *>?, callback: (result: HashMap<String, *>?) -> Unit)

    /**
     * finish flutter container Activity
     */
    fun pop(result: Serializable?)

    /**
     * 是否允许滑动返回
     */
    fun enableSwipeBack(enable: Boolean)
}
