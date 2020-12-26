package io.flutter.embedding.android;

import androidx.annotation.NonNull;

public interface ExclusiveAppComponent<T> {

    /**
     * Called when another App Component is about to become attached to the {@link
     * io.flutter.embedding.engine.FlutterEngine} this App Component is currently attached to.
     *
     * <p>This App Component's connections to the {@link io.flutter.embedding.engine.FlutterEngine}
     * are still valid at the moment of this call.
     */
    void detachFromFlutterEngine();

    /** Retrieve the App Component behind this exclusive App Component. */
    @NonNull
    T getAppComponent();
}
