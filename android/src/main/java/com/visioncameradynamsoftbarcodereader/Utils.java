package com.visioncameradynamsoftbarcodereader;

import android.os.Build;
import android.util.Base64;

import androidx.annotation.RequiresApi;
import com.dynamsoft.dbr.Point;
import com.dynamsoft.dbr.TextResult;
import com.facebook.react.bridge.WritableNativeMap;
import com.mrousavy.camera.frameprocessor.Frame;
import com.mrousavy.camera.parsers.Orientation;

public class Utils {
    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    public static WritableNativeMap wrapResults(TextResult result, Frame image, Boolean isFront, Boolean rotateImage) {
        WritableNativeMap map = new WritableNativeMap();
        map.putString("barcodeText",result.barcodeText);
        map.putString("barcodeFormat",result.barcodeFormatString);
        map.putString("barcodeBytesBase64", Base64.encodeToString(result.barcodeBytes,Base64.DEFAULT));
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
    public static Point rotatedPoint(Point point, Frame image, Boolean isFront){
        Point rotatedPoint = new Point();
        switch (BitmapUtils.getRotationDegreeFromOrientation(image.getOrientation())){
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
}
