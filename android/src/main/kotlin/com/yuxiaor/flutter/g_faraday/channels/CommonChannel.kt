package com.yuxiaor.flutter.g_faraday.channels

import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

/**
 * Author: Edward
 * Date: 2020-09-28
 * Description:桥接通道
 */
internal class CommonChannel(messenger: BinaryMessenger, handler: MethodChannel.MethodCallHandler) {

    private val channel by lazy { MethodChannel(messenger, "g_faraday/common") }

    init {
        channel.setMethodCallHandler(handler)
    }

}