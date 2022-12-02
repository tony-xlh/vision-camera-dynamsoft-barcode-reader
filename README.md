# vision-camera-dynamsoft-barcode-reader

React Native Vision Camera Frame Processor Plugin of [Dynamsoft Barcode Reader](https://www.dynamsoft.com/barcode-reader/overview/).

If you only need to scan barcodes and do not want to use Vision Camera, you can use [Dynamsoft Capture Vision](https://github.com/Dynamsoft/capture-vision-react-native).

## Installation

```sh
npm install vision-camera-dynamsoft-barcode-reader
```

make sure you correctly setup react-native-reanimated and add this to your babel.config.js

```
[
  'react-native-reanimated/plugin',
  {
    globals: ['__decode'],
  },
]
```

### Android ProGuard Configuration

```
-keep class com.swmansion.reanimated.** { *; }
-keep class com.facebook.react.turbomodule.** { *; }
-keep class com.dynamsoft.dbr.** { *; }
-keep class androidx.camera.core.** {*;}
```

## Usage

1. Scan barcodes from the camera preview.

   ```ts
   import * as React from 'react';
   import { StyleSheet, Text } from 'react-native';
   import { Camera, useCameraDevices, useFrameProcessor } from 'react-native-vision-camera';
   import { DBRConfig, decode, TextResult } from 'vision-camera-dynamsoft-barcode-reader';
   import * as REA from 'react-native-reanimated';

   export default function App() {
     const [hasPermission, setHasPermission] = React.useState(false);
     const [barcodeResults, setBarcodeResults] = React.useState([] as TextResult[]);
     const devices = useCameraDevices();
     const device = devices.back;
     const frameProcessor = useFrameProcessor((frame) => {
       'worklet'
       const config:DBRConfig = {};
       config.template="{\"ImageParameter\":{\"BarcodeFormatIds\":[\"BF_QR_CODE\"],\"Description\":\"\",\"Name\":\"Settings\"},\"Version\":\"3.0\"}"; //scan qrcode only

       const results:TextResult[] = decode(frame,config)
       REA.runOnJS(setBarcodeResults)(results);
     }, [])

     React.useEffect(() => {
       (async () => {
         const status = await Camera.requestCameraPermission();
         setHasPermission(status === 'authorized');
       })();
     }, []);

     return (
       device != null &&
       hasPermission && (
         <>
           <Camera
             style={StyleSheet.absoluteFill}
             device={device}
             isActive={true}
             frameProcessor={frameProcessor}
             frameProcessorFps={5}
           />
           {barcodeResults.map((barcode, idx) => (
             <Text key={idx} style={styles.barcodeText}>
               {barcode.barcodeFormat +": "+ barcode.barcodeText}
             </Text>
           ))}
         </>
       )
     );
   }

   const styles = StyleSheet.create({
     container: {
       flex: 1,
       alignItems: 'center',
       justifyContent: 'center',
     },
     barcodeText: {
       fontSize: 20,
       color: 'white',
       fontWeight: 'bold',
     },
   });

   ```

2. Scan barcodes from a base64-encoded static image.

   ```ts
   let results = await decodeBase64(base64);
   ```

3. License initialization ([apply for a trial license](https://www.dynamsoft.com/customer/license/trialLicense/?product=dbr)).

   ```ts
   await initLicense("your license");
   ```

### Interfaces

TextResult:

```js
 TextResult{
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
```

Configuration:

```js
DBRConfig{
  template?:string;
  license?:string;
  isFront?:boolean;
  rotateImage?:boolean;
}
```

`isFront` and `rotateImage` are Android-only. Since the natural camera sensor's orientation in Android is landscape, the camera image may be rotated for preview while the raw image we get is still not rotated. If we enable `rotateImage`, the plugin will rotate the image automatically to match the camera preview. If it is disabled, the plugin will rotate the returned coordinates instead of the image which may have a slight performance gain. `isFront` is needed for rotating the coordinates since the image of front camera is mirrored.

## Supported Platforms

* Android
* iOS

## Supported Barcode Symbologies

* Code 11
* Code 39
* Code 93
* Code 128
* Codabar
* EAN-8
* EAN-13
* UPC-A
* UPC-E
* Interleaved 2 of 5 (ITF)
* Industrial 2 of 5 (Code 2 of 5 Industry, Standard 2 of 5, Code 2 of 5)
* ITF-14 
* QRCode
* DataMatrix
* PDF417
* GS1 DataBar
* Maxicode
* Micro PDF417
* Micro QR
* PatchCode
* GS1 Composite
* Postal Code
* Dot Code


## Detailed Installation Guide

Let's create a new react native project and use the plugin.

1. Create a new project: `npx react-native init MyTestApp`
2. Install required packages: `npm install vision-camera-dynamsoft-barcode-reader react-native-reanimated react-native-vision-camera`. Update relevant files following the [react-native-reanimated installation guide](https://docs.swmansion.com/react-native-reanimated/docs/fundamentals/installation/). You can use jsc instead of hermes
3. Update the `babel.config.js` file
4. Add camera permission for both Android and iOS
5. Update `App.tsx` to use the camera and the plugin
6. For Android, register the plugin in `MainApplication.java` following the [guide](https://mrousavy.com/react-native-vision-camera/docs/guides/frame-processors-plugins-android)
7. Run the project: `npx react-native run-andoid/run-ios`

You can check out the [example](https://github.com/xulihang/vision-camera-dynamsoft-barcode-reader/tree/main/example) for more details.

## Blogs on How the Plugin is Made

* [Build a React Native Vision Camera Frame Processor Plugin to Scan Barcodes for Android](https://www.dynamsoft.com/codepool/react-native-vision-camera-barcode-plugin-android.html)
* [Build a React Native Vision Camera Frame Processor Plugin to Scan Barcodes for iOS](https://www.dynamsoft.com/codepool/react-native-vision-camera-barcode-plugin-ios.html)
* [Build a React Native QR Code Scanner using Vision Camera](https://www.dynamsoft.com/codepool/react-native-qr-code-scanner-vision-camera.html)

## Versions

For versions >= 0.4.0, Dynamsoft Barcode Reader 9.x is used.

For versions < 0.4.0, Dynamsoft Barcode Reader 8.x is used.

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT
