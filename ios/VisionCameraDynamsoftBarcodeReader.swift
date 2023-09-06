import Foundation
import DynamsoftBarcodeReader

@objc(VisionCameraDynamsoftBarcodeReader)
class VisionCameraDynamsoftBarcodeReader: NSObject  {
    static var dbr:DynamsoftBarcodeReader = DynamsoftBarcodeReader()
    
    @objc(initRuntimeSettingsFromString:withResolver:withRejecter:)
    func initRuntimeSettingsFromString(template:String, resolve:RCTPromiseResolveBlock,reject:RCTPromiseRejectBlock) -> Void {
        do {
            try VisionCameraDynamsoftBarcodeReader.dbr.initRuntimeSettingsWithString(template, conflictMode: EnumConflictMode.overwrite)
            resolve(true)
        }catch {
            print("Unexpected error: \(error).")
            resolve(false)
        }
    }
    
    @objc(decodeBase64:withResolver:withRejecter:)
    func decodeBase64(base64:String,resolve:RCTPromiseResolveBlock,reject:RCTPromiseRejectBlock) -> Void {
        var returned_results: [Any] = []
        let image = VisionCameraDynamsoftBarcodeReader.convertBase64ToImage(base64)
        if image != nil {
            let results = try? VisionCameraDynamsoftBarcodeReader.dbr.decodeImage(image!)
            let count = results?.count ?? 0
            if count > 0 {
                for index in 0..<count {
                    let tr = results![index]
                    returned_results.append(VisionCameraDynamsoftBarcodeReader.wrapResult(result: tr))
                }
            }
        }
        resolve(returned_results)
    }
    
    @objc(initLicense:withResolver:withRejecter:)
    func initLicense(license:String, resolve:RCTPromiseResolveBlock,reject:RCTPromiseRejectBlock) -> Void {
        let initializer = BarcodeReaderInitializer()
        initializer.initLicense(license: license)
        resolve(true)
    }
    
    static func wrapResult(result: iTextResult) -> Any {
        var map: [String: Any] = [:]
        
        map["barcodeText"] = result.barcodeText
        map["barcodeFormat"] = result.barcodeFormatString
        map["barcodeBytesBase64"] = result.barcodeBytes?.base64EncodedString()

        let points = result.localizationResult?.resultPoints as! [CGPoint]
        map["x1"] = points[0].x
        map["x2"] = points[1].x
        map["x3"] = points[2].x
        map["x4"] = points[3].x
        map["y1"] = points[0].y
        map["y2"] = points[1].y
        map["y3"] = points[2].y
        map["y4"] = points[3].y
        
        return map
    }
    
    static public func convertBase64ToImage(_ imageStr:String) ->UIImage?{
        if let data: NSData = NSData(base64Encoded: imageStr, options:NSData.Base64DecodingOptions.ignoreUnknownCharacters)
        {
            if let image: UIImage = UIImage(data: data as Data)
            {
                return image
            }
        }
        return nil
    }
        
}
