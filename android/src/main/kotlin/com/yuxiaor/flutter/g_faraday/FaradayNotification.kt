package com.yuxiaor.flutter.g_faraday

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Author: Edward
 * Date: 2020-09-28
 * Description:通知
 */
object FaradayNotification : MethodChannel.MethodCallHandler {

    private val notifications = hashMapOf<String, NotificationCallback>()

    private var channel: MethodChannel? = null

    internal fun init(channel: MethodChannel) {
        FaradayNotification.channel = channel
        channel.setMethodCallHandler(this)
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