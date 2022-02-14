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
            configurationDBR(config: config)
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
        let results = try? barcodeReader.decode(image, withTemplate: "")
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
    
    static func configurationDBR(config: [String:String]!) {
        var license = "";
        var organizationID = "200001";

        license = config?["license"] ?? ""
        organizationID = config?["organizationID"] ?? "200001"
        

        let dls = iDMDLSConnectionParameters()
        if license != "" {
           barcodeReader = DynamsoftBarcodeReader(license: license)
        }else{
           dls.organizationID = organizationID
           barcodeReader = DynamsoftBarcodeReader(licenseFromDLS: dls, verificationDelegate: self)
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
                var error: NSError? = NSError()
                barcodeReader.initRuntimeSettings(with: template, conflictMode: EnumConflictMode.overwrite, error: &error)
                mTemplate = template
            }
            
        } else {
            if mTemplate != nil {
                var error: NSError? = NSError()
                barcodeReader.resetRuntimeSettings(&error)
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
