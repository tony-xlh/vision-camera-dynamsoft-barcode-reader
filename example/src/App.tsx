import * as React from 'react';
import { SafeAreaView, StyleSheet, Text } from 'react-native';
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
    config.template="{\"ImageParameter\":{\"BarcodeFormatIds\":[\"BF_QR_CODE\"],\"Description\":\"\",\"Name\":\"Settings\"},\"Version\":\"3.0\"}";

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
      <SafeAreaView style={styles.container}>
        {device != null &&
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
        </>)}
      </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1
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
