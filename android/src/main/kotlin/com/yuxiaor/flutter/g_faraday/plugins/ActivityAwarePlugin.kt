package com.yuxiaor.flutter.g_faraday.plugins

import android.content.Intent
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.PluginRegistry

/**
 * Author: Edward
 * Date: 2020-08-31
 * Description:
 */
class ActivityAwarePlugin : FlutterPlugin, ActivityAware {

    var binding: ActivityPluginBinding? = null

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        this.binding = binding
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    }

    override fun onDetachedFromActivity() {
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    }

    override fun onDetachedFromActivityForConfigChanges() {
    }

    fun addActivityResultListener(listener: PluginRegistry.ActivityResultListener) {
        binding?.addActivityResultListener(listener)
    }

    fun removeActivityResultListener(listener: PluginRegistry.ActivityResultListener) {
        binding?.removeActivityResultListener(listener)
    }
}


class ResultListener(private val activityAwarePlugin: ActivityAwarePlugin, private val callback: (requestCode: Int, resultCode: Int, data: Intent?) -> Unit) : PluginRegistry.ActivityResultListener {

    init {
        activityAwarePlugin.addActivityResultListener(this)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        callback.invoke(requestCode, resultCode, data)
        activityAwarePlugin.removeActivityResultListener(this)
        return false
    }
}