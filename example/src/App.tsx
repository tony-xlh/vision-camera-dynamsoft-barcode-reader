import * as React from 'react';
import { Camera, useCameraDevices } from 'react-native-vision-camera';
import { StyleSheet, Text } from 'react-native';

export default function App() {
  const [hasPermission, setHasPermission] = React.useState(false);
  const devices = useCameraDevices()
  const device = devices.back
  
  React.useEffect(() => {
    (async () => {
      const status = await Camera.requestCameraPermission();
      setHasPermission(status === 'granted');
    })();
  }, []);
  if (hasPermission == false) return <Text>No camera permission</Text>
  if (device == null) return <Text>Loading...</Text>
  return (
    <Camera
      style={StyleSheet.absoluteFill}
      device={device}
      isActive={true}
    />
  )
}
