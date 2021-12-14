//
//  Aggregator.swift
//  barcodesdkaggregator
//
//  Created by xulihang on 2021/11/23.
//

import Foundation
import UIKit

class Aggregator:ObservableObject {
    private var barcodeReader:Reader? = nil
    public var name:String = ""
    public static let dbr:String = "DBR"
    public static let mlKit:String = "MLKit"
    public static let appleVision:String = "AppleVision"
    public static let scandit:String = "Scandit"
    public static let zxing:String = "ZXing"
    init(name:String) {
        switchSDK(name: name)
    }
    
    func switchSDK(name:String){
        if name == Aggregator.dbr{
            barcodeReader = DBR()
        }else if name == Aggregator.mlKit {
            barcodeReader = MLKit()
        }else if name == Aggregator.appleVision {
            barcodeReader = AppleVision()
        }else if name == Aggregator.scandit {
            barcodeReader = Scandit(useMatrixScan: true)
        }else if name == Aggregator.zxing {
            barcodeReader = ZXing()
        }
        self.name = name
    }
    
    func updateDBRSettings(template:String){
        let reader:DBR = barcodeReader as! DBR
        reader.updateRuntimeSettingsWithTemplate(template: template)
    }
    
    func decode(image:UIImage) async ->NSArray{
        return await barcodeReader!.decode(image:image)
    }
}
