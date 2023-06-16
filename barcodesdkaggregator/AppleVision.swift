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
        
        //let requestHandler = VNImageRequestHandler(cgImage: image.cgImage!, orientation: CGImagePropertyOrientationForUIImageOrientation(uiOrientation: image.imageOrientation))
        let requestHandler = VNImageRequestHandler(cgImage: image.cgImage!, orientation: CGImagePropertyOrientation.downMirrored)
        let barcodeRequest = VNDetectBarcodesRequest()
        barcodeRequest.symbologies = [.pdf417]
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
        let width = image.size.width
        let height = image.size.height
        for result in results{
            let subDic = NSMutableDictionary()
            
            let minY = result.boundingBox.minY * height
            let minX = result.boundingBox.minX * width
            let maxY = result.boundingBox.maxY * height
            let maxX = result.boundingBox.maxX * width
            subDic.setObject(result.payloadStringValue ?? "", forKey: "barcodeText" as NSCopying)
            subDic.setObject(result.symbology, forKey: "barcodeFormat" as NSCopying)
            subDic.setObject("", forKey: "barcodeBytes" as NSCopying) //https://developer.apple.com/documentation/vision/vnbarcodeobservation/4183553-payloaddata?language=objc only available on macOS 14.0, iOS 17.0
            subDic.setObject(minX, forKey: "x1" as NSCopying)
            subDic.setObject(minY, forKey: "y1" as NSCopying)
            subDic.setObject(maxX, forKey: "x2" as NSCopying)
            subDic.setObject(minY, forKey: "y2" as NSCopying)
            subDic.setObject(maxX, forKey: "x3" as NSCopying)
            subDic.setObject(maxY, forKey: "y3" as NSCopying)
            subDic.setObject(minX, forKey: "x4" as NSCopying)
            subDic.setObject(maxY, forKey: "y4" as NSCopying)
            outResults.add(subDic)
        }
        return outResults
    }
    
    func CGImagePropertyOrientationForUIImageOrientation(uiOrientation:UIImage.Orientation) -> CGImagePropertyOrientation {
        switch (uiOrientation) {
            case UIImage.Orientation.up: return CGImagePropertyOrientation.up;
            case UIImage.Orientation.down: return CGImagePropertyOrientation.down;
            case UIImage.Orientation.left: return CGImagePropertyOrientation.left;
            case UIImage.Orientation.right: return CGImagePropertyOrientation.right;
            case UIImage.Orientation.upMirrored: return CGImagePropertyOrientation.upMirrored;
            case UIImage.Orientation.downMirrored: return CGImagePropertyOrientation.downMirrored;
            case UIImage.Orientation.leftMirrored: return CGImagePropertyOrientation.leftMirrored;
            case UIImage.Orientation.rightMirrored: return CGImagePropertyOrientation.rightMirrored;
        @unknown default:
            return CGImagePropertyOrientation.up
        }
    }
}
