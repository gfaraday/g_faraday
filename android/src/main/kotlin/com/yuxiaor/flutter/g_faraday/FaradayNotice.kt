package com.yuxiaor.flutter.g_faraday

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Author: Edward
 * Date: 2020-09-28
 * Description:通知
 */
internal object FaradayNotice : MethodChannel.MethodCallHandler {

    private val channel by lazy {
        MethodChannel(Faraday.engine?.dartExecutor, "g_faraday/notification").apply {
            setMethodCallHandler(this@FaradayNotice)
        }
    }


    private val notifications = hashMapOf<String, NotificationCallback>()


    /**
     * 发送通知  native -> flutter
     */
    fun post(key: String, arguments: Any?) {
        channel.invokeMethod(key, arguments)
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
    }
}


interface NotificationCallback {

    fun onReceiveNotification(arguments: Any?)
}