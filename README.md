# vision-camera-dynamsoft-barcode-reader

React Native Vision Camera Frame Processor Plugin of [Dynamsoft Barcode Reader](https://www.dynamsoft.com/barcode-reader/overview/)

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

## Usage

```js
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
          <Text key={idx} style={styles.barcodeTextURL}>
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
  box: {
    width: 60,
    height: 60,
    marginVertical: 20,
  },
  barcodeTextURL: {
    fontSize: 20,
    color: 'white',
    fontWeight: 'bold',
  },
});

```

## Detailed Installation Guide

Let's create a new react native project and use the plugin.

1. Create a new project: `npx react-native init MyTestApp`
2. Install required packages: `npm install vision-camera-dynamsoft-barcode-reader react-native-reanimated react-native-vision-camera`. Update relevant files following the [react-native-reanimated installation guide](https://docs.swmansion.com/react-native-reanimated/docs/fundamentals/installation/). You can use jsc instead of hermes
3. Update the `babel.config.js` file
4. Add camera permission for both Android and iOS
5. Update `App.tsx` to use the camera and the plugin
6. Run the project: `npx react-native run-andoid/run-ios`

You can check out the [example](https://github.com/xulihang/vision-camera-dynamsoft-barcode-reader/tree/main/example) for more details.

## Supported Platforms

* Android
* iOS

## Supported Barcode Symbologies

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
