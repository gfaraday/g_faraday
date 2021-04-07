package com.yuxiaor.flutter.g_faraday

import android.animation.Animator
import android.animation.Animator.AnimatorListener
import android.content.Context
import android.graphics.Color
import android.os.Bundle
import android.view.View
import io.flutter.embedding.android.SplashScreen

class FaradayColorBaseSplashScreen(private val color: Int?) : SplashScreen {

    private var splashView: View? = null

    override fun createSplashView(context: Context, savedInstanceState: Bundle?): View? {
        //不能重用
        // if (splashView != null) {
        //     return splashView
        // }
        splashView = View(context)
        splashView?.setBackgroundColor(color ?: Color.WHITE)
        return splashView
    }

    override fun transitionToFlutter(onTransitionComplete: Runnable) {
        if (splashView == null) {
            onTransitionComplete.run()
            return
        }
        splashView!!
                .animate()
                .alpha(0.0f)
                .setDuration(500)
                .setListener(
                        object : AnimatorListener {
                            override fun onAnimationStart(animation: Animator) {}
                            override fun onAnimationEnd(animation: Animator) {
                                onTransitionComplete.run()
                            }

                            override fun onAnimationCancel(animation: Animator) {
                                onTransitionComplete.run()
                            }

                            override fun onAnimationRepeat(animation: Animator) {}
                        })
    }
}