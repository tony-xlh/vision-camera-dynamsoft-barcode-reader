import * as React from 'react';
import { Button, SafeAreaView, StyleSheet, Switch, Text, View } from 'react-native';
import type { TextResult } from 'vision-camera-dynamsoft-barcode-reader';
import BarcodeScanner from './components/BarcodeScanner';
import * as DBR from 'vision-camera-dynamsoft-barcode-reader';
import {launchImageLibrary, ImageLibraryOptions} from 'react-native-image-picker';

const Separator = () => (
  <View style={styles.separator} />
);

export default function App() {
  const [useCamera,setUseCamera] = React.useState(false);
  const [continuous, setContinuous] = React.useState(false);
  const [barcodeResults, setBarcodeResults] = React.useState([] as TextResult[]);
  const toggleSwitch = () => setContinuous(previousState => !previousState);
  
  React.useEffect(() => {
    (async () => {
      await DBR.initLicense("DLS2eyJoYW5kc2hha2VDb2RlIjoiMjAwMDAxLTE2NDk4Mjk3OTI2MzUiLCJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSIsInNlc3Npb25QYXNzd29yZCI6IndTcGR6Vm05WDJrcEQ5YUoifQ==");
    })();
  }, []);

  const onScanned = (results:TextResult[]) => {
    setBarcodeResults(results);
    if (results.length>0 && !continuous) {
      setUseCamera(false);
    }
  }

  const decodeFromAlbum = async () => {
    let options: ImageLibraryOptions = {
      mediaType: 'photo',
      includeBase64: true,
    }
    let response = await launchImageLibrary(options);
    if (response && response.assets) {
      if (response.assets[0].base64) {
        console.log(response.assets[0].base64);
        let results = await DBR.decodeBase64(response.assets[0].base64);
        setBarcodeResults(results);
      }
    }
  }

  return (
    <SafeAreaView style={styles.container}>
      {useCamera && (
        <>
          <BarcodeScanner onScanned={onScanned}></BarcodeScanner>
          <View
            style={{position: 'absolute', top: 0, left: 0, right: 0, bottom: 0, justifyContent: 'flex-end', alignItems: 'center'}}
          >
            <Button
              title="Close"
              onPress={() => setUseCamera(false)}
            />
          </View>
        </>
        
      )}
      {!useCamera &&(
          <View style={{alignItems:"center"}}>
            <Text style={styles.title}>
              Dynamsoft Barcode Reader Demo
            </Text>
            <Button
              title="Read Barcodes from the Camera"
              onPress={() => setUseCamera(true)}
            />
            <Separator />
            <View style={styles.switchView}>
              <Text style={{alignSelf: 'center'}}>
                Continues Scan
              </Text>
              <Switch 
                style={{alignSelf: 'center'}}
                trackColor={{ false: "#767577", true: "#81b0ff" }}
                thumbColor={continuous ? "#f5dd4b" : "#f4f3f4"}
                ios_backgroundColor="#3e3e3e"
                onValueChange={toggleSwitch}
                value={continuous}
              />
            </View>
            <Separator />
            <Button
              title="Read Barcodes from the Album"
              onPress={() => decodeFromAlbum()}
            />
            <Separator />
            {barcodeResults.map((barcode, idx) => (
              <Text key={idx}>
                {barcode.barcodeFormat+": "+barcode.barcodeText}
              </Text>
            ))}
          </View>
      )}
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex:1,
  },
  title: {
    textAlign: 'center',
    marginVertical: 8,
  },
  separator: {
    marginVertical: 4,
  },
  switchView: {
    alignItems: 'center',
    flexDirection: "row",
  },
  barcodeText: {
    fontSize: 20,
    color: 'white',
    fontWeight: 'bold',
  },
});
