import { NativeModules, Platform } from 'react-native';
import type { Frame } from 'react-native-vision-camera'

const LINKING_ERROR =
  `The package 'vision-camera-dynamsoft-barcode-reader' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo managed workflow\n';

export interface TextResult{
    barcodeText:string;
    barcodeFormat:string;
    x1:number;
    x2:number;
    x3:number;
    x4:number;
    y1:number;
    y2:number;
    y3:number;
    y4:number;
}

const VisionCameraDynamsoftBarcodeReader = NativeModules.VisionCameraDynamsoftBarcodeReader
  ? NativeModules.VisionCameraDynamsoftBarcodeReader
  : new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR);
        },
      }
    );

  export function decode(frame: Frame): TextResult[] {
    'worklet'
    return __decode(frame)
  }
