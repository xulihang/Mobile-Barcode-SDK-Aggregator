//
//  DBRLicenseInitializer.swift
//  barcodesdkaggregator
//
//  Created by xulihang on 2023/6/15.
//

import Foundation
import DynamsoftBarcodeReader

public class DBRLicenseInitializer: NSObject, DBRLicenseVerificationListener {
    
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
