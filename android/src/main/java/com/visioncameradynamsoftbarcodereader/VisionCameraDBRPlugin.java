package com.visioncameradynamsoftbarcodereader;

import android.annotation.SuppressLint;
import android.graphics.Bitmap;
import android.os.Build;
import android.util.Base64;
import android.util.Log;

import androidx.annotation.RequiresApi;
import androidx.camera.core.ImageProxy;

import com.dynamsoft.dbr.BarcodeReader;
import com.dynamsoft.dbr.BarcodeReaderException;
import com.dynamsoft.dbr.DBRDLSLicenseVerificationListener;
import com.dynamsoft.dbr.DBRLicenseVerificationListener;
import com.dynamsoft.dbr.DMDLSConnectionParameters;
import com.dynamsoft.dbr.EnumConflictMode;
import com.dynamsoft.dbr.EnumImagePixelFormat;
import com.dynamsoft.dbr.Point;
import com.dynamsoft.dbr.TextResult;
import com.facebook.react.bridge.ReadableNativeMap;
import com.facebook.react.bridge.WritableNativeArray;
import com.facebook.react.bridge.WritableNativeMap;
import com.mrousavy.camera.frameprocessor.FrameProcessorPlugin;

import java.nio.ByteBuffer;

public class VisionCameraDBRPlugin extends FrameProcessorPlugin {
    private VisionCameraDynamsoftBarcodeReaderModule mModule;
    private String mTemplate = null;
    private String mLicense = null;
    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    @Override
    public Object callback(ImageProxy image, Object[] params) {
        ReadableNativeMap config = getConfig(params);
        Boolean isFront;
        Boolean rotateImage;
        if (config.hasKey("isFront")){
            isFront = config.getBoolean("isFront");
        }else{
            isFront = false;
        }

        if (config.hasKey("rotateImage")){
            rotateImage = config.getBoolean("rotateImage");
        }else{
            rotateImage = true;
        }

        initLicense(config);
        updateRuntimeSettingsWithTemplate(config);

        TextResult[] results = null;
        try {
            results = decode(image, rotateImage);
        } catch (BarcodeReaderException e) {
            e.printStackTrace();
        }

        Log.d("DBR","rotation degrees:"+image.getImageInfo().getRotationDegrees());

        WritableNativeArray array = new WritableNativeArray();
        if (results != null) {
            for (int i = 0; i < results.length; i++) {
                Log.d("DBR",results[i].barcodeText);
                array.pushMap(Utils.wrapResults(results[i], image, isFront, rotateImage));
            }
        }

        return array;
    }

    @SuppressLint("UnsafeOptInUsageError")
    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    private TextResult[] decode(ImageProxy image, Boolean rotateImage) throws BarcodeReaderException {
        TextResult[] results = null;
        if (rotateImage){
            Bitmap bitmap = BitmapUtils.getBitmap(image);
            Log.d("DBR","bitmap width: "+bitmap.getWidth());
            Log.d("DBR","bitmap height: "+bitmap.getHeight());
            results = mModule.getDBR().decodeBufferedImage(bitmap);
        }else{
            ByteBuffer buffer = image.getPlanes()[0].getBuffer();
            int nRowStride = image.getPlanes()[0].getRowStride();
            int nPixelStride = image.getPlanes()[0].getPixelStride();
            int length = buffer.remaining();
            byte[] bytes = new byte[length];
            buffer.get(bytes);
            results = mModule.getDBR().decodeBuffer(bytes, image.getWidth(), image.getHeight(), nRowStride*nPixelStride, EnumImagePixelFormat.IPF_NV21);
        }
        return results;
    }

    private void initLicense(ReadableNativeMap config) {
        if (config != null){
            if (config.hasKey("license")) {
                String license = config.getString("license");
                if (license != mLicense) {
                    mLicense = license;
                    BarcodeReader.initLicense(license, new DBRLicenseVerificationListener() {
                        @Override
                        public void DBRLicenseVerificationCallback(boolean isSuccessful, Exception e) {
                            if (!isSuccessful) {
                                e.printStackTrace();
                            }
                        }
                    });
                }
            }
        }
    }

    private void updateRuntimeSettingsWithTemplate(ReadableNativeMap config){
        if (config == null){
            return;
        }
        if (config.hasKey("template")) {
            String template = config.getString("template");
            Boolean shouldUpdate = false;
            if (mTemplate == null){
                shouldUpdate = true;
            }else{
                if (!mTemplate.equals(template)) {
                    shouldUpdate = true;
                }
            }
            if (shouldUpdate){
                try {
                    mModule.getDBR().initRuntimeSettingsWithString(template,EnumConflictMode.CM_OVERWRITE);
                } catch (BarcodeReaderException e) {
                    e.printStackTrace();
                }
                mTemplate = template;
            }
        }else{
            if (mTemplate != null) {
                mTemplate = null;
                try {
                    mModule.getDBR().resetRuntimeSettings();
                } catch (BarcodeReaderException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    private ReadableNativeMap getConfig(Object[] params){
        if (params.length>0) {
            if (params[0] instanceof ReadableNativeMap) {
                ReadableNativeMap config = (ReadableNativeMap) params[0];
                return config;
            }
        }
        return null;
    }

    VisionCameraDBRPlugin(VisionCameraDynamsoftBarcodeReaderModule module)
    {
        super("decode");
        mModule = module;
    }
}