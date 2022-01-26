package com.visioncameradynamsoftbarcodereader;

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
import com.dynamsoft.dbr.TextResult;
import com.facebook.react.bridge.ReadableNativeMap;
import com.facebook.react.bridge.WritableNativeArray;
import com.facebook.react.bridge.WritableNativeMap;
import com.mrousavy.camera.frameprocessor.FrameProcessorPlugin;

import java.nio.ByteBuffer;

public class VisionCameraDBRPlugin extends FrameProcessorPlugin {
    private BarcodeReader reader = null;
    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    @Override
    public Object callback(ImageProxy image, Object[] params) {
        if (reader==null){
            createDBRInstance(params);
        }
        TextResult[] results = null;
        ByteBuffer buffer = image.getPlanes()[0].getBuffer();
        int nRowStride = image.getPlanes()[0].getRowStride();
        int nPixelStride = image.getPlanes()[0].getPixelStride();
        int length = buffer.remaining();
        byte[] bytes = new byte[length];
        buffer.get(bytes);

        try {
            results = reader.decodeBuffer(bytes, image.getWidth(), image.getHeight(), nRowStride*nPixelStride, EnumImagePixelFormat.IPF_NV21, "");
        } catch (BarcodeReaderException e) {
            e.printStackTrace();
        }
        WritableNativeArray array = new WritableNativeArray();
        if (results!=null) {
            for (int i = 0; i < results.length; i++) {
                Log.d("DBR",results[i].barcodeText);
                array.pushMap(wrapResults(results[i]));
                //array.pushString(results[i].barcodeText);
            }
        }

        return array;
    }

    private void createDBRInstance(Object[] params) {
        String template = null;
        String license = null;
        String organizationID = "200001";

        if (params.length>0){
            if (params[0] instanceof ReadableNativeMap) {
                ReadableNativeMap config = (ReadableNativeMap) params[0];
                if (config.hasKey("template")) {
                    template = config.getString("template");
                }
                if (config.hasKey("license")) {
                    license = config.getString("license");
                }
                if (config.hasKey("organizationID")) {
                    organizationID = config.getString("organizationID");
                }
            }
        }

        try {
            // Create an instance of Dynamsoft Barcode Reader.
            reader = new BarcodeReader();
            if (license!=null){
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
            if (template!=null){
                reader.initRuntimeSettingsWithString(template, EnumConflictMode.CM_OVERWRITE);
            }
        } catch (BarcodeReaderException e) {
            e.printStackTrace();
        }
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


    VisionCameraDBRPlugin() {
        super("decode");
    }
}