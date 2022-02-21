package com.visioncameradynamsoftbarcodereader;

import android.annotation.SuppressLint;
import android.graphics.Bitmap;
import android.os.Build;
import android.util.Log;

import androidx.annotation.RequiresApi;
import androidx.camera.core.ImageProxy;

import com.dynamsoft.dbr.BarcodeReader;
import com.dynamsoft.dbr.BarcodeReaderException;
import com.dynamsoft.dbr.DBRDLSLicenseVerificationListener;
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
    private BarcodeReader reader = null;
    private String mTemplate = null;
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

        if (reader==null){
            createDBRInstance(config);
        }

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
                array.pushMap(wrapResults(results[i], image, isFront, rotateImage));
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
            results = reader.decodeBufferedImage(bitmap, "");
        }else{
            ByteBuffer buffer = image.getPlanes()[0].getBuffer();
            int nRowStride = image.getPlanes()[0].getRowStride();
            int nPixelStride = image.getPlanes()[0].getPixelStride();
            int length = buffer.remaining();
            byte[] bytes = new byte[length];
            buffer.get(bytes);
            results = reader.decodeBuffer(bytes, image.getWidth(), image.getHeight(), nRowStride*nPixelStride, EnumImagePixelFormat.IPF_NV21, "");
        }
        return results;
    }

    private void createDBRInstance(ReadableNativeMap config) {
        String license = null;
        String organizationID = "200001";
        if (config != null){
            if (config.hasKey("license")) {
                license = config.getString("license");
            }
            if (config.hasKey("organizationID")) {
                organizationID = config.getString("organizationID");
            }
        }

        try {
            // Create an instance of Dynamsoft Barcode Reader.
            reader = new BarcodeReader();
            if (license != null){
                reader.initLicense(license);
            }else{
                // Initialize license for Dynamsoft Barcode Reader.
                // The organization id 200001 here will grant you a public trial license good for 7 days. Note that network connection is required for this license to work.
                // If you want to use an offline license, please contact Dynamsoft Support: https://www.dynamsoft.com/company/contact/
                // You can also request a 30-day trial license in the customer portal: https://www.dynamsoft.com/customer/license/trialLicense?product=dbr&utm_source=installer&package=android
                DMDLSConnectionParameters dbrParameters = new DMDLSConnectionParameters();
                dbrParameters.organizationID = organizationID;
                reader.initLicenseFromDLS(dbrParameters, new DBRDLSLicenseVerificationListener() {
                    @Override
                    public void DLSLicenseVerificationCallback(boolean isSuccessful, Exception e) {

                    }
                });
            }
        } catch (BarcodeReaderException e) {
            e.printStackTrace();
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
                    reader.initRuntimeSettingsWithString(template,EnumConflictMode.CM_OVERWRITE);
                } catch (BarcodeReaderException e) {
                    e.printStackTrace();
                }
                mTemplate = template;
            }
        }else{
            if (mTemplate != null) {
                mTemplate = null;
                try {
                    reader.resetRuntimeSettings();
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

    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    private WritableNativeMap wrapResults(TextResult result, ImageProxy image, Boolean isFront, Boolean rotateImage) {
        WritableNativeMap map = new WritableNativeMap();
        map.putString("barcodeText",result.barcodeText);
        map.putString("barcodeFormat",result.barcodeFormatString);
        Point[] points = result.localizationResult.resultPoints;
        for (int i = 0; i <4 ; i++) {
            Point point = points[i];
            if (!rotateImage){
                point = rotatedPoint(point, image, isFront);
            }
            map.putInt("x"+(i+1), point.x);
            map.putInt("y"+(i+1), point.y);
        }
        return map;
    }

    //rotate point to match camera preview
    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    private Point rotatedPoint(Point point, ImageProxy image, Boolean isFront){
        Point rotatedPoint = new Point();
        switch (image.getImageInfo().getRotationDegrees()){
            case 90:
                rotatedPoint.x = image.getHeight() - point.y;
                rotatedPoint.y = point.x;
                break;
            case 180:
                rotatedPoint.x = image.getWidth() - point.x;
                rotatedPoint.y = image.getHeight() - point.y;
                if (isFront){ //front cam landscape
                    rotatedPoint.x = image.getWidth() - rotatedPoint.x;
                }
                break;
            case 270:
                rotatedPoint.x = image.getHeight() - point.y;
                rotatedPoint.y = image.getWidth() - point.x;
                break;
            default:
                rotatedPoint.x = point.x;
                rotatedPoint.y = point.y;
                if (isFront){ //front cam landscape
                    rotatedPoint.x = image.getWidth() - rotatedPoint.x;
                }
        }

        return rotatedPoint;
    }

    VisionCameraDBRPlugin() {
        super("decode");
    }
}