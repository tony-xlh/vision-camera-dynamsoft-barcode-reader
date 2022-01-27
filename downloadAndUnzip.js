const download = require('download');
const fs = require('fs');

function fsExistsSync(path) {
    try{
        fs.accessSync(path,fs.F_OK);
    }catch(e){
        return false;
    }
    return true;
}

async function main(){
    try{
        var options = {"extract":true};
        if (fsExistsSync("./DynamsoftBarcodeReader.framework")==true){
            console.log("DBR already exists");
        }else{
            console.log("Downloading DBR");
            await download('https://download.dynamsoft.com/cocoapods/dynamsoft-barcodereader-ios-8.8.0.zip', './',options);
        }
    }catch (e){
        console.log(e)
    }
}

main();


