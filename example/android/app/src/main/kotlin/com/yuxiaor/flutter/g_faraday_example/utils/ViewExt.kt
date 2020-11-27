package com.yuxiaor.flutter.g_faraday_example.utils

import android.content.res.Resources
import android.graphics.Outline
import android.util.TypedValue
import android.view.View
import android.view.ViewOutlineProvider

/**
 * Author: Edward
 * Date: 2020-11-27
 * Description:
 */
val Float.dp
    get() = TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, this, Resources.getSystem().displayMetrics)
val Int.dp
    get() = TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, this.toFloat(), Resources.getSystem().displayMetrics).toInt()
val Float.sp
    get() = TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_SP, this, Resources.getSystem().displayMetrics)

fun View.setCorner(corner: Float) {
    clipToOutline = true
    outlineProvider = object : ViewOutlineProvider() {
        override fun getOutline(view: View, outline: Outline) {
            outline.setRoundRect(0, 0, view.measuredWidth, view.measuredHeight, corner.dp)
        }
    }
}