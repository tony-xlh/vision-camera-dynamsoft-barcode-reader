package com.visioncameradynamsoftbarcodereader;

import android.content.Context;
import android.graphics.Bitmap;
import android.os.Build;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;

import com.dynamsoft.dbr.BarcodeReader;
import com.dynamsoft.dbr.BarcodeReaderException;
import com.dynamsoft.dbr.DBRLicenseVerificationListener;
import com.dynamsoft.dbr.EnumConflictMode;
import com.dynamsoft.dbr.TextResult;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.WritableNativeArray;
import com.facebook.react.module.annotations.ReactModule;

@ReactModule(name = VisionCameraDynamsoftBarcodeReaderModule.NAME)
public class VisionCameraDynamsoftBarcodeReaderModule extends ReactContextBaseJavaModule {
  public static final String NAME = "VisionCameraDynamsoftBarcodeReader";
  private Context mContext;
  private BarcodeReader dbr;
  public VisionCameraDynamsoftBarcodeReaderModule(ReactApplicationContext reactContext) {
    super(reactContext);
    mContext = reactContext;
    initDBR();
  }
  private void initDBR(){
    try {
      dbr = new BarcodeReader();
    } catch (Exception e) {
      e.printStackTrace();
    }
  }

  public Context getContext(){
    return mContext;
  }
  public BarcodeReader getDBR(){
    return dbr;
  }

  @Override
  @NonNull
  public String getName() {
    return NAME;
  }
  @ReactMethod
  public void initLicense(String license, Promise promise) {
    BarcodeReader.initLicense(license, new DBRLicenseVerificationListener() {
      @Override
      public void DBRLicenseVerificationCallback(boolean isSuccessful, Exception e) {
        if (!isSuccessful) {
          e.printStackTrace();
          promise.reject("DBR",e.getMessage());
        }else {
          promise.resolve(true);
        }
      }
    });
  }

  @ReactMethod
  public void initRuntimeSettingsFromString(String template, Promise promise) {
    try {
      dbr.initRuntimeSettingsWithString(template, EnumConflictMode.CM_OVERWRITE);
      promise.resolve(true);
    } catch (BarcodeReaderException e) {
      e.printStackTrace();
      promise.reject("DBR",e.getMessage());
    }
  }

  @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
  @ReactMethod
  public void decodeBase64(String base64, Promise promise) {
    try {
      Bitmap bitmap = BitmapUtils.base642Bitmap(base64);
      TextResult[] results = dbr.decodeBufferedImage(bitmap);
      WritableNativeArray array = new WritableNativeArray();
      if (results != null) {
        for (int i = 0; i < results.length; i++) {
          Log.d("DBR",results[i].barcodeText);
          array.pushMap(Utils.wrapResults(results[i], null, false, true));
        }
      }
      promise.resolve(array);
    } catch (BarcodeReaderException e) {
      e.printStackTrace();
      promise.reject("DBR",e.getMessage());
    }
  }
}
