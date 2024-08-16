//
//  VisionCameraDynamsoftBarcodeReader.swift
//  VisionCameraDynamsoftBarcodeReader
//
//  Created by xulihang on 2022/12/2.
//  Copyright © 2022 Facebook. All rights reserved.
//

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
    
    @objc(decodeBase64:templateName:withResolver:withRejecter:)
    func decodeBase64(base64:String,templateName:String,resolve:RCTPromiseResolveBlock,reject:RCTPromiseRejectBlock) -> Void {
        var returned_results: [Any] = []
        let image = VisionCameraDynamsoftBarcodeReader.convertBase64ToImage(base64)
        if image != nil {
            var results:[iTextResult]?
            if templateName != "" {
                results = try? VisionCameraDynamsoftBarcodeReader.dbr.decodeImage(image!,templateName: templateName)
            }else{
                results = try? VisionCameraDynamsoftBarcodeReader.dbr.decodeImage(image!)
            }
            
            let count = results?.count ?? 0
            if count > 0 {
                for index in 0..<count {
                    let tr = results![index]
                    returned_results.append(VisionCameraDynamsoftBarcodeReader.wrapResult(result: tr, image: image!, rotate: false, degree: 0))
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
    
    static func wrapResult(result: iTextResult, image: UIImage, rotate: Bool, degree: Int) -> Any {
        var map: [String: Any] = [:]
        
        map["barcodeText"] = result.barcodeText
        map["barcodeFormat"] = result.barcodeFormatString
        map["barcodeBytesBase64"] = result.barcodeBytes?.base64EncodedString()

        let points = result.localizationResult?.resultPoints as! [CGPoint]
        for i in 0...3{
            var point = points[i]
            if rotate {
                point = rotatedPoint(point, image: image, degree:degree)
            }
            map["x\(i+1)"] = point.x
            map["y\(i+1)"] = point.y
        }
        return map
    }
    
    static public func rotatedPoint(_ point:CGPoint, image: UIImage, degree: Int) -> CGPoint {
        var x = point.x
        var y = point.y
        switch (degree) {
            case 90:
                x = image.size.height - point.y
                y = point.x
            case 180:
                x = image.size.width - point.x;
                y = image.size.height - point.y;
            case 270:
                x = image.size.height - point.y;
                y = image.size.width - point.x;
            default:
                x = point.x
                y = point.y
        }
        return CGPoint(x: x, y: y)
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
