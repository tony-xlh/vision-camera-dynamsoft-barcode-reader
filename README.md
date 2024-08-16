
# vision-camera-dynamsoft-barcode-reader

React Native Vision Camera Frame Processor Plugin of [Dynamsoft Barcode Reader](https://www.dynamsoft.com/barcode-reader/overview/).

If you do not want to use Vision Camera, you can use the [offical React Native package](https://www.dynamsoft.com/capture-vision/react-native/) by Dynamsoft.

## Versions

For vision-camera v2, use versions 0.x.

For vision-camera v3, use versions 1.x.

For vision-camera v4, use versions >= 2.0.0.

## SDK Versions Used for Different Platforms

| Product      | Android |    iOS |
| ----------- | ----------- | -----------  |
| Dynamsoft Barcode Reader    | 9.x       | 9.x     |

## Installation

```sh
yarn add vision-camera-dynamsoft-barcode-reader
cd ios && pod install
```

Add the plugin to your `babel.config.js`:

```js
module.exports = {
   plugins: [['react-native-worklets-core/plugin']],
    // ...
```

> Note: You have to restart metro-bundler for changes in the `babel.config.js` file to take effect.

## Usage

1. Scan barcodes with vision camera.
   
   ```js
   import { decode } from 'vision-camera-dynamsoft-barcode-reader';
 
   // ...
   const frameProcessor = useFrameProcessor((frame) => {
     'worklet';
     const barcodes = decode(frame);
   }, []);
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

 Since the natural camera sensor's orientation is landscape, the camera image may be rotated for preview while the raw image we get is still not rotated. If we enable `rotateImage`, the plugin will rotate the image automatically to match the camera preview. If it is disabled, the plugin will rotate the returned coordinates instead of the image which may have a slight performance gain. `isFront` is needed for rotating the coordinates since the image of front camera is mirrored. `isFront` is Android-only.

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

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT
