import * as React from 'react';
import { StyleSheet, Text } from 'react-native';
import { Camera, runAsync, runAtTargetFps, useCameraDevice, useCameraFormat, useFrameProcessor } from 'react-native-vision-camera';
import { decode, type DBRConfig, type TextResult } from 'vision-camera-dynamsoft-barcode-reader';
import { Worklets} from 'react-native-worklets-core';

interface props {
  onScanned?: (result:TextResult[]) => void;
}

const BarcodeScanner: React.FC<props> = (props: props) => {
  const [hasPermission, setHasPermission] = React.useState(false);
  const [isActive, setIsActive] = React.useState(false);
  const [results, setResults] = React.useState([] as TextResult[]);
  const convertAndSetResults = (records:Record<string,TextResult>) => {
    let results:TextResult[] = [];
    for (let index = 0; index < Object.keys(records).length; index++) {
      const result = records[Object.keys(records)[index]];
      results.push(result);
    }
    setResults(results);
  }
  const convertAndSetResultsJS = Worklets.createRunOnJS(convertAndSetResults);
  const device = useCameraDevice("back");
  const cameraFormat = useCameraFormat(device, [
    { videoResolution: { width: 1280, height: 720 } },
    { fps: 60 }
  ])
  const frameProcessor = useFrameProcessor(frame => {
    'worklet'
    runAtTargetFps(3, () => {
      'worklet'
      const config:DBRConfig = {
        rotateImage:false,
        template:"{\"ImageParameter\":{\"BarcodeFormatIds\":[\"BF_ALL\"],\"Description\":\"\",\"Name\":\"Settings\"},\"Version\":\"3.0\"}"
      };
      const results = decode(frame,config);
      console.log("decode");
      console.log(results);
      if (results) {
        convertAndSetResultsJS(results);
      }
    })
  }, [])

  React.useEffect(() => {
    (async () => {
      const status = await Camera.requestCameraPermission();
      setHasPermission(status === 'granted');
      setIsActive(true);
    })();
  }, []);

  React.useEffect(() => {
    if (props.onScanned && results) {
      props.onScanned(results);
    }
  }, [results]);

  const renderBarcodeResults = ()=> {
    if (results) {
      const listItems = results.map((barcode,idx) =>
        <Text key={"barcode"+idx} style={styles.barcodeText}>
            {barcode.barcodeFormat +": "+ barcode.barcodeText}
        </Text>
      );
      return (
        <>
          {listItems}
        </>
      );
    }
  }

  return (
      <>
        {device &&
        hasPermission && (
        <>
            <Camera
            style={StyleSheet.absoluteFill}
            device={device}
            isActive={isActive}
            format={cameraFormat}
            frameProcessor={frameProcessor}
            pixelFormat="yuv"
            />
            {renderBarcodeResults()}
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