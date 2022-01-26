package com.visioncameradynamsoftbarcodereader;

import androidx.annotation.NonNull;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.module.annotations.ReactModule;

@ReactModule(name = VisionCameraDynamsoftBarcodeReaderModule.NAME)
public class VisionCameraDynamsoftBarcodeReaderModule extends ReactContextBaseJavaModule {
    public static final String NAME = "VisionCameraDynamsoftBarcodeReader";

    public VisionCameraDynamsoftBarcodeReaderModule(ReactApplicationContext reactContext) {
        super(reactContext);
    }

    @Override
    @NonNull
    public String getName() {
        return NAME;
    }

}
