package com.yuxiaor.flutter.g_faraday

import io.flutter.plugin.common.MethodChannel

/**
 * Author: Edward
 * Date: 2020-09-28
 * Description:桥接通道
 */
internal object InternalChannels {
    //网络
    private val netChannel by lazy { MethodChannel(Faraday.engine?.dartExecutor, "g_faraday/net") }

    //通用
    private val commonChannel by lazy { MethodChannel(Faraday.engine?.dartExecutor, "g_faraday/common") }


    fun setNetHandler(handler: MethodChannel.MethodCallHandler) {
        netChannel.setMethodCallHandler(handler)
    }


    fun setCommonHandler(handler: MethodChannel.MethodCallHandler) {
        commonChannel.setMethodCallHandler(handler)
    }

}
