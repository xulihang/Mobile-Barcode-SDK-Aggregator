//
//  AppleVision.swift
//  barcodesdkaggregator
//
//  Created by xulihang on 2021/11/23.
//

import Foundation
import Vision
import UIKit

class AppleVision:Reader{
    init(){
        
    }
    func decode(image: UIImage) async -> NSArray {
        //let imageRequestHandler = VNImageRequestHandler(cgImage: image.cgImage!)
        //let barcodeRequest = VNDetectBarcodesRequest { request, error in
        //    let barcodeObservations = request.results

        //    for barcode in barcodeObservations? {
        //        let barcode = result as? VNBarcodeObservation
        //    }
        //}
        let requestHandler = VNImageRequestHandler(cgImage: image.cgImage!)
        let barcodeRequest = VNDetectBarcodesRequest()
        barcodeRequest.symbologies = [.dataMatrix,.qr]
        do {
            try requestHandler.perform([barcodeRequest])
        } catch {
            print("Can't make the request due to \(error)")
        }
        let results = barcodeRequest.results
        
        print(results?.count ?? 0)
        let outResults = NSMutableArray()
        guard let results = results else {
            return outResults
          }
        for result in results{
            let subDic = NSMutableDictionary()
            subDic.setObject(result.payloadStringValue ?? "", forKey: "barcodeText" as NSCopying)
            subDic.setObject(result.symbology, forKey: "barcodeFormat" as NSCopying)
            subDic.setObject(result.topLeft.x, forKey: "x1" as NSCopying)
            subDic.setObject(result.topLeft.y, forKey: "y1" as NSCopying)
            subDic.setObject(result.topRight.x, forKey: "x2" as NSCopying)
            subDic.setObject(result.topRight.y, forKey: "y2" as NSCopying)
            subDic.setObject(result.bottomRight.x, forKey: "x3" as NSCopying)
            subDic.setObject(result.bottomRight.y, forKey: "y3" as NSCopying)
            subDic.setObject(result.bottomLeft.x, forKey: "x4" as NSCopying)
            subDic.setObject(result.bottomLeft.y, forKey: "y4" as NSCopying)
            outResults.add(subDic)
        }
        return outResults
    }
}
