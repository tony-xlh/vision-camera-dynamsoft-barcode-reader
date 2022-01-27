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
    private static let context = CIContext(options: nil)
    @objc
    public static func callback(_ frame: Frame!, withArgs args: [Any]!) -> Any! {
        if barcodeReader == nil {
            configurationDBR(withArgs:args)
        }
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
    
    static func configurationDBR(withArgs args: [Any]!) {
        var license = "";
        var organizationID = "200001";
        var template = "";
        if args.count>0 {
            let config = args[0] as? [String: String]
            license = config?["license"] ?? ""
            organizationID = config?["organizationID"] ?? "200001"
            template = config?["template"] ?? ""
        }
        

        let dls = iDMDLSConnectionParameters()
        if license != "" {
           barcodeReader = DynamsoftBarcodeReader(license: license)
        }else{
           dls.organizationID = organizationID
           barcodeReader = DynamsoftBarcodeReader(licenseFromDLS: dls, verificationDelegate: self)
        }
        
        if template != "" {
            var error: NSError? = NSError()
            barcodeReader.initRuntimeSettings(with: template, conflictMode: EnumConflictMode.overwrite, error: &error)
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
