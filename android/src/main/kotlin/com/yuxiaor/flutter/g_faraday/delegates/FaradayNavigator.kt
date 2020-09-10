package com.yuxiaor.flutter.g_faraday.delegates

import java.io.Serializable

/**
 * Author: Edward
 * Date: 2020-09-02
 * Description:
 */

interface FaradayNavigator {

    fun push(name: String, arguments: Serializable?, callback: (result: HashMap<String, Any?>?) -> Unit)

    fun pop(result: Serializable?)
}
