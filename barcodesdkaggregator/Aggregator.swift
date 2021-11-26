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
    init(name:String) {
        switchSDK(name: name)
    }
    
    func switchSDK(name:String){
        if name == "DBR"{
            barcodeReader = DBR()
        }else if name == "MLKit" {
            barcodeReader = MLKit()
        }else if name == "AppleVision" {
            barcodeReader = AppleVision()
        }else if name == "Scandit" {
            barcodeReader = Scandit(useMatrixScan: true)
        }
        self.name = name
    }
    
    func decode(image:UIImage) async ->NSArray{
        return await barcodeReader!.decode(image:image)
    }
}
