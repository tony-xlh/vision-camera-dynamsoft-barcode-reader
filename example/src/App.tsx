import * as React from 'react';
import { Dimensions, SafeAreaView, StyleSheet, Text } from 'react-native';
import { Camera, useCameraDevices, useFrameProcessor } from 'react-native-vision-camera';
import { DBRConfig, decode, TextResult } from 'vision-camera-dynamsoft-barcode-reader';
import * as REA from 'react-native-reanimated';
import { Polygon, Rect, Svg } from 'react-native-svg';

export default function App() {
  const [hasPermission, setHasPermission] = React.useState(false);
  const [barcodeResults, setBarcodeResults] = React.useState([] as TextResult[]);
  const [frameWidth, setFrameWidth] = React.useState(1280);
  const [frameHeight, setFrameHeight] = React.useState(720);
  const devices = useCameraDevices();
  const device = devices.back;
  
  const frameProcessor = useFrameProcessor((frame) => {
    'worklet'
    const config:DBRConfig = {};
    //config.template="{\"ImageParameter\":{\"BarcodeFormatIds\":[\"BF_QR_CODE\"],\"Description\":\"\",\"Name\":\"Settings\"},\"Version\":\"3.0\"}";
    
    const results:TextResult[] = decode(frame,config)
    
    console.log("height: "+frame.height);
    console.log("width: "+frame.width);
    
    REA.runOnJS(setBarcodeResults)(results);
    REA.runOnJS(setFrameWidth)(frame.width);
    REA.runOnJS(setFrameHeight)(frame.height);
  }, [])

  function getPointsData(lr:TextResult){
    //let point1 = rotate(frameWidth/2,frameHeight/2,lr.x1,lr.y1,90);
    //let point2 = rotate(frameWidth/2,frameHeight/2,lr.x2,lr.y2,90);
    //let point3 = rotate(frameWidth/2,frameHeight/2,lr.x3,lr.y3,90);
    //let point4 = rotate(frameWidth/2,frameHeight/2,lr.x4,lr.y4,90);
    //let point1 = rotatePoint(lr.x1,lr.y1,90);
    //let point2 = rotatePoint(lr.x2,lr.y2,90);
    //let point3 = rotatePoint(lr.x3,lr.y3,90);
    //let point4 = rotatePoint(lr.x4,lr.y4,90);
    //let x1 = point1[0];
    //let y1 = point1[1];
    //let x2 = point2[0];
    //let y2 = point2[1];
    //let x3 = point3[0];
    //let y3 = point3[1];
    //let x4 = point4[0];
    //let y4 = point4[1];
    let x1 = lr.x1;
    let x2 = lr.x2;
    let x3 = lr.x3;
    let x4 = lr.x4;
    let y1 = lr.y1;
    let y2 = lr.y2;
    let y3 = lr.y3;
    let y4 = lr.y4;
    var pointsData = x1+","+y1 + " ";
    pointsData = pointsData+ x2+","+y2 + " ";
    pointsData = pointsData+ x3+","+y3 + " ";
    pointsData = pointsData+ x4+","+y4;
    console.log(pointsData);
    return pointsData;
  }

  function rotate(cx, cy, x, y, angle) {
    var radians = (Math.PI / 180) * angle,
        cos = Math.cos(radians),
        sin = Math.sin(radians),
        nx = (cos * (x - cx)) + (sin * (y - cy)) + cx,
        ny = (cos * (y - cy)) - (sin * (x - cx)) + cy;
        nx = Math.floor(nx);
        ny = Math.floor(ny);
    return [nx, ny];
  }

  function rotatePoint(x,y,angle) { 
    var a = angle * Math.PI / 180.0;
    var cosa = Math.cos(a);
    var sina = Math.sin(a);
    var nx = x * cosa - y * sina;
    var ny = x * sina + y * cosa;
    return [nx,ny];
 }

  function getViewBox(){
    let viewBox = null;
    if (frameHeight>frameWidth && Dimensions.get('window').width>Dimensions.get('window').height){
      console.log("Has rotation");
      viewBox = "0 0 "+frameHeight+" "+frameWidth;
    }else {
      viewBox = "0 0 "+frameHeight+" "+frameWidth;
    }    
    console.log("viewBox"+viewBox);
    return viewBox;
  }

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
            <Text key={idx} style={styles.barcodeText}>
                {barcode.barcodeFormat +": "+ barcode.barcodeText}
            </Text>
            ))}
        </>)}
        <Svg style={[StyleSheet.absoluteFill]} viewBox={getViewBox()}>

          {barcodeResults.map((barcode, idx) => (
            <Polygon key={idx}
            points={getPointsData(barcode)}
            fill="lime"
            stroke="green"
            opacity="0.5"
            strokeWidth="1"
          />
          ))}
          
        </Svg>
      </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex:1
  },
  barcodeText: {
    fontSize: 20,
    color: 'white',
    fontWeight: 'bold',
  },
});
