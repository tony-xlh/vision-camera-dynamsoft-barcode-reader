package com.visioncameradynamsoftbarcodereader;


import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.ImageFormat;
import android.graphics.Matrix;
import android.graphics.Rect;
import android.graphics.YuvImage;
import android.media.Image;
import android.os.Build;
import android.util.Log;
import android.view.Display;

import androidx.annotation.RequiresApi;
import androidx.camera.core.ImageProxy;

import com.dynamsoft.dbr.BarcodeReader;
import com.dynamsoft.dbr.BarcodeReaderException;
import com.dynamsoft.dbr.DBRDLSLicenseVerificationListener;
import com.dynamsoft.dbr.DMDLSConnectionParameters;
import com.dynamsoft.dbr.EnumConflictMode;
import com.dynamsoft.dbr.EnumImagePixelFormat;
import com.dynamsoft.dbr.TextResult;
import com.facebook.react.bridge.ReadableNativeMap;
import com.facebook.react.bridge.WritableNativeArray;
import com.facebook.react.bridge.WritableNativeMap;
import com.mrousavy.camera.frameprocessor.FrameProcessorPlugin;

import java.io.ByteArrayOutputStream;
import java.nio.ByteBuffer;

public class VisionCameraDBRPlugin extends FrameProcessorPlugin {
    private BarcodeReader reader = null;
    private String mTemplate = null;
    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    @Override
    public Object callback(ImageProxy image, Object[] params) {
        ReadableNativeMap config = getConfig(params);
        if (reader==null){
            createDBRInstance(config);
        }

        updateRuntimeSettingsWithTemplate(config);

        Bitmap bitmap = toJpegImage(image.getImage(),100);
        //Log.d("DBR","rotation degree: "+ image.getImageInfo().getRotationDegrees());
        if (image.getImageInfo().getRotationDegrees()!=0){
            bitmap = rotatedBitmap(bitmap, image.getImageInfo().getRotationDegrees());
        }

        TextResult[] results = null;

        try {
            results = reader.decodeBufferedImage(bitmap,"");
        } catch (BarcodeReaderException e) {
            e.printStackTrace();
        }
        WritableNativeArray array = new WritableNativeArray();
        if (results != null) {
            for (int i = 0; i < results.length; i++) {
                Log.d("DBR",results[i].barcodeText);
                array.pushMap(wrapResults(results[i]));
            }
        }

        return array;
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

    private WritableNativeMap wrapResults(TextResult result) {
        WritableNativeMap map = new WritableNativeMap();
        map.putString("barcodeText",result.barcodeText);
        map.putString("barcodeFormat",result.barcodeFormatString);
        map.putInt("x1",result.localizationResult.resultPoints[0].x);
        map.putInt("x2",result.localizationResult.resultPoints[1].x);
        map.putInt("x3",result.localizationResult.resultPoints[2].x);
        map.putInt("x4",result.localizationResult.resultPoints[3].x);
        map.putInt("y1",result.localizationResult.resultPoints[0].y);
        map.putInt("y2",result.localizationResult.resultPoints[1].y);
        map.putInt("y3",result.localizationResult.resultPoints[2].y);
        map.putInt("y4",result.localizationResult.resultPoints[3].y);
        return map;
    }

    private Bitmap rotatedBitmap(Bitmap bitmap,int rotationDegrees){
        Matrix m = new Matrix();
        m.postRotate(rotationDegrees);
        Bitmap bitmapRotated = Bitmap.createBitmap(bitmap,0,0,bitmap.getWidth(),bitmap.getHeight(),m,false);
        return bitmapRotated;
    }

    private Bitmap toJpegImage(android.media.Image image, int imageQuality) {

        if (image.getFormat() != ImageFormat.YUV_420_888) {
            throw new IllegalArgumentException("Invalid image format");
        }

        YuvImage yuvImage = toYuvImage(image);
        int width = image.getWidth();
        int height = image.getHeight();

        // Convert to jpeg
        byte[] jpegImage = null;
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        yuvImage.compressToJpeg(new Rect(0, 0, width, height), imageQuality, out);
        jpegImage = out.toByteArray();
        Bitmap bitmap = BitmapFactory.decodeByteArray(jpegImage, 0, jpegImage.length);
        return bitmap;
    }

    private YuvImage toYuvImage(Image image) {
        if (image.getFormat() != ImageFormat.YUV_420_888) {
            throw new IllegalArgumentException("Invalid image format");
        }

        int width = image.getWidth();
        int height = image.getHeight();

        // Order of U/V channel guaranteed, read more:
        // https://developer.android.com/reference/android/graphics/ImageFormat#YUV_420_888
        Image.Plane yPlane = image.getPlanes()[0];
        Image.Plane uPlane = image.getPlanes()[1];
        Image.Plane vPlane = image.getPlanes()[2];

        ByteBuffer yBuffer = yPlane.getBuffer();
        ByteBuffer uBuffer = uPlane.getBuffer();
        ByteBuffer vBuffer = vPlane.getBuffer();

        // Full size Y channel and quarter size U+V channels.
        int numPixels = (int) (width * height * 1.5f);
        byte[] nv21 = new byte[numPixels];
        int index = 0;

        // Copy Y channel.
        int yRowStride = yPlane.getRowStride();
        int yPixelStride = yPlane.getPixelStride();
        for(int y = 0; y < height; ++y) {
            for (int x = 0; x < width; ++x) {
                nv21[index++] = yBuffer.get(y * yRowStride + x * yPixelStride);
            }
        }

        // Copy VU data; NV21 format is expected to have YYYYVU packaging.
        // The U/V planes are guaranteed to have the same row stride and pixel stride.
        int uvRowStride = uPlane.getRowStride();
        int uvPixelStride = uPlane.getPixelStride();
        int uvWidth = width / 2;
        int uvHeight = height / 2;

        for(int y = 0; y < uvHeight; ++y) {
            for (int x = 0; x < uvWidth; ++x) {
                int bufferIndex = (y * uvRowStride) + (x * uvPixelStride);
                // V channel.
                nv21[index++] = vBuffer.get(bufferIndex);
                // U channel.
                nv21[index++] = uBuffer.get(bufferIndex);
            }
        }

        return new YuvImage(
                nv21, ImageFormat.NV21, width, height, /* strides= */ null);
    }

    VisionCameraDBRPlugin() {
        super("decode");
    }
}