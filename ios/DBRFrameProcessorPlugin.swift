//
//  VisionCameraDBRPlugin.swift
//  VisionCameraDynamsoftBarcodeReader
//
//  Created by xulihang on 2023/11/20.
//  Copyright © 2023 Facebook. All rights reserved.
//

import UIKit
import DynamsoftBarcodeReader

@objc(DBRFrameProcessorPlugin)
public class DBRFrameProcessorPlugin: FrameProcessorPlugin {
    private static var mTemplate:String! = nil
    private static var mLicense:String! = nil
    private static let context = CIContext(options: nil)
    public override func callback(_ frame: Frame, withArguments arguments: [AnyHashable: Any]?) -> Any? {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(frame.buffer) else {
          print("Failed to get image buffer from sample buffer.")
          return nil
        }

        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        
        guard let cgImage = CIContext().createCGImage(ciImage, from: ciImage.extent) else {
            print("Failed to create bitmap from image.")
            return nil
        }
        
        if arguments != nil {
            DBRFrameProcessorPlugin.initLicense(config: arguments as? [String:String])
            DBRFrameProcessorPlugin.updateRuntimeSettingsWithTemplate(config: arguments as? [String:String])
        }
        
        let image = UIImage(cgImage: cgImage)
        var returned_results: [Any] = []
        let results = try? VisionCameraDynamsoftBarcodeReader.dbr.decodeImage(image)
        let count = results?.count ?? 0
        if count > 0 {
            for index in 0..<count {
                let tr = results![index]
                returned_results.append(VisionCameraDynamsoftBarcodeReader.wrapResult(result: tr))
            }
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
