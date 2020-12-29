package com.yuxiaor.flutter.g_faraday

import android.content.Intent
import java.io.Serializable

/**
 * Author: Edward
 * Date: 2020-09-02
 * Description:
 */

data class Options(val raw: HashMap<String, *>?) {

    val animated: Boolean
        get() = get("_faraday.animated", true)

    val present: Boolean
        get() = get("_faraday.present", false)

    val isFlutterRoute: Boolean
        get() = get("_faraday.flutter", false)

    inline fun <reified T> get(key: String, defaultValue: T): T {
        if (raw == null) return defaultValue
        val value = raw[key]
        if (value is T) return value;
        return defaultValue
    }
}

interface FaradayNavigator {

    /**
     * create native Intent
     */
    fun create(name: String, arguments: Serializable?, options: Options): Intent?

    /**
     * finish flutter container Activity
     */
    fun pop(result: Serializable?)

    /**
     * 是否允许滑动返回
     */
    fun enableSwipeBack(enable: Boolean)
}
