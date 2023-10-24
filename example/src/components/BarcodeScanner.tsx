import * as React from 'react';
import { StyleSheet, Text } from 'react-native';
import { Camera, useCameraDevice, useFrameProcessor } from 'react-native-vision-camera';
import { type DBRConfig, type TextResult } from 'vision-camera-dynamsoft-barcode-reader';

interface props {
  onScanned?: (result:TextResult[]) => void;
}

const BarcodeScanner: React.FC<props> = (props: props) => {
  const [hasPermission, setHasPermission] = React.useState(false);
  const [barcodeResults, setBarcodeResults] = React.useState([] as TextResult[]);
  const device = useCameraDevice('back');
  
  const frameProcessor = useFrameProcessor(frame => {
    'worklet'
    const config:DBRConfig = {};
    console.log(frame.pixelFormat);
  }, [])

  React.useEffect(() => {
    (async () => {
      const status = await Camera.requestCameraPermission();
      setHasPermission(status === 'granted');
    })();
  }, []);

  React.useEffect(() => {
    if (props.onScanned) {
      props.onScanned(barcodeResults);
    }
  }, [barcodeResults]);

  return (
      <>
        {device != null &&
        hasPermission && (
        <>
            <Camera
            style={StyleSheet.absoluteFill}
            device={device}
            isActive={true}
            frameProcessor={frameProcessor}
            pixelFormat="yuv"
            />
            {barcodeResults.map((barcode, idx) => (
            <Text key={idx} style={styles.barcodeText}>
                {barcode.barcodeFormat +": "+ barcode.barcodeText}
            </Text>
            ))}
        </>)}
      </>
  );
}

export default BarcodeScanner;

const styles = StyleSheet.create({
  barcodeText: {
    fontSize: 20,
    color: 'white',
    fontWeight: 'bold',
  },
});