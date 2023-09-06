//
//  BarcodeReaderInitializer.swift
//  VisionCameraDynamsoftBarcodeReader
//
//  Created by xulihang on 2023/9/5.
//  Copyright © 2023 Facebook. All rights reserved.
//

import Foundation
import DynamsoftBarcodeReader

public class BarcodeReaderInitializer: NSObject, DBRLicenseVerificationListener {
    
    func initLicense(license:String) {
        DynamsoftBarcodeReader.initLicense(license, verificationDelegate: self)
    }
    
    public func dbrLicenseVerificationCallback(_ isSuccess: Bool, error: Error?) {
        let err = error as NSError?
        if(err != nil){
            print("Server DBR license verify failed")
        }
    }
}

