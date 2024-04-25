package com.visioncameradynamsoftbarcodereader;

import android.graphics.Bitmap;
import android.os.Build;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;
import com.dynamsoft.dbr.BarcodeReader;
import com.dynamsoft.dbr.BarcodeReaderException;
import com.dynamsoft.dbr.DBRLicenseVerificationListener;
import com.dynamsoft.dbr.EnumConflictMode;
import com.dynamsoft.dbr.EnumImagePixelFormat;
import com.dynamsoft.dbr.TextResult;
import com.facebook.react.bridge.ReadableNativeMap;
import com.facebook.react.bridge.WritableNativeArray;
import com.mrousavy.camera.core.FrameInvalidError;
import com.mrousavy.camera.frameprocessors.Frame;
import com.mrousavy.camera.frameprocessors.FrameProcessorPlugin;
import com.mrousavy.camera.frameprocessors.VisionCameraProxy;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.nio.ByteBuffer;


public class VisionCameraDBRPlugin extends FrameProcessorPlugin {
    private String mTemplate = null;
    private String mLicense = null;

    private BarcodeReader dbr = VisionCameraDynamsoftBarcodeReaderModule.dbr;
    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    @Nullable
    @Override
    public Object callback(@NonNull Frame frame, @Nullable Map<String, Object> arguments) {
        List<Object> array = new ArrayList<>();
        try {
            //Log.d("DBR",frame.getImage().getWidth()+"x"+frame.getImage().getHeight());
            Boolean isFront = false;
            Boolean rotateImage = true;
            if (arguments != null ){
                //for (String key:
                //     arguments.keySet()) {
                //    Log.d("DBR",key);
                //}
                if (arguments.containsKey("isFront")){
                    isFront = (Boolean) arguments.get("isFront");
                }
                if (arguments.containsKey("rotateImage")){
                    rotateImage = (Boolean) arguments.get("rotateImage");
                    //Log.d("DBR","rot: "+rotateImage);
                }
                initLicense(arguments);
                updateRuntimeSettingsWithTemplate(arguments);
            }

            TextResult[] results = null;
            results = decode(frame, rotateImage);

            if (results != null) {
                for (int i = 0; i < results.length; i++) {
                    //Log.d("DBR",results[i].barcodeText);
                    array.add(Utils.wrapResults(results[i], frame, isFront, rotateImage));
                }
            }
        }catch(Exception | FrameInvalidError e) {
            Log.d("DBR",e.getMessage());
        }
        return array;
    }

    private TextResult[] decode(Frame image, Boolean rotateImage) throws BarcodeReaderException, FrameInvalidError {
        TextResult[] results = null;
        if (rotateImage){
            Bitmap bitmap = BitmapUtils.getBitmap(image);
            //Log.d("DBR","bitmap width: "+bitmap.getWidth());
            //Log.d("DBR","bitmap height: "+bitmap.getHeight());
            results = dbr.decodeBufferedImage(bitmap);
        }else{
            ByteBuffer buffer = image.getImage().getPlanes()[0].getBuffer();
            int nRowStride = image.getImage().getPlanes()[0].getRowStride();
            int nPixelStride = image.getImage().getPlanes()[0].getPixelStride();
            int length = buffer.remaining();
            byte[] bytes = new byte[length];
            buffer.get(bytes);
            results = dbr.decodeBuffer(bytes, image.getWidth(), image.getHeight(), nRowStride*nPixelStride, EnumImagePixelFormat.IPF_NV21);
        }
        return results;
    }

    private void initLicense(Map<String, Object> config) {
        if (config != null){
            if (config.containsKey("license")) {
                String license = (String) config.get("license");
                if (mLicense == null || mLicense.equals(license) == false) {
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

    private void updateRuntimeSettingsWithTemplate(Map<String,Object> config){
        if (config == null){
            return;
        }
        if (config.containsKey("template")) {
            String template = (String) config.get("template");
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
                    dbr.initRuntimeSettingsWithString(template,EnumConflictMode.CM_OVERWRITE);
                } catch (BarcodeReaderException e) {
                    e.printStackTrace();
                }
                mTemplate = template;
            }
        }else{
            if (mTemplate != null) {
                mTemplate = null;
                try {
                    dbr.resetRuntimeSettings();
                } catch (BarcodeReaderException e) {
                    e.printStackTrace();
                }
            }
        }
    }
    VisionCameraDBRPlugin(@NonNull VisionCameraProxy proxy, @Nullable Map<String, Object> options) {super();}

}
