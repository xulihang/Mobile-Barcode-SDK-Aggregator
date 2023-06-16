//
//  DBR.swift
//  barcodesdkaggregator
//
//  Created by xulihang on 2021/11/23.
//

import Foundation
import DynamsoftBarcodeReader

class DBR:Reader  {
    private var barcodeReader: DynamsoftBarcodeReader! = nil
    private var template: String = ""
    init() {
        let initializer = DBRLicenseInitializer()
        initializer.initLicense(license: "DLS2eyJoYW5kc2hha2VDb2RlIjoiMTAwMjI3NzYzLVRYbE5iMkpwYkdWUWNtOXFYMlJpY2ciLCJtYWluU2VydmVyVVJMIjoiaHR0cHM6Ly9tbHRzLmR5bmFtc29mdC5jb20iLCJvcmdhbml6YXRpb25JRCI6IjEwMDIyNzc2MyIsImNoZWNrQ29kZSI6MTcyNTc5NTA5OX0=")
        barcodeReader = DynamsoftBarcodeReader()
        let settings = try? barcodeReader.getRuntimeSettings()
        settings!.expectedBarcodesCount = 999
        settings!.scaleDownThreshold = 9999
        settings!.barcodeFormatIds = EnumBarcodeFormat.PDF417.rawValue
        try? barcodeReader.updateRuntimeSettings(settings!)
        print("updated")
    }
    
    public func dbrLicenseVerificationCallback(_ isSuccess: Bool, error: Error?) {
        let err = error as NSError?
        if(err != nil){
            print("Server DBR license verify failed")
        }
    }
    
    func decode(image:UIImage) async ->NSArray{
        let outResults = NSMutableArray()
        do{
            let results = try barcodeReader.decodeImage(image)
            print(results.count)
            for result in results {
                let points = result.localizationResult?.resultPoints as! [CGPoint]
                let subDic = NSMutableDictionary()
                subDic.setObject(result.barcodeText ?? "", forKey: "barcodeText" as NSCopying)
                subDic.setObject(result.barcodeFormatString ?? "", forKey: "barcodeFormat" as NSCopying)
                subDic.setObject(result.barcodeBytes?.base64EncodedString() ?? "", forKey: "barcodeBytes" as NSCopying)
                subDic.setObject(Int(points[0].x), forKey: "x1" as NSCopying)
                subDic.setObject(Int(points[0].y), forKey: "y1" as NSCopying)
                subDic.setObject(Int(points[1].x), forKey: "x2" as NSCopying)
                subDic.setObject(Int(points[1].y), forKey: "y2" as NSCopying)
                subDic.setObject(Int(points[2].x), forKey: "x3" as NSCopying)
                subDic.setObject(Int(points[2].y), forKey: "y3" as NSCopying)
                subDic.setObject(Int(points[3].x), forKey: "x4" as NSCopying)
                subDic.setObject(Int(points[3].y), forKey: "y4" as NSCopying)
                outResults.add(subDic)
            }
            
        }catch{
            print(error)
        }
        return outResults
    }
    
    func updateRuntimeSettingsWithTemplate(template:String){
        if template != self.template{
            print("template")
            print(template)
            self.template = template
            try? barcodeReader.initRuntimeSettingsWithString(template, conflictMode: EnumConflictMode.overwrite)
            print(template)
        }
    }
}
