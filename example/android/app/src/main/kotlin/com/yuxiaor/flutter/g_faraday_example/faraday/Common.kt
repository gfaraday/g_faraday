package com.yuxiaor.flutter.g_faraday_example.faraday

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

//  Created by faraday_cli on 2020-09-24 09:48:07.370618.
//
//    ___                   _
//   / __\_ _ _ __ __ _  __| | __ _ _   _
//  / _\/ _` | '__/ _` |/ _` |/ _` | | | |
// / / | (_| | | | (_| | (_| | (_| | |_| |
// \/   \__,_|_|  \__,_|\__,_|\__,_|\__, |
//                                  |___/
//
// GENERATED CODE BY FARADAY CLI - DO NOT MODIFY BY HAND


interface Common: MethodChannel.MethodCallHandler {
    // ---> interface

    fun defaultHandle(call: MethodCall, result: MethodChannel.Result): Boolean {
        val args: Map<*, *> = call.arguments as? Map<*, *> ?: emptyMap<Any, Any>()
        // ---> impl

        return false
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (!defaultHandle(call, result)) {
            print("Faraday->Warning ${call.method} not handle. argument: ${call.arguments}")
        }
    }
}
