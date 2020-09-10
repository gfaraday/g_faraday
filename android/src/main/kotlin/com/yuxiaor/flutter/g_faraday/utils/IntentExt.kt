package com.yuxiaor.flutter.g_faraday.utils

import android.content.Intent
import android.os.Bundle
import android.os.Parcelable
import com.yuxiaor.flutter.g_faraday.Faraday
import java.io.Serializable

/**
 * Author: Edward
 * Date: 2020-09-02
 * Description:
 */
fun Intent.fillArgs(params: Array<out Pair<String, Any?>>): Intent {
    params.forEach {
        when (val value = it.second) {
            null -> putExtra(it.first, null as? Serializable?)
            is Int -> putExtra(it.first, value)
            is Long -> putExtra(it.first, value)
            is CharSequence -> putExtra(it.first, value)
            is String -> putExtra(it.first, value)
            is Float -> putExtra(it.first, value)
            is Double -> putExtra(it.first, value)
            is Char -> putExtra(it.first, value)
            is Short -> putExtra(it.first, value)
            is Boolean -> putExtra(it.first, value)
            is Serializable -> putExtra(it.first, value)
            is Bundle -> putExtra(it.first, value)
            is Parcelable -> putExtra(it.first, value)
            is Array<*> -> when {
                value.isArrayOf<CharSequence>() -> putExtra(it.first, value)
                value.isArrayOf<String>() -> putExtra(it.first, value)
                value.isArrayOf<Parcelable>() -> putExtra(it.first, value)
                else -> throw Exception("Intent extra ${it.first} has wrong type ${value.javaClass.name}")
            }
            is IntArray -> putExtra(it.first, value)
            is LongArray -> putExtra(it.first, value)
            is FloatArray -> putExtra(it.first, value)
            is DoubleArray -> putExtra(it.first, value)
            is CharArray -> putExtra(it.first, value)
            is ShortArray -> putExtra(it.first, value)
            is BooleanArray -> putExtra(it.first, value)
            else -> throw Exception("Intent extra ${it.first} has wrong type ${value.javaClass.name}")
        }
    }
    return this
}

/**
 * 获取Intent携带的所有数据
 */
fun Intent.getArgs(): HashMap<String, Any?> {
    val map = hashMapOf<String, Any?>()
    extras?.keySet()?.forEach {
        map[it] = extras?.get(it)
    }
    return map
}


/**
 * 从flutter页面传给原生页面的数据
 */
fun Intent.getFlutterArgs(): Serializable? {
    return getSerializableExtra(Faraday.ARGS_KEY)
}