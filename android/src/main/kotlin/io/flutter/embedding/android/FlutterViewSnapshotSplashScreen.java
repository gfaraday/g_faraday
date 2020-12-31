package io.flutter.embedding.android;

import android.animation.Animator;
import android.content.Context;
import android.graphics.Bitmap;
import android.os.Bundle;
import android.view.View;
import android.widget.ImageView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import io.flutter.embedding.engine.FlutterEngine;

public class FlutterViewSnapshotSplashScreen implements SplashScreen {

    @NonNull
    private final Bitmap flutterViewSnapshot;
    @Nullable
    private View splashView;

    public FlutterViewSnapshotSplashScreen(@NonNull FlutterEngine flutterEngine) {
        flutterViewSnapshot = flutterEngine.getRenderer().getBitmap();
    }

    @Nullable
    @Override
    public View createSplashView(@NonNull Context context, @Nullable Bundle savedInstanceState) {
        // 这里不能重用
        //        if (splashView != null) return splashView;
        ImageView splash = new ImageView(context);
        splash.setImageBitmap(flutterViewSnapshot);
        splashView = splash;
        return splash;
    }

    @Override
    public void transitionToFlutter(@NonNull final Runnable onTransitionComplete) {
        if (splashView == null) {
            onTransitionComplete.run();
            return;
        }

        splashView
                .animate()
                .alpha(0.0f)
                .setDuration(500)
                .setListener(
                        new Animator.AnimatorListener() {
                            @Override
                            public void onAnimationStart(Animator animation) {
                            }

                            @Override
                            public void onAnimationEnd(Animator animation) {
                                onTransitionComplete.run();
                            }

                            @Override
                            public void onAnimationCancel(Animator animation) {
                                onTransitionComplete.run();
                            }

                            @Override
                            public void onAnimationRepeat(Animator animation) {
                            }
                        });
    }
}
