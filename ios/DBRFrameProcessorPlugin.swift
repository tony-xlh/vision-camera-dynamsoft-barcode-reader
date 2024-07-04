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
    public override init(proxy: VisionCameraProxyHolder, options: [AnyHashable : Any]! = [:]) {
        super.init(proxy: proxy, options: options)
    }
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
            DBRFrameProcessorPlugin.initLicense(config: arguments)
            DBRFrameProcessorPlugin.updateRuntimeSettingsWithTemplate(config: arguments)
        }
        var templateName = ""
        if arguments?["templateName"] != nil {
            templateName = arguments?["templateName"] as! String
        }
        
        var image = UIImage(cgImage: cgImage)
        var degree = 0.0;
        if UIDevice.current.orientation == UIDeviceOrientation.portrait {
            degree = 90.0;
        }else if UIDevice.current.orientation == UIDeviceOrientation.landscapeRight {
            degree = 270.0;
        }
        if degree != 0.0 {
            image = DBRFrameProcessorPlugin.rotate(image:image,degree:degree)
        }
        var returned_results: [Any] = []
        var results:[iTextResult]?;
        if templateName != "" {
            results = try? VisionCameraDynamsoftBarcodeReader.dbr.decodeImage(image,templateName: templateName)
        }else{
            results = try? VisionCameraDynamsoftBarcodeReader.dbr.decodeImage(image)
        }
        let count = results?.count ?? 0
        if count > 0 {
            for index in 0..<count {
                let tr = results![index]
                returned_results.append(VisionCameraDynamsoftBarcodeReader.wrapResult(result: tr))
            }
        }
        return returned_results
    }
    
    static func initLicense(config: [AnyHashable: Any]?) {
        if config?["license"] != nil {
           let license = config?["license"] as! String
           if license != mLicense {
               mLicense = license
               let initializer = BarcodeReaderInitializer()
               initializer.initLicense(license: license)
           }
        }
    }
    
    static func updateRuntimeSettingsWithTemplate(config:[AnyHashable: Any]?){
        if config?["template"] != nil {
            let template = config?["template"] as! String
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
    public static func rotate(image: UIImage, degree: CGFloat) -> UIImage {
        let radians = degree / (180.0 / .pi)
        let rotatedSize = CGRect(origin: .zero, size: image.size)
            .applying(CGAffineTransform(rotationAngle: CGFloat(radians)))
            .integral.size
        UIGraphicsBeginImageContext(rotatedSize)
        if let context = UIGraphicsGetCurrentContext() {
            let origin = CGPoint(x: rotatedSize.width / 2.0,
                                 y: rotatedSize.height / 2.0)
            context.translateBy(x: origin.x, y: origin.y)
            context.rotate(by: radians)
            image.draw(in: CGRect(x: -origin.y, y: -origin.x,
                                  width: image.size.width, height: image.size.height))
            let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            return rotatedImage ?? image
        }
        return image
    }
}
