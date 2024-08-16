import * as React from 'react';
import { StyleSheet } from 'react-native';
import { Camera, runAsync, useCameraDevice, useCameraFormat, useFrameProcessor } from 'react-native-vision-camera';
import { decode, type DBRConfig, type TextResult } from 'vision-camera-dynamsoft-barcode-reader';
import { Worklets} from 'react-native-worklets-core';
import { Polygon, Svg, Text as SVGText } from 'react-native-svg';
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
    runAsync(frame, () => {
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

  const getPointsData = (lr:TextResult) => {
    var pointsData = lr.x1 + "," + lr.y1 + " ";
    pointsData = pointsData+lr.x2 + "," + lr.y2 +" ";
    pointsData = pointsData+lr.x3 + "," + lr.y3 +" ";
    pointsData = pointsData+lr.x4 + "," + lr.y4;
    return pointsData;
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
            resizeMode='contain'
            pixelFormat="yuv"
            />
            <Svg style={StyleSheet.absoluteFill} 
              preserveAspectRatio="xMidYMid slice"
              viewBox="0 0 720 1280">
              {results.map((barcode, idx) => (
                <Polygon key={"poly-"+idx}
                  points={getPointsData(barcode)}
                  fill="lime"
                  stroke="green"
                  opacity="0.5"
                  strokeWidth="1"
                />
              ))}
              {results.map((barcode, idx) => (
                <SVGText key={"text-"+idx}
                  fill="white"
                  stroke="purple"
                  fontSize={720/400*20}
                  fontWeight="bold"
                  x={barcode.x1}
                  y={barcode.y1}
                >
                  {barcode.barcodeText}
                </SVGText>
              ))}
            
            </Svg>
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