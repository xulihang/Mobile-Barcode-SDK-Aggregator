//
//  MLKit.swift
//  barcodesdkaggregator
//
//  Created by xulihang on 2021/11/23.
//

import Foundation
import UIKit
import MLKitBarcodeScanning
import MLKitVision

class MLKit:Reader{
    var barcodeScanner: BarcodeScanner
    init(){
        let format = MLKitBarcodeScanning.BarcodeFormat.PDF417
        let barcodeOptions = BarcodeScannerOptions(formats: format)
        barcodeScanner = BarcodeScanner.barcodeScanner(options: barcodeOptions)
    }
    
    func decode(image:UIImage) async -> NSArray{
        let outResults = NSMutableArray()
        let visionImage = VisionImage(image: image)
        visionImage.orientation = image.imageOrientation
        do{
            let barcodes = try await barcodeScanner.process(visionImage)
            for barcode:Barcode in barcodes{
                let subDic = NSMutableDictionary()
                let points = barcode.cornerPoints
                subDic.setObject(barcode.displayValue ?? "", forKey: "barcodeText" as NSCopying)
                subDic.setObject(getFormatName(rawValue: barcode.format.rawValue), forKey: "barcodeFormat" as NSCopying)
                subDic.setObject(Int(points?[0].cgPointValue.x ?? 0), forKey: "x1" as NSCopying)
                subDic.setObject(Int(points?[0].cgPointValue.y ?? 0), forKey: "y1" as NSCopying)
                subDic.setObject(Int(points?[1].cgPointValue.x ?? 0), forKey: "x2" as NSCopying)
                subDic.setObject(Int(points?[1].cgPointValue.y ?? 0), forKey: "y2" as NSCopying)
                subDic.setObject(Int(points?[2].cgPointValue.x ?? 0), forKey: "x3" as NSCopying)
                subDic.setObject(Int(points?[2].cgPointValue.y ?? 0), forKey: "y3" as NSCopying)
                subDic.setObject(Int(points?[3].cgPointValue.x ?? 0), forKey: "x4" as NSCopying)
                subDic.setObject(Int(points?[3].cgPointValue.y ?? 0), forKey: "y4" as NSCopying)
                outResults.add(subDic)
            }
        }catch{
            print(error)
        }
       
        return outResults
    }
    
    func getFormatName(rawValue:Int)->String{
        var format = ""
        if rawValue == BarcodeFormat.dataMatrix.rawValue {
            format = "DataMatrix"
        } else if rawValue == BarcodeFormat.qrCode.rawValue {
            format = "QRCODE"
        } else if rawValue == BarcodeFormat.EAN13.rawValue {
            format = "EAN13"
        } else if rawValue == BarcodeFormat.PDF417.rawValue {
            format = "PDF417"
        }
        return format
                
    }
    
}
