package com.yuxiaor.flutter.g_faraday.channels

import android.app.Activity
import android.content.Intent
import com.yuxiaor.flutter.g_faraday.Faraday
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

internal object NavigatorAnchor: MethodChannel.MethodCallHandler {

    private val channel = MethodChannel(Faraday.engine.dartExecutor, "g_faraday/anchor")

    private lateinit var anchors: MutableMap<String, Class<Activity>>

    init {
        channel.setMethodCallHandler(this)
    }

    fun setup() {
        anchors = mutableMapOf()
    }

    fun popToAnchor(identifier: String) {
        channel.invokeMethod("popToAnchor", identifier)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when(call.method) {
            "addAnchor" -> {
                val key = call.arguments as String
                Faraday.getCurrentActivity()?.let {
                    anchors[key] = it.javaClass
                }
            }
            "removeAnchor" -> {
                val key = call.arguments as String
                anchors.remove(key)
            }
            "replaceAnchor" -> {
                val args = call.arguments as Map<*, *>
                val key = args["id"] as String
                val oldKey = args["oldID"] as String
                anchors[oldKey]?.let {
                    anchors.remove(oldKey)
                    anchors[key] = it
                }
            }
            "popToAnchor" -> {
                val context = Faraday.getCurrentActivity() ?: return
                val key = call.arguments as String
                val intent = Intent(context, anchors[key])
                intent.flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
                context.startActivity(intent)
            }
        }
    }
}

fun Faraday.popToAnchor(identifier: String) {
    NavigatorAnchor.popToAnchor(identifier)
}