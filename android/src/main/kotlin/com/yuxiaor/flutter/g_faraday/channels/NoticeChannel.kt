package com.yuxiaor.flutter.g_faraday.channels

import com.yuxiaor.flutter.g_faraday.Faraday
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Author: Edward
 * Date: 2020-09-28
 * Description:通知
 */
internal object FaradayNotice : MethodChannel.MethodCallHandler {

    private val notifications = hashMapOf<String, NotificationCallback>()
    private var channel: MethodChannel? = null

    fun setup(dartExecutor: DartExecutor) {
        channel = MethodChannel(dartExecutor, "g_faraday/notification")
        channel?.setMethodCallHandler(this)
    }


    /**
     * 发送通知  native -> flutter
     */
    fun post(key: String, arguments: Any?) {
        channel?.invokeMethod(key, arguments)
    }

    /**
     * 注册接收通知  flutter -> native
     */
    fun register(key: String, callback: (arguments: Any?) -> Unit) {
        notifications[key] = object : NotificationCallback {
            override fun onReceiveNotification(arguments: Any?) {
                callback.invoke(arguments)
            }
        }
    }

    /**
     * for java
     */
    fun register(key: String, callback: NotificationCallback) {
        notifications[key] = callback
    }

    /**
     * 解除注册
     */
    fun unregister(key: String) {
        notifications.remove(key)
    }


    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val key = call.method
        val args = call.arguments
        notifications[key]?.onReceiveNotification(args)

        result.success(notifications.containsKey(key))
    }
}


interface NotificationCallback {

    fun onReceiveNotification(arguments: Any?)
}



/**
 * post notification  form native to flutter
 */
fun Faraday.postNotification(key: String, arguments: Any?) {
    FaradayNotice.post(key, arguments)
}

/**
 * receive notification from flutter
 */
fun Faraday.registerNotification(key: String, callback: (arguments: Any?) -> Unit) {
    FaradayNotice.register(key, callback)
}

fun Faraday.unregisterNotification(key: String) {
    FaradayNotice.unregister(key)
}