// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.embedding.android;

import static io.flutter.embedding.android.FlutterActivityLaunchConfigs.DART_ENTRYPOINT_META_DATA_KEY;
import static io.flutter.embedding.android.FlutterActivityLaunchConfigs.DEFAULT_DART_ENTRYPOINT;
import static io.flutter.embedding.android.FlutterActivityLaunchConfigs.EXTRA_BACKGROUND_MODE;
import static io.flutter.embedding.android.FlutterActivityLaunchConfigs.EXTRA_CACHED_ENGINE_ID;
import static io.flutter.embedding.android.FlutterActivityLaunchConfigs.EXTRA_DESTROY_ENGINE_WITH_ACTIVITY;
import static io.flutter.embedding.android.FlutterActivityLaunchConfigs.EXTRA_ENABLE_STATE_RESTORATION;
import static io.flutter.embedding.android.FlutterActivityLaunchConfigs.EXTRA_INITIAL_ROUTE;
import static io.flutter.embedding.android.FlutterActivityLaunchConfigs.INITIAL_ROUTE_META_DATA_KEY;
import static io.flutter.embedding.android.FlutterActivityLaunchConfigs.NORMAL_THEME_META_DATA_KEY;
import static io.flutter.embedding.android.FlutterActivityLaunchConfigs.SPLASH_SCREEN_META_DATA_KEY;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;
import android.os.Build;
import android.os.Bundle;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;
import androidx.annotation.VisibleForTesting;
import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.LifecycleOwner;
import androidx.lifecycle.LifecycleRegistry;

import org.jetbrains.annotations.NotNull;

import io.flutter.Log;
import io.flutter.embedding.android.FlutterActivityLaunchConfigs.BackgroundMode;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.FlutterShellArgs;
import io.flutter.embedding.engine.loader.FlutterLoader;
import io.flutter.embedding.engine.plugins.activity.ActivityControlSurface;
import io.flutter.embedding.engine.plugins.util.GeneratedPluginRegister;
import io.flutter.plugin.platform.PlatformPlugin;


