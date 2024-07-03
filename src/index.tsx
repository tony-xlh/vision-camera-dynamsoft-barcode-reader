import { NativeModules, Platform } from 'react-native';
import {VisionCameraProxy, type Frame} from 'react-native-vision-camera';

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


const plugin = VisionCameraProxy.initFrameProcessorPlugin('decode',{})

/**
 * Detect barcodes from the camera preview
 */
export function decode(frame: Frame,config?:DBRConfig):Record<string, TextResult>|undefined {
  'worklet'
  if (plugin == null) throw new Error('Failed to load Frame Processor Plugin "decode"!')
  if (config) {
    let record:Record<string,any> = {};
    if (config.isFront != undefined && config.isFront != null) {
      record["isFront"] = config.isFront;
    }
    if (config.rotateImage != undefined && config.rotateImage != null) {
      record["rotateImage"] = config.rotateImage;
    }
    if (config.template) {
      record["template"] = config.template;
    }
    if (config.license) {
      record["license"] = config.license;
    }
    return plugin.call(frame,record) as any;
  }else{
    return plugin.call(frame) as any;
  }
}


export interface TextResult{
  barcodeText:string;
  barcodeFormat:string;
  barcodeBytesBase64:string;
  x1:number;
  x2:number;
  x3:number;
  x4:number;
  y1:number;
  y2:number;
  y3:number;
  y4:number;
}

export interface DBRConfig{
  template?:string;
  isFront?:boolean;
  rotateImage?:boolean;
  license?:string;
}

/**
 * Init the license of Dynamsoft Barcode Reader
 */
export function initLicense(license:string): Promise<boolean> {
  return VisionCameraDynamsoftBarcodeReader.initLicense(license);
}

/**
 * Init the runtime settings from a JSON template
 */
export function initRuntimeSettingsFromString(template:string): Promise<boolean> {
  return VisionCameraDynamsoftBarcodeReader.initRuntimeSettingsFromString(template);
}

/**
 * Detect barcodes from base64
 */
export function decodeBase64(base64:string): Promise<TextResult[]> {
  return VisionCameraDynamsoftBarcodeReader.decodeBase64(base64);
}