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

    private static var mTemplate:String! = nil
    private static var mLicense:String! = nil
    private static let context = CIContext(options: nil)
    @objc
    public static func callback(_ frame: Frame!, withArgs args: [Any]!) -> Any! {
        let config = getConfig(withArgs: args)

        //for compatibility
        initLicense(config: config)
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
        let results = try? VisionCameraDynamsoftBarcodeReader.dbr.decodeImage(image)
        let count = results?.count ?? 0
        if count > 0 {
            for index in 0..<count {
                let tr = results![index]
                returned_results.append(VisionCameraDynamsoftBarcodeReader.wrapResult(result: tr))
            }
            print("Found barcodes")
        }
        return returned_results
    }
    
    static func initLicense(config: [String:String]!) {
        if config?["license"] != nil {
            let license = config?["license"] ?? "DLS2eyJoYW5kc2hha2VDb2RlIjoiMjAwMDAxLTE2NDk4Mjk3OTI2MzUiLCJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSIsInNlc3Npb25QYXNzd29yZCI6IndTcGR6Vm05WDJrcEQ5YUoifQ=="
            if license != mLicense {
                mLicense = license
                let initializer = BarcodeReaderInitializer()
                initializer.initLicense(license: license)
            }
        }
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
                try? VisionCameraDynamsoftBarcodeReader.dbr.initRuntimeSettingsWithString(template, conflictMode: EnumConflictMode.overwrite)
                mTemplate = template
            }
            
        } else {
            if mTemplate != nil {
                try? VisionCameraDynamsoftBarcodeReader.dbr.resetRuntimeSettings()
                mTemplate = nil
            }
        }
    }
    
    


}
