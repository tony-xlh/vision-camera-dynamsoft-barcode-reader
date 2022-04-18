//
//  BarcodeScanner.swift
//  vision-camera-dynamsoft-barcode-reader
//
//  Created by xulihang on 2022/4/17.
//

import Foundation
import DynamsoftBarcodeReader

public class BarcodeReaderInitializer: NSObject, DBRLicenseVerificationListener {
    
    func configurationDBR(license:String) -> DynamsoftBarcodeReader {
        var dbr:DynamsoftBarcodeReader
        DynamsoftBarcodeReader.initLicense(license, verificationDelegate: self)
        dbr = DynamsoftBarcodeReader.init()
        return dbr
    }
    
    public func dbrLicenseVerificationCallback(_ isSuccess: Bool, error: Error?) {
        let err = error as NSError?
        if(err != nil){
            print("Server DBR license verify failed")
        }
    }
}

