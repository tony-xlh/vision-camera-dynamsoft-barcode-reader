import { NativeModules, Platform } from 'react-native';

const LINKING_ERROR =
  `The package 'vision-camera-dynamsoft-barcode-reader' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n';

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

export function multiply(a: number, b: number): Promise<number> {
  return VisionCameraDynamsoftBarcodeReader.multiply(a, b);
}
