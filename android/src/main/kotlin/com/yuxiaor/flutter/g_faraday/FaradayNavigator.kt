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
    fun push(name: String, arguments: Serializable?, callback: (result: HashMap<String, Any?>?) -> Unit)

    /**
     * finish flutter container Activity
     */
    fun pop(result: Serializable?)

    /**
     * 是否允许滑动返回
     */
    fun onSwipeBack(enable: Boolean)
}
