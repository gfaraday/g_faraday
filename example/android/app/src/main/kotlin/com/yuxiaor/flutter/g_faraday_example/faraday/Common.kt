package com.yuxiaor.flutter.g_faraday_example.faraday

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.lang.RuntimeException


//
//  Common.kt
//  Faraday
//
//  Created by gix on 2020/9/22.
//

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
    // ---> interface cli_demo/demo.dart|DemoApp
    fun getSomeData(id: String, optionalArg: Boolean?): Any?
    fun showLoading(message: String): Any?
    fun setSomeData(data: Any, id: String): Any?
    // <--- interface cli_demo/demo.dart|DemoApp

    fun defaultHandle(call: MethodCall, result: MethodChannel.Result): Boolean {
        val args: Map<*, *> = call.arguments as? Map<*, *> ?: emptyMap<Any, Any>()
        // ---> impl
    // ---> impl cli_demo/demo.dart|DemoApp
        if (call.method == "cli_demo/demo.dart|DemoApp#getSomeData") {
            val id = args["id"] as? String ?: throw IllegalArgumentException("Invalid argument: id")
           val optionalArg = args["optionalArg"] as? Boolean
            // invoke getSomeData
            result.success(getSomeData(id, optionalArg))
            return true
        }
        if (call.method == "cli_demo/demo.dart|DemoApp#showLoading") {
            val message = args["message"] as? String ?: throw IllegalArgumentException("Invalid argument: message")
            // invoke showLoading
            result.success(showLoading(message))
            return true
        }
        if (call.method == "cli_demo/demo.dart|DemoApp#setSomeData") {
            val data = args["data"] as? Any ?: throw IllegalArgumentException("Invalid argument: data")
           val id = args["id"] as? String ?: throw IllegalArgumentException("Invalid argument: id")
            // invoke setSomeData
            result.success(setSomeData(data, id))
            return true
        }
    // <--- impl cli_demo/demo.dart|DemoApp
        return false
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (!defaultHandle(call, result)) {
            print("Faraday->Warning ${call.method} not handle. argument: ${call.arguments}")
        }
    }
}