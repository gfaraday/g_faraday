package com.yuxiaor.flutter.g_faraday.channels

import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.*

/**
 * Author: Edward
 * Date: 2020-10-15
 * Description:网络桥接
 */
internal class NetChannel(messenger: BinaryMessenger, private val handler: NetHandler) : MethodChannel.MethodCallHandler {

    private val channel = MethodChannel(messenger, "g_faraday/net")

    init {
        channel.setMethodCallHandler(this)
    }


    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val url = call.argument<String>("url") ?: return
        val params = call.argument<HashMap<String, Any>>("parameters")
        val headers = call.argument<HashMap<String, String>>("headers")
        handler.request(call.method, url, params, headers) {
            result.success(it)
        }
    }
}


interface NetHandler {

    /**
     * @param method GET POST PUT DELETE ...
     * @param url
     * @param params request params
     * @param headers request headers
     * @param onComplete callback the request response
     */
    fun request(method: String, url: String, params: HashMap<String, Any>?, headers: HashMap<String, String>?, onComplete: (result: Any?) -> Unit)

}