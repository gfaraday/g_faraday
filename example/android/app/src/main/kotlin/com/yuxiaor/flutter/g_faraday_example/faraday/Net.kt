package com.yuxiaor.flutter.g_faraday_example.faraday

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.*

fun flutterNetBridge(call: MethodCall, result: MethodChannel.Result) {
    val args: Map<*, *> = call.arguments as? Map<*, *> ?: emptyMap<Any, Any>()
    val method = call.method.toUpperCase(Locale.ROOT)

    val query = args["query"] as? Map<*, *>
    val body = args["body"] as? Map<*, *>
    val additions = args["additions"]

    result.notImplemented()
}