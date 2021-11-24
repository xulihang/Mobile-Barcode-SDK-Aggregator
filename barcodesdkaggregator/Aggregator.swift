//
//  Aggregator.swift
//  barcodesdkaggregator
//
//  Created by xulihang on 2021/11/23.
//

import Foundation
import UIKit

class Aggregator {
    private var barcodeReader:Reader? = nil
    init(name:String) {
        if name == "DBR"{
            barcodeReader = DBR()
        }else if name == "MLKit" {
            barcodeReader = MLKit()
        }else if name == "AppleVision" {
            barcodeReader = AppleVision()
        }
    }
    
    func decode(image:UIImage) async ->NSArray{
        return await barcodeReader!.decode(image:image)
    }
}
