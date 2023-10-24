import * as React from 'react';

import { StyleSheet, View, Text } from 'react-native';
import { Camera, useCameraDevice, useFrameProcessor } from 'react-native-vision-camera';
import { useSharedValue, Worklets } from 'react-native-worklets-core';
import { decode, type TextResult } from 'vision-camera-dynamsoft-barcode-reader';

export default function App() {
  const [hasPermission, setHasPermission] = React.useState(false);
  const device = useCameraDevice('back');
  const [barcodeResults,setBarcodeResults] = React.useState<TextResult[]>([]);
  const setResultsJS = Worklets.createRunInJsFn(setBarcodeResults);
  const fps = 1;

  React.useEffect(() => {
    (async () => {
      const status = await Camera.requestCameraPermission();
      setHasPermission(status === 'granted');
    })();
  }, []);
  const frameProcessor = useFrameProcessor(frame => {
    'worklet';
    const results = decode(frame);
    console.log(results);
    //setBarcodeResults(results)
  }, []);
  
  if (hasPermission == false) return <Text>No camera permission</Text>
  if (device == null) return <Text>No Camera</Text>
  return (
    <>
      <Camera
        style={StyleSheet.absoluteFill}
        device={device}
        isActive={true}
        frameProcessor={frameProcessor}
        fps={fps}
      />
      <Text></Text>
    </>
    
  )
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
});
