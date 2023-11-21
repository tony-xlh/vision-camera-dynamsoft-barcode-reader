import * as React from 'react';
import { StyleSheet, Text } from 'react-native';
import { Camera, useCameraDevice, useFrameProcessor } from 'react-native-vision-camera';
import { decode, type DBRConfig, type TextResult } from 'vision-camera-dynamsoft-barcode-reader';
import { Worklets} from 'react-native-worklets-core';

interface props {
  onScanned?: (result:TextResult[]) => void;
}

const BarcodeScanner: React.FC<props> = (props: props) => {
  const [hasPermission, setHasPermission] = React.useState(false);
  const [results, setResults] = React.useState([] as TextResult[]);
  const device = useCameraDevice('back');
  const setResultsJS = Worklets.createRunInJsFn(setResults);

  const frameProcessor = useFrameProcessor(frame => {
    'worklet'
    const config:DBRConfig = {
      rotateImage:false,
      template:"{\"ImageParameter\":{\"BarcodeFormatIds\":[\"BF_ALL\"],\"Description\":\"\",\"Name\":\"Settings\"},\"Version\":\"3.0\"}"
    };
    const results = decode(frame,config);
    console.log(results);
    if (results) {
      setResultsJS(results);
    }
  }, [])

  React.useEffect(() => {
    (async () => {
      const status = await Camera.requestCameraPermission();
      setHasPermission(status === 'granted');
    })();
  }, []);

  React.useEffect(() => {
    if (props.onScanned) {
      props.onScanned(results);
    }
  }, [results]);

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
            {results.map((barcode, idx) => (
            <Text key={"barcode"+idx} style={styles.barcodeText}>
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