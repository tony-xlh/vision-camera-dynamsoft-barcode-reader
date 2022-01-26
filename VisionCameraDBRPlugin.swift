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
    static var barcodeReader:DynamsoftBarcodeReader! = nil
    @objc
    public static func callback(_ frame: Frame!, withArgs args: [Any]!) -> Any! {
        if barcodeReader == nil {
            configurationDBR(withArgs:args)
        }
        let image:UIImage = sampleBufferToImage(sampleBuffer: frame.buffer)
        
        // code goes here
        let results = try? barcodeReader.decode(image, withTemplate: "")
        let count = results?.count ?? 0
        if count > 0 {
            print("Found barcodes")
        }
        return []
    }
    
    static func configurationDBR(withArgs args: [Any]!) {
        var license = "";
        var organizationID = "200001";
        let dls = iDMDLSConnectionParameters()
        if (license != ""){
           barcodeReader = DynamsoftBarcodeReader(license: license)
        }else{
           dls.organizationID = organizationID
           barcodeReader = DynamsoftBarcodeReader(licenseFromDLS: dls, verificationDelegate: self)
        }
     }
    // CMSampleBuffer -> UIImage
    static func sampleBufferToImage(sampleBuffer: CMSampleBuffer) -> UIImage {
        let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)! as CVPixelBuffer

        CVPixelBufferLockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0))

        let baseAddress = CVPixelBufferGetBaseAddress(imageBuffer)
        
        let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer)

        let width = CVPixelBufferGetWidth(imageBuffer)
        let height = CVPixelBufferGetHeight(imageBuffer)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let context = CGContext(data: baseAddress, width: width, height: height, bitsPerComponent: 8,
                                bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue)

        let quartzImage:CGImage = context!.makeImage()!

        CVPixelBufferUnlockBaseAddress(imageBuffer,CVPixelBufferLockFlags(rawValue: 0))
        
        let image = UIImage(cgImage: quartzImage)
        return image
    }

}
