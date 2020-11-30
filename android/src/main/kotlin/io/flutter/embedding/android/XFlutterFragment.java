// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.embedding.android;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentActivity;
import androidx.lifecycle.Lifecycle;


import io.flutter.Log;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.FlutterEngineCache;
import io.flutter.embedding.engine.FlutterShellArgs;
import io.flutter.embedding.engine.loader.FlutterLoader;
import io.flutter.embedding.engine.renderer.FlutterUiDisplayListener;
import io.flutter.plugin.platform.PlatformPlugin;

/**
 * {@code Fragment} which displays a Flutter UI that takes up all available {@code Fragment} space.
 *
 * <p>Using a {@code XFlutterFragment} requires forwarding a number of calls from an {@code Activity}
 * to ensure that the internal Flutter app behaves as expected:
 *
 * <ol>
 *   <li>{@link #onPostResume()}
 *   <li>{@link #onBackPressed()}
 *   <li>{@link #onRequestPermissionsResult(int, String[], int[])} ()}
 *   <li>{@link #onNewIntent(Intent)} ()}
 *   <li>{@link #onUserLeaveHint()}
 *   <li>{@link #onTrimMemory(int)}
 * </ol>
 * <p>
 * Additionally, when starting an {@code Activity} for a result from this {@code Fragment}, be sure
 * to invoke {@link Fragment#startActivityForResult(Intent, int)} rather than {@link
 * android.app.Activity#startActivityForResult(Intent, int)}. If the {@code Activity} version of the
 * method is invoked then this {@code Fragment} will never receive its {@link
 * Fragment#onActivityResult(int, int, Intent)} callback.
 *
 * <p>If convenient, consider using a {@link FlutterActivity} instead of a {@code XFlutterFragment}
 * to avoid the work of forwarding calls.
 *
 * <p>It is generally recommended to use a cached {@link FlutterEngine} to avoid a momentary delay
 * when initializing a new {@link FlutterEngine}. The two exceptions to using a cached {@link
 * FlutterEngine} are:
 *
 * <p>
 *
 * <ul>
 *   <li>When {@code XFlutterFragment} is in the first {@code Activity} displayed by the app, because
 *       pre-warming a {@link FlutterEngine} would have no impact in this situation.
 *   <li>When you are unsure when/if you will need to display a Flutter experience.
 * </ul>
 *
 * <p>The following illustrates how to pre-warm and cache a {@link FlutterEngine}:
 *
 * <pre>{@code
 * // Create and pre-warm a FlutterEngine.
 * FlutterEngine flutterEngine = new FlutterEngine(context);
 * flutterEngine
 *   .getDartExecutor()
 *   .executeDartEntrypoint(DartEntrypoint.createDefault());
 *
 * // Cache the pre-warmed FlutterEngine in the FlutterEngineCache.
 * FlutterEngineCache.getInstance().put("my_engine", flutterEngine);
 * }</pre>
 *
 * <p>If Flutter is needed in a location that can only use a {@code View}, consider using a {@link
 * FlutterView}. Using a {@link FlutterView} requires forwarding some calls from an {@code
 * Activity}, as well as forwarding lifecycle calls from an {@code Activity} or a {@code Fragment}.
 */
public abstract class XFlutterFragment extends Fragment implements XFlutterActivityAndFragmentDelegate.Host {
    private static final String TAG = "XFlutterFragment";

    /**
     * The Dart entrypoint method name that is executed upon initialization.
     */
    protected static final String ARG_DART_ENTRYPOINT = "dart_entrypoint";
    /**
     * Initial Flutter route that is rendered in a Navigator widget.
     */
    protected static final String ARG_INITIAL_ROUTE = "initial_route";
    /**
     * Path to Flutter's Dart code.
     */
    protected static final String ARG_APP_BUNDLE_PATH = "app_bundle_path";
    /**
     * Flutter shell arguments.
     */
    protected static final String ARG_FLUTTER_INITIALIZATION_ARGS = "initialization_args";
    /**
     * {@link RenderMode} to be used for the {@link FlutterView} in this {@code XFlutterFragment}
     */
    protected static final String ARG_FLUTTERVIEW_RENDER_MODE = "flutterview_render_mode";
    /**
     * {@link TransparencyMode} to be used for the {@link FlutterView} in this {@code XFlutterFragment}
     */
    protected static final String ARG_FLUTTERVIEW_TRANSPARENCY_MODE = "flutterview_transparency_mode";
    /**
     * See {@link #shouldAttachEngineToActivity()}.
     */
    protected static final String ARG_SHOULD_ATTACH_ENGINE_TO_ACTIVITY =
            "should_attach_engine_to_activity";
    /**
     * The ID of a {@link FlutterEngine} cached in {@link FlutterEngineCache} that will be used within
     * the created {@code XFlutterFragment}.
     */
    protected static final String ARG_CACHED_ENGINE_ID = "cached_engine_id";
    /**
     * True if the {@link FlutterEngine} in the created {@code XFlutterFragment} should be destroyed
     * when the {@code XFlutterFragment} is destroyed, false if the {@link FlutterEngine} should
     * outlive the {@code XFlutterFragment}.
     */
    protected static final String ARG_DESTROY_ENGINE_WITH_FRAGMENT = "destroy_engine_with_fragment";
    /**
     * True if the framework state in the engine attached to this engine should be stored and restored
     * when this fragment is created and destroyed.
     */
    protected static final String ARG_ENABLE_STATE_RESTORATION = "enable_state_restoration";

