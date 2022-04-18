//
//  VisionCameraDBRPlugin.swift
//  vision-camera-dynamsoft-barcode-reader
//
//  Created by xulihang on 2022/1/26.
//

import Foundation
import DynamsoftBarcodeReader

@objc(VisionCameraDBRPlugin)
public class VisionCameraDBRPlugin: NSObject, FrameProcessorPluginBase {

    
    private static var barcodeReader:DynamsoftBarcodeReader! = nil
    private static var mTemplate:String! = nil
    private static let context = CIContext(options: nil)
    @objc
    public static func callback(_ frame: Frame!, withArgs args: [Any]!) -> Any! {
        let config = getConfig(withArgs: args)
        if barcodeReader == nil {
            initDBR(config: config)
        }
        
        updateRuntimeSettingsWithTemplate(config: config)
        
        guard let imageBuffer = CMSampleBufferGetImageBuffer(frame.buffer) else {
          print("Failed to get CVPixelBuffer!")
          return nil
        }
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)

        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
          print("Failed to create CGImage!")
          return nil
        }
        var returned_results: [Any] = []
        let image = UIImage(cgImage: cgImage)
        // code goes here
        let results = try? barcodeReader.decodeImage(image)
        let count = results?.count ?? 0
        if count > 0 {
            for index in 0..<count {
                let tr = results![index]
                returned_results.append(wrapResult(result: tr))
            }
            print("Found barcodes")
        }
        return returned_results
    }
    
    static func initDBR(config: [String:String]!) {
        var license = "";
        license = config?["license"] ?? "DLS2eyJoYW5kc2hha2VDb2RlIjoiMjAwMDAxLTE2NDk4Mjk3OTI2MzUiLCJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSIsInNlc3Npb25QYXNzd29yZCI6IndTcGR6Vm05WDJrcEQ5YUoifQ=="
        let initializer = BarcodeReaderInitializer();
        barcodeReader = initializer.configurationDBR(license: license)
     }
       
    
    static func getConfig(withArgs args: [Any]!) -> [String:String]!{
        if args.count>0 {
            let config = args[0] as? [String: String]
            return config
        }
        return nil
    }
    
    static func updateRuntimeSettingsWithTemplate(config:[String:String]!){
        let template = config?["template"] ?? ""
        var shouldUpdate = false
        
        if template != "" {
            if mTemplate == nil {
                shouldUpdate = true
            } else {
                if mTemplate != template {
                    shouldUpdate = true
                }
            }
            
            if shouldUpdate {
                try? barcodeReader.initRuntimeSettingsWithString(template, conflictMode: EnumConflictMode.overwrite)
                mTemplate = template
            }
            
        } else {
            if mTemplate != nil {
                try? barcodeReader.resetRuntimeSettings()
                mTemplate = nil
            }
        }
    }
    
    static func wrapResult(result: iTextResult) -> Any {
        var map: [String: Any] = [:]
        
        map["barcodeText"] = result.barcodeText
        map["barcodeFormat"] = result.barcodeFormatString
        
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


}
