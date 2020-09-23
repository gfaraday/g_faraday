package com.yuxiaor.flutter.g_faraday_example.faraday

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.*

//  Created by faraday_cli on 2020-09-23 18:47:14.233496.
//
//    ___                   _
//   / __\_ _ _ __ __ _  __| | __ _ _   _
//  / _\/ _` | '__/ _` |/ _` |/ _` | | | |
// / / | (_| | | | (_| | (_| | (_| | |_| |
// \/   \__,_|_|  \__,_|\__,_|\__,_|\__, |
//                                  |___/
//
// GENERATED CODE BY FARADAY CLI - DO NOT MODIFY BY HAND


fun flutterNetBridge(call: MethodCall, result: MethodChannel.Result) {
    val args: Map<*, *> = call.arguments as? Map<*, *> ?: emptyMap<Any, Any>()
    val method = call.method.toUpperCase(Locale.ROOT)

    val query = args["query"] as? Map<*, *>
    val body = args["body"] as? Map<*, *>
    val additions = args["additions"]

    result.notImplemented()
}

