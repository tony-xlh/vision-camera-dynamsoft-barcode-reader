import * as React from 'react';
import { Camera, useCameraDevices, useFrameProcessor } from 'react-native-vision-camera';
import { StyleSheet, Text } from 'react-native';
import { decode } from 'vision-camera-dynamsoft-barcode-reader';
import { Worklets } from 'react-native-worklets-core';

export default function App() {
  const [hasPermission, setHasPermission] = React.useState(false);
  const [barcodeText,setBarcodeText] = React.useState("");
  const devices = useCameraDevices()
  const device = devices.back
  const frameProcessor = useFrameProcessor((frame) => {
    'worklet'
    const results:any = decode(frame,{})
    console.log(results);
    if (results.length>0) {
      Worklets.createRunInJsFn(setBarcodeText)(results[0].barcodeText);
    }
  }, [])
  
  React.useEffect(() => {
    (async () => {
      const status = await Camera.requestCameraPermission();
      setHasPermission(status === 'granted');
    })();
  }, []);
  if (hasPermission == false) return <Text>No camera permission</Text>
  if (device == null) return <Text>Loading...</Text>
  return (
    <>
      <Text>{{ barcodeText }}</Text>
      <Camera
        style={StyleSheet.absoluteFill}
        device={device}
        isActive={true}
        frameProcessor={frameProcessor}
      ></Camera>
    </>
  )
}