    XFlutterActivityAndFragmentDelegate delegate;

    @Override
    public void onAttach(@NonNull Context context) {
        super.onAttach(context);
        delegate = new XFlutterActivityAndFragmentDelegate(this);
        delegate.onAttach(context);
    }

    @Nullable
    @Override
    public View onCreateView(
            LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {

//        FrameLayout parentLayout = new FrameLayout(getContext());
//        parentLayout.setLayoutParams(new ViewGroup.LayoutParams(-1, -1));
//        parentLayout.setBackgroundColor(Color.YELLOW);
//
//        FrameLayout layout = (FrameLayout) delegate.onCreateView(inflater, container, savedInstanceState);
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
//        return parentLayout;

        return delegate.onCreateView(inflater, container, savedInstanceState);
    }

    @Override
    public void onActivityCreated(@Nullable Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
//        delegate.onActivityCreated(savedInstanceState);
    }

    @Override
    public void onStart() {
        super.onStart();
        if (!isHidden()) {
            delegate.onStart();
        }
    }

    private void reattachIfNeeded() {
        if (!isHidden()) {
            if (delegate.isDetached()) {
                delegate.reattach();
            } else {
                delegate.onResume();
            }
        }
    }

    @Override
    public void onResume() {
        super.onResume();
        reattachIfNeeded();
    }

    @Override
    public void onHiddenChanged(boolean hidden) {
        super.onHiddenChanged(hidden);
        reattachIfNeeded();
    }

    // TODO(mattcarroll): determine why this can't be in onResume(). Comment reason, or move if
    // possible.
    @ActivityCallThrough
    public void onPostResume() {
        if (!isHidden()) {
            delegate.onPostResume();
        }
    }

    @Override
    public void onPause() {
        super.onPause();
        if (!isHidden()) {
            delegate.onPause();
        }
    }

    @Override
    public void onStop() {
        super.onStop();
        if (!isHidden() && stillAttachedForEvent("onStop")) {
            delegate.onStop();
        }
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        if (stillAttachedForEvent("onDestroyView")) {
            delegate.onDestroyView();
        }
    }

    @Override
    public void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);
        if (!isHidden() && stillAttachedForEvent("onSaveInstanceState")) {
            delegate.onSaveInstanceState(outState);
        }
    }

    @Override
    public void detachFromFlutterEngine() {
        Log.v(
                TAG,
                "XFlutterFragment "
                        + this
                        + " connection to the engine "
                        + getFlutterEngine()
                        + " evicted by another attaching activity");
        // Redundant calls are ok.
        delegate.detach();
    }

    private void release() {
        delegate.onDestroyView();
        delegate.onDetach();
        delegate.release();
        delegate = null;
    }

    @Override
    public void onDetach() {
        super.onDetach();
        if (delegate != null) {
            release();
        } else {
            Log.v(TAG, "XFlutterFragment " + this + " onDetach called after release.");
        }
    }

    /**
     * The result of a permission request has been received.
     *
     * <p>See {@link android.app.Activity#onRequestPermissionsResult(int, String[], int[])}
     *
     * <p>
     *
     * @param requestCode  identifier passed with the initial permission request
     * @param permissions  permissions that were requested
     * @param grantResults permission grants or denials
     */
    @ActivityCallThrough
    public void onRequestPermissionsResult(
            int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        if (stillAttachedForEvent("onRequestPermissionsResult")) {
            delegate.onRequestPermissionsResult(requestCode, permissions, grantResults);
        }
    }

    /**
     * A new Intent was received by the {@link android.app.Activity} that currently owns this {@link
     * Fragment}.
     *
     * <p>
     *
     * @param intent new Intent
     */
    @ActivityCallThrough
    public void onNewIntent(@NonNull Intent intent) {
        if (stillAttachedForEvent("onNewIntent")) {
            delegate.onNewIntent(intent);
        }
    }

    /**
     * The hardware back button was pressed.
     *
     * <p>See {@link android.app.Activity#onBackPressed()}
     */
    @ActivityCallThrough
    public void onBackPressed() {
        if (!isHidden() && stillAttachedForEvent("onBackPressed")) {
            delegate.onBackPressed();
        }
    }

    /**
     * A result has been returned after an invocation of {@link
     * Fragment#startActivityForResult(Intent, int)}.
     *
     * <p>
     *
     * @param requestCode request code sent with {@link Fragment#startActivityForResult(Intent, int)}
     * @param resultCode  code representing the result of the {@code Activity} that was launched
     * @param data        any corresponding return data, held within an {@code Intent}
     */
    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (stillAttachedForEvent("onActivityResult")) {
            delegate.onActivityResult(requestCode, resultCode, data);
        }
    }

    /**
     * The {@link android.app.Activity} that owns this {@link Fragment} is about to go to the
     * background as the result of a user's choice/action, i.e., not as the result of an OS decision.
     */
    @ActivityCallThrough
    public void onUserLeaveHint() {
        if (stillAttachedForEvent("onUserLeaveHint")) {
            delegate.onUserLeaveHint();
        }
    }

    /**
     * Callback invoked when memory is low.
     *
     * <p>This implementation forwards a memory pressure warning to the running Flutter app.
     *
     * <p>
     *
     * @param level level
     */
    @ActivityCallThrough
    public void onTrimMemory(int level) {
        if (stillAttachedForEvent("onTrimMemory")) {
            delegate.onTrimMemory(level);
        }
    }

    /**
     * Callback invoked when memory is low.
     *
     * <p>This implementation forwards a memory pressure warning to the running Flutter app.
     */
    @Override
    public void onLowMemory() {
        super.onLowMemory();
        if (stillAttachedForEvent("onLowMemory")) {
            delegate.onLowMemory();
        }
    }

    @Override
    public boolean shouldHandleDeeplinking() {
        return false;
    }

    /**
     * {@link FlutterActivityAndFragmentDelegate.Host} method that is used by {@link
     * FlutterActivityAndFragmentDelegate} to obtain Flutter shell arguments when initializing
     * Flutter.
     */
    @Override
    @NonNull
    public FlutterShellArgs getFlutterShellArgs() {
        String[] flutterShellArgsArray = getArguments().getStringArray(ARG_FLUTTER_INITIALIZATION_ARGS);
        return new FlutterShellArgs(
                flutterShellArgsArray != null ? flutterShellArgsArray : new String[]{});
    }

    /**
     * Returns the ID of a statically cached {@link FlutterEngine} to use within this {@code
     * XFlutterFragment}, or {@code null} if this {@code XFlutterFragment} does not want to use a cached
     * {@link FlutterEngine}.
     */
    @Nullable
    @Override
    public String getCachedEngineId() {
        return getArguments().getString(ARG_CACHED_ENGINE_ID, null);
    }

    /**
     * Returns false if the {@link FlutterEngine} within this {@code XFlutterFragment} should outlive
     * the {@code XFlutterFragment}, itself.
     *
     * <p>Defaults to true if no custom {@link FlutterEngine is provided}, false if a custom {@link
     * FlutterEngine} is provided.
     */
    @Override
    public boolean shouldDestroyEngineWithHost() {
        boolean explicitDestructionRequested =
                getArguments().getBoolean(ARG_DESTROY_ENGINE_WITH_FRAGMENT, false);
        if (getCachedEngineId() != null || delegate.isFlutterEngineFromHost()) {
            // Only destroy a cached engine if explicitly requested by app developer.
            return explicitDestructionRequested;
        } else {
            // If this Fragment created the FlutterEngine, destroy it by default unless
            // explicitly requested not to.
            return getArguments().getBoolean(ARG_DESTROY_ENGINE_WITH_FRAGMENT, true);
        }
    }

    /**
     * Returns the name of the Dart method that this {@code XFlutterFragment} should execute to start a
     * Flutter app.
     *
     * <p>Defaults to "main".
     *
     * <p>Used by this {@code XFlutterFragment}'s {@link FlutterActivityAndFragmentDelegate.Host}
     */
    @Override
    @NonNull
    public String getDartEntrypointFunctionName() {
        return getArguments().getString(ARG_DART_ENTRYPOINT, "main");
    }

    /**
     * A custom path to the bundle that contains this Flutter app's resources, e.g., Dart code
     * snapshots.
     *
     * <p>When unspecified, the value is null, which defaults to the app bundle path defined in {@link
     * FlutterLoader#findAppBundlePath()}.
     *
     * <p>Used by this {@code XFlutterFragment}'s {@link FlutterActivityAndFragmentDelegate.Host}
     */
    @Override
    @NonNull
    public String getAppBundlePath() {
        return getArguments().getString(ARG_APP_BUNDLE_PATH);
    }

    /**
     * Returns the initial route that should be rendered within Flutter, once the Flutter app starts.
     *
     * <p>Defaults to {@code null}, which signifies a route of "/" in Flutter.
     *
     * <p>Used by this {@code XFlutterFragment}'s {@link FlutterActivityAndFragmentDelegate.Host}
     */
    @Override
    @Nullable
    public String getInitialRoute() {
        return getArguments().getString(ARG_INITIAL_ROUTE);
    }

    /**
     * Returns the desired {@link RenderMode} for the {@link FlutterView} displayed in this {@code
     * XFlutterFragment}.
     *
     * <p>Defaults to {@link RenderMode#surface}.
     *
     * <p>Used by this {@code XFlutterFragment}'s {@link FlutterActivityAndFragmentDelegate.Host}
     */
    @Override
    @NonNull
    public RenderMode getRenderMode() {
        String renderModeName =
                getArguments().getString(ARG_FLUTTERVIEW_RENDER_MODE, RenderMode.surface.name());
        return RenderMode.valueOf(renderModeName);
    }

    /**
     * Returns the desired {@link TransparencyMode} for the {@link FlutterView} displayed in this
     * {@code XFlutterFragment}.
     *
     * <p>Defaults to {@link TransparencyMode#transparent}.
     *
     * <p>Used by this {@code XFlutterFragment}'s {@link FlutterActivityAndFragmentDelegate.Host}
     */
    @Override
    @NonNull
    public TransparencyMode getTransparencyMode() {
        String transparencyModeName =
                getArguments()
                        .getString(ARG_FLUTTERVIEW_TRANSPARENCY_MODE, TransparencyMode.transparent.name());
        return TransparencyMode.valueOf(transparencyModeName);
    }

    @Override
    @Nullable
    public SplashScreen provideSplashScreen() {
        FragmentActivity parentActivity = getActivity();
        if (parentActivity instanceof SplashScreenProvider) {
            SplashScreenProvider splashScreenProvider = (SplashScreenProvider) parentActivity;
            return splashScreenProvider.provideSplashScreen();
        }

        return null;
    }

    /**
     * Hook for subclasses to return a {@link FlutterEngine} with whatever configuration is desired.
     *
     * <p>By default this method defers to this {@code XFlutterFragment}'s surrounding {@code
     * Activity}, if that {@code Activity} implements {@link FlutterEngineProvider}. If this method is
     * overridden, the surrounding {@code Activity} will no longer be given an opportunity to provide
     * a {@link FlutterEngine}, unless the subclass explicitly implements that behavior.
     *
     * <p>Consider returning a cached {@link FlutterEngine} instance from this method to avoid the
     * typical warm-up time that a new {@link FlutterEngine} instance requires.
     *
     * <p>If null is returned then a new default {@link FlutterEngine} will be created to back this
     * {@code XFlutterFragment}.
     *
     * <p>Used by this {@code XFlutterFragment}'s {@link FlutterActivityAndFragmentDelegate.Host}
     */
    @Override
    @Nullable
    public FlutterEngine provideFlutterEngine(@NonNull Context context) {
        // Defer to the FragmentActivity that owns us to see if it wants to provide a
        // FlutterEngine.
        FlutterEngine flutterEngine = null;
        FragmentActivity attachedActivity = getActivity();
        if (attachedActivity instanceof FlutterEngineProvider) {
            // Defer to the Activity that owns us to provide a FlutterEngine.
            Log.v(TAG, "Deferring to attached Activity to provide a FlutterEngine.");
            FlutterEngineProvider flutterEngineProvider = (FlutterEngineProvider) attachedActivity;
            flutterEngine = flutterEngineProvider.provideFlutterEngine(getContext());
        }

        return flutterEngine;
    }

    /**
     * Hook for subclasses to obtain a reference to the {@link FlutterEngine} that is owned by this
     * {@code FlutterActivity}.
     */
    @Nullable
    public FlutterEngine getFlutterEngine() {
        return delegate.getFlutterEngine();
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
     * Configures a {@link FlutterEngine} after its creation.
     *
     * <p>This method is called after {@link #provideFlutterEngine(Context)}, and after the given
     * {@link FlutterEngine} has been attached to the owning {@code FragmentActivity}. See {@link
     * io.flutter.embedding.engine.plugins.activity.ActivityControlSurface#attachToActivity(
     *ExclusiveAppComponent, Lifecycle)}.
     *
     * <p>It is possible that the owning {@code FragmentActivity} opted not to connect itself as an
     * {@link io.flutter.embedding.engine.plugins.activity.ActivityControlSurface}. In that case, any
     * configuration, e.g., plugins, must not expect or depend upon an available {@code Activity} at
     * the time that this method is invoked.
     *
     * <p>The default behavior of this method is to defer to the owning {@code FragmentActivity} as a
     * {@link FlutterEngineConfigurator}. Subclasses can override this method if the subclass needs to
     * override the {@code FragmentActivity}'s behavior, or add to it.
     *
     * <p>Used by this {@code XFlutterFragment}'s {@link FlutterActivityAndFragmentDelegate.Host}
     */
    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        FragmentActivity attachedActivity = getActivity();
        if (attachedActivity instanceof FlutterEngineConfigurator) {
            ((FlutterEngineConfigurator) attachedActivity).configureFlutterEngine(flutterEngine);
        }
    }

    /**
     * Hook for the host to cleanup references that were established in {@link
     * #configureFlutterEngine(FlutterEngine)} before the host is destroyed or detached.
     *
     * <p>This method is called in {@link #onDetach()}.
     */
    @Override
    public void cleanUpFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        FragmentActivity attachedActivity = getActivity();
        if (attachedActivity instanceof FlutterEngineConfigurator) {
            ((FlutterEngineConfigurator) attachedActivity).cleanUpFlutterEngine(flutterEngine);
        }
    }

    /**
     * <p>Used by this {@code XFlutterFragment}'s {@link FlutterActivityAndFragmentDelegate}
     */
    @Override
    public boolean shouldAttachEngineToActivity() {
        return getArguments().getBoolean(ARG_SHOULD_ATTACH_ENGINE_TO_ACTIVITY);
    }

    @Override
    public void onFlutterSurfaceViewCreated(@NonNull FlutterSurfaceView flutterSurfaceView) {
        // Hook for subclasses.
    }

    @Override
    public void onFlutterTextureViewCreated(@NonNull FlutterTextureView flutterTextureView) {
        // Hook for subclasses.
    }

    /**
     * Invoked after the {@link FlutterView} within this {@code XFlutterFragment} starts rendering
     * pixels to the screen.
     *
     * <p>This method forwards {@code onFlutterUiDisplayed()} to its attached {@code Activity}, if the
     * attached {@code Activity} implements {@link FlutterUiDisplayListener}.
     *
     * <p>Subclasses that override this method must call through to the {@code super} method.
     *
     * <p>Used by this {@code XFlutterFragment}'s {@link FlutterActivityAndFragmentDelegate.Host}
     */
    @Override
    public void onFlutterUiDisplayed() {
        FragmentActivity attachedActivity = getActivity();
        if (attachedActivity instanceof FlutterUiDisplayListener) {
            ((FlutterUiDisplayListener) attachedActivity).onFlutterUiDisplayed();
        }
    }

    /**
     * Invoked after the {@link FlutterView} within this {@code XFlutterFragment} stops rendering
     * pixels to the screen.
     *
     * <p>This method forwards {@code onFlutterUiNoLongerDisplayed()} to its attached {@code
     * Activity}, if the attached {@code Activity} implements {@link FlutterUiDisplayListener}.
     *
     * <p>Subclasses that override this method must call through to the {@code super} method.
     *
     * <p>Used by this {@code XFlutterFragment}'s {@link FlutterActivityAndFragmentDelegate.Host}
     */
    @Override
    public void onFlutterUiNoLongerDisplayed() {
        FragmentActivity attachedActivity = getActivity();
        if (attachedActivity instanceof FlutterUiDisplayListener) {
            ((FlutterUiDisplayListener) attachedActivity).onFlutterUiNoLongerDisplayed();
        }
    }

    @Override
    public boolean shouldRestoreAndSaveState() {
        if (getArguments().containsKey(ARG_ENABLE_STATE_RESTORATION)) {
            return getArguments().getBoolean(ARG_ENABLE_STATE_RESTORATION);
        }
        return getCachedEngineId() == null;
    }

    private boolean stillAttachedForEvent(String event) {
        if (delegate.isDetached()) {
            Log.v(TAG, "XFlutterFragment " + hashCode() + " " + event + " called after release.");
            return false;
        }
        return true;
    }

    /**
     * Annotates methods in {@code XFlutterFragment} that must be called by the containing {@code
     * Activity}.
     */
    @interface ActivityCallThrough {
    }
}
