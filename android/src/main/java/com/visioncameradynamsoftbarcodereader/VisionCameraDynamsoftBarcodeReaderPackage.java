package com.visioncameradynamsoftbarcodereader;

import androidx.annotation.NonNull;

import com.facebook.react.ReactPackage;
import com.facebook.react.bridge.NativeModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.uimanager.ViewManager;
import com.mrousavy.camera.frameprocessor.FrameProcessorPlugin;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class VisionCameraDynamsoftBarcodeReaderPackage implements ReactPackage {
    @NonNull
    @Override
    public List<NativeModule> createNativeModules(@NonNull ReactApplicationContext reactContext) {
        List<NativeModule> modules = new ArrayList<>();
        VisionCameraDynamsoftBarcodeReaderModule module = new VisionCameraDynamsoftBarcodeReaderModule(reactContext);
        modules.add(module);
        VisionCameraDBRPlugin plugin = new VisionCameraDBRPlugin(module);
        FrameProcessorPlugin.register(plugin);
        return modules;
    }

    @NonNull
    @Override
    public List<ViewManager> createViewManagers(@NonNull ReactApplicationContext reactContext) {
        return Collections.emptyList();
    }
}
