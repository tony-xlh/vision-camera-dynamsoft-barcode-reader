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
        
        let image = UIImage(cgImage: cgImage)
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
}