// A number of methods in this class have the same implementation as FlutterFragmentActivity. These
// methods are duplicated for readability purposes. Be sure to replicate any change in this class in
// FlutterFragmentActivity, too.
public abstract class XFlutterActivity extends Activity
        implements XFlutterActivityAndFragmentDelegate.Host, LifecycleOwner {

    private static final String TAG = "XFlutterActivity";

    // Delegate that runs all lifecycle and OS hook logic that is common between
    // XFlutterActivity and FlutterFragment. See the XFlutterActivityAndFragmentDelegate
    // implementation for details about why it exists.
    @VisibleForTesting
    protected XFlutterActivityAndFragmentDelegate delegate;

    @NonNull
    private final LifecycleRegistry lifecycle;

    public XFlutterActivity() {
        lifecycle = new LifecycleRegistry(this);
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        switchLaunchThemeForNormalTheme();

        super.onCreate(savedInstanceState);

        delegate = new XFlutterActivityAndFragmentDelegate(this);
        delegate.onAttach(this);
        delegate.onRestoreInstanceState(savedInstanceState);

        lifecycle.handleLifecycleEvent(Lifecycle.Event.ON_CREATE);

        configureWindowForTransparency();
        setContentView(createFlutterView());
        configureStatusBarForFullscreenFlutterExperience();
    }

    /**
     * Switches themes for this {@code Activity} from the theme used to launch this {@code Activity}
     * to a "normal theme" that is intended for regular {@code Activity} operation.
     *
     * <p>This behavior is offered so that a "launch screen" can be displayed while the application
     * initially loads. To utilize this behavior in an app, do the following:
     *
     * <ol>
     *   <li>Create 2 different themes in style.xml: one theme for the launch screen and one theme for
     *       normal display.
     *   <li>In the launch screen theme, set the "windowBackground" property to a {@code Drawable} of
     *       your choice.
     *   <li>In the normal theme, customize however you'd like.
     *   <li>In the AndroidManifest.xml, set the theme of your {@code XFlutterActivity} to your launch
     *       theme.
     *   <li>Add a {@code <meta-data>} property to your {@code XFlutterActivity} with a name of
     *       "io.flutter.embedding.android.NormalTheme" and set the resource to your normal theme,
     *       e.g., {@code android:resource="@style/MyNormalTheme}.
     * </ol>
     * <p>
     * With the above settings, your launch theme will be used when loading the app, and then the
     * theme will be switched to your normal theme once the app has initialized.
     *
     * <p>Do not change aspects of system chrome between a launch theme and normal theme. Either
     * define both themes to be fullscreen or not, and define both themes to display the same status
     * bar and navigation bar settings. If you wish to adjust system chrome once your Flutter app
     * renders, use platform channels to instruct Android to do so at the appropriate time. This will
     * avoid any jarring visual changes during app startup.
     */
    private void switchLaunchThemeForNormalTheme() {
        try {
            Bundle metaData = getMetaData();
            if (metaData != null) {
                int normalThemeRID = metaData.getInt(NORMAL_THEME_META_DATA_KEY, -1);
                if (normalThemeRID != -1) {
                    setTheme(normalThemeRID);
                }
            } else {
                Log.v(TAG, "Using the launch theme as normal theme.");
            }
        } catch (PackageManager.NameNotFoundException exception) {
            Log.e(
                    TAG,
                    "Could not read meta-data for XFlutterActivity. Using the launch theme as normal theme.");
        }
    }

    @Nullable
    @Override
    public SplashScreen provideSplashScreen() {
        Drawable manifestSplashDrawable = getSplashScreenFromManifest();
        if (manifestSplashDrawable != null) {
            return new DrawableSplashScreen(manifestSplashDrawable);
        } else {
            return null;
        }
    }

    /**
     * Returns a {@link Drawable} to be used as a splash screen as requested by meta-data in the
     * {@code AndroidManifest.xml} file, or null if no such splash screen is requested.
     *
     * <p>See {@link FlutterActivityLaunchConfigs#SPLASH_SCREEN_META_DATA_KEY} for the meta-data key
     * to be used in a manifest file.
     */
    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    @Nullable
    private Drawable getSplashScreenFromManifest() {
        try {
            Bundle metaData = getMetaData();
            int splashScreenId = metaData != null ? metaData.getInt(SPLASH_SCREEN_META_DATA_KEY) : 0;
            return splashScreenId != 0
                    ? getResources().getDrawable(splashScreenId, getTheme())
                    : null;
        } catch (PackageManager.NameNotFoundException e) {
            // This is never expected to happen.
            return null;
        }
    }

    /**
     * Sets this {@code Activity}'s {@code Window} background to be transparent, and hides the status
     * bar, if this {@code Activity}'s desired {@link BackgroundMode} is {@link
     * BackgroundMode#transparent}.
     *
     * <p>For {@code Activity} transparency to work as expected, the theme applied to this {@code
     * Activity} must include {@code <item name="android:windowIsTranslucent">true</item>}.
     */
    private void configureWindowForTransparency() {
        BackgroundMode backgroundMode = getBackgroundMode();
        if (backgroundMode == BackgroundMode.transparent) {
            getWindow().setBackgroundDrawable(new ColorDrawable(Color.TRANSPARENT));
        }
    }

    @NonNull
    private View createFlutterView() {
//        FrameLayout parentLayout = new FrameLayout(getContext());
//        parentLayout.setLayoutParams(new ViewGroup.LayoutParams(-1, -1));
//        parentLayout.setBackgroundColor(Color.YELLOW);
//
//        FrameLayout layout = (FrameLayout) delegate.onCreateView(null, null, null);
//
//        ViewGroup.LayoutParams lp = new ViewGroup.LayoutParams(1000, 1500);
//        layout.setLayoutParams(lp);
//
//        parentLayout.addView(layout);
//
//        TextView textView = new TextView(getContext());
//        textView.setText(layout.toString());
//        textView.setTextColor(Color.RED);
//
//        FrameLayout.LayoutParams flp = new FrameLayout.LayoutParams(-2, -2);
//        flp.gravity = Gravity.CENTER_VERTICAL;
//        textView.setLayoutParams(flp);
//
//        parentLayout.addView(textView);
//
//        return  parentLayout;
        return delegate.onCreateView(
                null /* inflater */, null /* container */, null /* savedInstanceState */);
    }

    private void configureStatusBarForFullscreenFlutterExperience() {
        Window window = getWindow();
        window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
        window.setStatusBarColor(Color.TRANSPARENT);
        window.getDecorView().setSystemUiVisibility(PlatformPlugin.DEFAULT_SYSTEM_UI);
    }

    @Override
    protected void onStart() {
        super.onStart();
        lifecycle.handleLifecycleEvent(Lifecycle.Event.ON_START);
        delegate.onStart();
        if (delegate.isDetached()) {
            delegate.reattach();
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
        lifecycle.handleLifecycleEvent(Lifecycle.Event.ON_RESUME);
        delegate.onResume();
    }

    @Override
    public void onPostResume() {
        super.onPostResume();
        delegate.onPostResume();
    }

    @Override
    protected void onPause() {
        super.onPause();
        delegate.onPause();
        lifecycle.handleLifecycleEvent(Lifecycle.Event.ON_PAUSE);
    }

    @Override
    protected void onStop() {
        super.onStop();
        if (stillAttachedForEvent("onStop")) {
            delegate.onStop();
        }
        lifecycle.handleLifecycleEvent(Lifecycle.Event.ON_STOP);
    }

    @Override
    protected void onSaveInstanceState(@NotNull Bundle outState) {
        super.onSaveInstanceState(outState);
        if (stillAttachedForEvent("onSaveInstanceState")) {
            delegate.onSaveInstanceState(outState);
        }
    }

    /**
     * Irreversibly release this activity's control of the {@link FlutterEngine} and its
     *
     * <p>Calling will disconnect this activity's view from the Flutter renderer, disconnect this
     * activity from plugins' {@link ActivityControlSurface}, and stop system channel messages from
     * this activity.
     *
     * <p>After calling, this activity should be disposed immediately and not be re-used.
     */
    private void release() {
        delegate.onDestroyView();
        delegate.onDetach();
        delegate.release();
        delegate = null;

//        Log.v(TAG, "Detaching FlutterEngine from the Activity that owns this Fragment.");
//        if (isChangingConfigurations()) {
//            provideFlutterEngine(this).getActivityControlSurface().detachFromActivityForConfigChanges();
//        } else {
//            provideFlutterEngine(this).getActivityControlSurface().detachFromActivity();
//        }
    }

    @Override
    public void detachFromFlutterEngine() {
        if (delegate != null) {
            Log.v(
                    TAG,
                    "XFlutterActivity "
                            + this
                            + " connection to the engine "
                            + getFlutterEngine()
                            + " evicted by another attaching activity");
            delegate.detach();
        } else {
            Log.w(TAG, "delegate has been released !!");
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (stillAttachedForEvent("onDestroy")) {
            release();
        }
        lifecycle.handleLifecycleEvent(Lifecycle.Event.ON_DESTROY);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (stillAttachedForEvent("onActivityResult")) {
            delegate.onActivityResult(requestCode, resultCode, data);
        }
    }

    @Override
    protected void onNewIntent(@NonNull Intent intent) {
        // TODO(mattcarroll): change G3 lint rule that forces us to call super
        super.onNewIntent(intent);
        if (stillAttachedForEvent("onNewIntent")) {
            delegate.onNewIntent(intent);
        }
    }

    @Override
    public void onBackPressed() {
        if (stillAttachedForEvent("onBackPressed")) {
            delegate.onBackPressed();
        }
    }

    @Override
    public void onRequestPermissionsResult(
            int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        if (stillAttachedForEvent("onRequestPermissionsResult")) {
            delegate.onRequestPermissionsResult(requestCode, permissions, grantResults);
        }
    }

    @Override
    public void onUserLeaveHint() {
        if (stillAttachedForEvent("onUserLeaveHint")) {
            delegate.onUserLeaveHint();
        }
    }

    @Override
    public void onTrimMemory(int level) {
        super.onTrimMemory(level);
        if (stillAttachedForEvent("onTrimMemory")) {
            delegate.onTrimMemory(level);
        }
    }

    /**
     * {@link XFlutterActivityAndFragmentDelegate.Host} method that is used by {@link
     * XFlutterActivityAndFragmentDelegate} to obtain a {@code Context} reference as needed.
     */
    @Override
    @NonNull
    public Context getContext() {
        return this;
    }

    /**
     * {@link XFlutterActivityAndFragmentDelegate.Host} method that is used by {@link
     * XFlutterActivityAndFragmentDelegate} to obtain an {@code Activity} reference as needed. This
     * reference is used by the delegate to instantiate a {@link FlutterView}, a {@link
     * PlatformPlugin}, and to determine if the {@code Activity} is changing configurations.
     */
    @Override
    @NonNull
    public Activity getActivity() {
        return this;
    }

    /**
     * {@link XFlutterActivityAndFragmentDelegate.Host} method that is used by {@link
     * XFlutterActivityAndFragmentDelegate} to obtain a {@code Lifecycle} reference as needed. This
     * reference is used by the delegate to provide Flutter plugins with access to lifecycle events.
     */
    @Override
    @NonNull
    public Lifecycle getLifecycle() {
        return lifecycle;
    }

    /**
     * {@link XFlutterActivityAndFragmentDelegate.Host} method that is used by {@link
     * XFlutterActivityAndFragmentDelegate} to obtain Flutter shell arguments when initializing
     * Flutter.
     */
    @NonNull
    @Override
    public FlutterShellArgs getFlutterShellArgs() {
        return FlutterShellArgs.fromIntent(getIntent());
    }

    /**
     * Returns the ID of a statically cached {@link FlutterEngine} to use within this {@code
     * XFlutterActivity}, or {@code null} if this {@code XFlutterActivity} does not want to use a cached
     * {@link FlutterEngine}.
     */
    @Override
    @Nullable
    public String getCachedEngineId() {
        return getIntent().getStringExtra(EXTRA_CACHED_ENGINE_ID);
    }

    /**
     * Returns false if the {@link FlutterEngine} backing this {@code XFlutterActivity} should outlive
     * this {@code XFlutterActivity}, or true to be destroyed when the {@code XFlutterActivity} is
     * destroyed.
     *
     * <p>The default value is {@code true} in cases where {@code XFlutterActivity} created its own
     * {@link FlutterEngine}, and {@code false} in cases where a cached {@link FlutterEngine} was
     * provided.
     */
    @Override
    public boolean shouldDestroyEngineWithHost() {
        boolean explicitDestructionRequested =
                getIntent().getBooleanExtra(EXTRA_DESTROY_ENGINE_WITH_ACTIVITY, false);
        if (getCachedEngineId() != null || delegate.isFlutterEngineFromHost()) {
            // Only destroy a cached engine if explicitly requested by app developer.
            return explicitDestructionRequested;
        } else {
            // If this Activity created the FlutterEngine, destroy it by default unless
            // explicitly requested not to.
            return getIntent().getBooleanExtra(EXTRA_DESTROY_ENGINE_WITH_ACTIVITY, true);
        }
    }

    /**
     * The Dart entrypoint that will be executed as soon as the Dart snapshot is loaded.
     *
     * <p>This preference can be controlled by setting a {@code <meta-data>} called {@link
     * FlutterActivityLaunchConfigs#DART_ENTRYPOINT_META_DATA_KEY} within the Android manifest
     * definition for this {@code XFlutterActivity}.
     *
     * <p>Subclasses may override this method to directly control the Dart entrypoint.
     */
    @NonNull
    public String getDartEntrypointFunctionName() {
        try {
            Bundle metaData = getMetaData();
            String desiredDartEntrypoint =
                    metaData != null ? metaData.getString(DART_ENTRYPOINT_META_DATA_KEY) : null;
            return desiredDartEntrypoint != null ? desiredDartEntrypoint : DEFAULT_DART_ENTRYPOINT;
        } catch (PackageManager.NameNotFoundException e) {
            return DEFAULT_DART_ENTRYPOINT;
        }
    }

    /**
     * The initial route that a Flutter app will render upon loading and executing its Dart code.
     *
     * <p>This preference can be controlled with 2 methods:
     *
     * <ol>
     *   <li>Pass a boolean as {@link FlutterActivityLaunchConfigs#EXTRA_INITIAL_ROUTE} with the
     *       launching {@code Intent}, or
     *   <li>Set a {@code <meta-data>} called {@link
     *       FlutterActivityLaunchConfigs#INITIAL_ROUTE_META_DATA_KEY} for this {@code Activity} in
     *       the Android manifest.
     * </ol>
     * <p>
     * If both preferences are set, the {@code Intent} preference takes priority.
     *
     * <p>The reason that a {@code <meta-data>} preference is supported is because this {@code
     * Activity} might be the very first {@code Activity} launched, which means the developer won't
     * have control over the incoming {@code Intent}.
     *
     * <p>Subclasses may override this method to directly control the initial route.
     *
     * <p>If this method returns null and the {@code shouldHandleDeeplinking} returns true, the
     * initial route is derived from the {@code Intent} through the Intent.getData() instead.
     */
    public String getInitialRoute() {
        if (getIntent().hasExtra(EXTRA_INITIAL_ROUTE)) {
            return getIntent().getStringExtra(EXTRA_INITIAL_ROUTE);
        }

        try {
            Bundle metaData = getMetaData();
            return metaData != null ? metaData.getString(INITIAL_ROUTE_META_DATA_KEY) : null;
        } catch (PackageManager.NameNotFoundException e) {
            return null;
        }
    }

    /**
     * A custom path to the bundle that contains this Flutter app's resources, e.g., Dart code
     * snapshots.
     *
     * <p>When this {@code XFlutterActivity} is run by Flutter tooling and a data String is included in
     * the launching {@code Intent}, that data String is interpreted as an app bundle path.
     *
     * <p>When otherwise unspecified, the value is null, which defaults to the app bundle path defined
     * in {@link FlutterLoader#findAppBundlePath()}.
     *
     * <p>Subclasses may override this method to return a custom app bundle path.
     */
    @NonNull
    public String getAppBundlePath() {
        // If this Activity was launched from tooling, and the incoming Intent contains
        // a custom app bundle path, return that path.
        // TODO(mattcarroll): determine if we should have an explicit FlutterTestActivity instead of
        // conflating.
        if (isDebuggable() && Intent.ACTION_RUN.equals(getIntent().getAction())) {
            return getIntent().getDataString();
        }

        return null;
    }

    /**
     * Returns true if Flutter is running in "debug mode", and false otherwise.
     *
     * <p>Debug mode allows Flutter to operate with hot reload and hot restart. Release mode does not.
     */
    private boolean isDebuggable() {
        return (getApplicationInfo().flags & ApplicationInfo.FLAG_DEBUGGABLE) != 0;
    }

    /**
     * {@link XFlutterActivityAndFragmentDelegate.Host} method that is used by {@link
     * XFlutterActivityAndFragmentDelegate} to obtain the desired {@link RenderMode} that should be
     * used when instantiating a {@link FlutterView}.
     */
    @NonNull
    @Override
    public RenderMode getRenderMode() {
        return getBackgroundMode() == BackgroundMode.opaque ? RenderMode.surface : RenderMode.texture;
    }

    /**
     * {@link XFlutterActivityAndFragmentDelegate.Host} method that is used by {@link
     * XFlutterActivityAndFragmentDelegate} to obtain the desired {@link TransparencyMode} that should
     * be used when instantiating a {@link FlutterView}.
     */
    @NonNull
    @Override
    public TransparencyMode getTransparencyMode() {
//        return getBackgroundMode() == BackgroundMode.opaque
//                ? TransparencyMode.opaque
//                : TransparencyMode.transparent;
        return TransparencyMode.transparent;
    }

    /**
     * The desired window background mode of this {@code Activity}, which defaults to {@link
     * BackgroundMode#opaque}.
     */
    @NonNull
    protected BackgroundMode getBackgroundMode() {
        if (getIntent().hasExtra(EXTRA_BACKGROUND_MODE)) {
            return BackgroundMode.valueOf(getIntent().getStringExtra(EXTRA_BACKGROUND_MODE));
        } else {
            return BackgroundMode.opaque;
        }
    }

    /**
     * Hook for subclasses to easily provide a custom {@link FlutterEngine}.
     *
     * <p>This hook is where a cached {@link FlutterEngine} should be provided, if a cached {@link
     * FlutterEngine} is desired.
     */
    @Nullable
    @Override
    public FlutterEngine provideFlutterEngine(@NonNull Context context) {
        // No-op. Hook for subclasses.
        return null;
    }

    /**
     * Hook for subclasses to obtain a reference to the {@link FlutterEngine} that is owned by this
     * {@code XFlutterActivity}.
     */
    @Nullable
    protected FlutterEngine getFlutterEngine() {
        return delegate.getFlutterEngine();
    }

    /**
     * Retrieves the meta data specified in the AndroidManifest.xml.
     */
    @Nullable
    protected Bundle getMetaData() throws PackageManager.NameNotFoundException {
        ActivityInfo activityInfo =
                getPackageManager().getActivityInfo(getComponentName(), PackageManager.GET_META_DATA);
        return activityInfo.metaData;
    }

    @Nullable
    @Override
    public PlatformPlugin providePlatformPlugin(
            @Nullable Activity activity, @NonNull FlutterEngine flutterEngine) {
        if (activity != null) {
            return new PlatformPlugin(getActivity(), flutterEngine.getPlatformChannel());
        } else {
            return null;
        }
    }

    /**
     * Hook for subclasses to easily configure a {@code FlutterEngine}.
     *
     * <p>This method is called after {@link #provideFlutterEngine(Context)}.
     *
     * <p>All plugins listed in the app's pubspec are registered in the base implementation of this
     * method. To avoid automatic plugin registration, override this method without invoking super().
     * To keep automatic plugin registration and further configure the flutterEngine, override this
     * method, invoke super(), and then configure the flutterEngine as desired.
     */
    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        GeneratedPluginRegister.registerGeneratedPlugins(flutterEngine);
    }

    /**
     * Hook for the host to cleanup references that were established in {@link
     * #configureFlutterEngine(FlutterEngine)} before the host is destroyed or detached.
     *
     * <p>This method is called in {@link #onDestroy()}.
     */
    @Override
    public void cleanUpFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        // No-op. Hook for subclasses.
    }

    /**
     * Hook for subclasses to control whether or not the {@link FlutterFragment} within this {@code
     * Activity} automatically attaches its {@link FlutterEngine} to this {@code Activity}.
     *
     * <p>This property is controlled with a protected method instead of an {@code Intent} argument
     * because the only situation where changing this value would help, is a situation in which {@code
     * XFlutterActivity} is being subclassed to utilize a custom and/or cached {@link FlutterEngine}.
     *
     * <p>Defaults to {@code true}.
     *
     * <p>Control surfaces are used to provide Android resources and lifecycle events to plugins that
     * are attached to the {@link FlutterEngine}. If {@code shouldAttachEngineToActivity} is true then
     * this {@code XFlutterActivity} will connect its {@link FlutterEngine} to itself, along with any
     * plugins that are registered with that {@link FlutterEngine}. This allows plugins to access the
     * {@code Activity}, as well as receive {@code Activity}-specific calls, e.g., {@link
     * Activity#onNewIntent(Intent)}. If {@code shouldAttachEngineToActivity} is false, then this
     * {@code XFlutterActivity} will not automatically manage the connection between its {@link
     * FlutterEngine} and itself. In this case, plugins will not be offered a reference to an {@code
     * Activity} or its OS hooks.
     *
     * <p>Returning false from this method does not preclude a {@link FlutterEngine} from being
     * attaching to a {@code XFlutterActivity} - it just prevents the attachment from happening
     * automatically. A developer can choose to subclass {@code XFlutterActivity} and then invoke
     * {@link ActivityControlSurface#attachToActivity(ExclusiveAppComponent, Lifecycle)} and {@link
     * ActivityControlSurface#detachFromActivity()} at the desired times.
     *
     * <p>One reason that a developer might choose to manually manage the relationship between the
     * {@code Activity} and {@link FlutterEngine} is if the developer wants to move the {@link
     * FlutterEngine} somewhere else. For example, a developer might want the {@link FlutterEngine} to
     * outlive this {@code XFlutterActivity} so that it can be used later in a different {@code
     * Activity}. To accomplish this, the {@link FlutterEngine} may need to be disconnected from this
     * {@code FluttterActivity} at an unusual time, preventing this {@code XFlutterActivity} from
     * correctly managing the relationship between the {@link FlutterEngine} and itself.
     */
    @Override
    public boolean shouldAttachEngineToActivity() {
        return true;
    }

    /**
     * Whether to handle the deeplinking from the {@code Intent} automatically if the {@code
     * getInitialRoute} returns null.
     *
     * <p>The default implementation looks {@code <meta-data>} called {@link
     * FlutterActivityLaunchConfigs# HANDLE_DEEPLINKING_META_DATA_KEY} within the Android manifest
     * definition for this {@code XFlutterActivity}.
     */
    @Override
    public boolean shouldHandleDeeplinking() {
//        try {
//            Bundle metaData = getMetaData();
//            boolean shouldHandleDeeplinking =
//                    metaData != null ? metaData.getBoolean(HANDLE_DEEPLINKING_META_DATA_KEY) : false;
//            return shouldHandleDeeplinking;
//        } catch (PackageManager.NameNotFoundException e) {
        return false;
//        }
    }

    @Override
    public void onFlutterSurfaceViewCreated(@NonNull FlutterSurfaceView flutterSurfaceView) {
        // Hook for subclasses.
    }

    @Override
    public void onFlutterTextureViewCreated(@NonNull FlutterTextureView flutterTextureView) {
        // Hook for subclasses.
    }

    @Override
    public void onFlutterUiDisplayed() {
        // Notifies Android that we're fully drawn so that performance metrics can be collected by
        // Flutter performance tests.
        // This was supported in KitKat (API 19), but has a bug around requiring
        // permissions. See https://github.com/flutter/flutter/issues/46172
        reportFullyDrawn();
    }

    @Override
    public void onFlutterUiNoLongerDisplayed() {
        // no-op
    }

    @Override
    public boolean shouldRestoreAndSaveState() {
        if (getIntent().hasExtra(EXTRA_ENABLE_STATE_RESTORATION)) {
            return getIntent().getBooleanExtra(EXTRA_ENABLE_STATE_RESTORATION, false);
        }
        // Prevent overwriting the existing state in a cached engine with restoration state.
        return getCachedEngineId() == null;
    }

    private boolean stillAttachedForEvent(String event) {
        if (delegate.isDetached()) {
            Log.v(TAG, "XFlutterActivity " + hashCode() + " " + event + " called after release.");
            return false;
        }
        return true;
    }
}
