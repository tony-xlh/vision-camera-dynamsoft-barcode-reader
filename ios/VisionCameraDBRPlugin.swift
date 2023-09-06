//
//  VisionCameraDBRPlugin.swift
//  VisionCameraDynamsoftBarcodeReader
//
//  Created by xulihang on 2023/9/6.
//  Copyright © 2023 Facebook. All rights reserved.
//

import Foundation
import DynamsoftBarcodeReader

@objc(VisionCameraDBRPlugin)
public class VisionCameraDBRPlugin: FrameProcessorPlugin  {
    private static var mTemplate:String! = nil
    private static var mLicense:String! = nil
    private static let context = CIContext(options: nil)
    public override func callback(_ frame: Frame!, withArguments arguments: [String:Any]) -> Any! {
        let config = arguments

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
