//
//  ZXing.swift
//  barcodesdkaggregator
//
//  Created by xulihang on 2021/12/13.
//

import Foundation
import ZXingObjC

class ZXing:Reader{
    var reader: ZXPDF417Reader
    init(){
        reader = ZXPDF417Reader()
    }
    func decode(image: UIImage) async -> NSArray {
        let outResults = NSMutableArray()
        let imageToDecode = image.cgImage  // Given a CGImage in which we are looking for barcodes
        let source:ZXCGImageLuminanceSource = ZXCGImageLuminanceSource.init(cgImage: imageToDecode)
        let bitmap:ZXBinaryBitmap = ZXBinaryBitmap.binaryBitmap(with: ZXHybridBinarizer.init(source: source)) as! ZXBinaryBitmap
        
        // There are a number of hints we can give to the reader, including
        // possible formats, allowed lengths, and the string encoding.
        let hints:ZXDecodeHints = ZXDecodeHints.hints() as! ZXDecodeHints
        hints.tryHarder = true
        do{
            let results = try reader.decodeMultiple(bitmap, hints: hints)
            if results.count > 0 {
                for result in results {
                    let _result:ZXResult = result as! ZXResult
                    let points = _result.resultPoints
                    let subDic = NSMutableDictionary()
                    subDic.setObject(_result.text ?? "", forKey: "barcodeText" as NSCopying)
                    subDic.setObject(_result.barcodeFormat.rawValue, forKey: "barcodeFormat" as NSCopying)
                    addBoundingBox(subDic: subDic, resultPoints: points as! [ZXResultPoint])
                    outResults.add(subDic)
                }
            }
        } catch{
            print(error)
        }
        return outResults
    }
    
    func addBoundingBox(subDic:NSMutableDictionary,resultPoints:[ZXResultPoint]){
        var minX = Int(resultPoints[0].x)
        var minY = Int(resultPoints[0].y)
        var maxX = 0
        var maxY = 0
        for point in resultPoints {
            minX = min(minX, Int(point.x))
            minY = min(minY, Int(point.y))
            maxX = max(maxX, Int(point.x))
            maxY = max(maxX, Int(point.x))
        }
        subDic.setObject(minX, forKey: "x1" as NSCopying)
        subDic.setObject(minY, forKey: "y1" as NSCopying)
        subDic.setObject(maxX, forKey: "x2" as NSCopying)
        subDic.setObject(minY, forKey: "y2" as NSCopying)
        subDic.setObject(maxX, forKey: "x3" as NSCopying)
        subDic.setObject(maxY, forKey: "y3" as NSCopying)
        subDic.setObject(minX, forKey: "x4" as NSCopying)
        subDic.setObject(maxY, forKey: "y4" as NSCopying)
    }
}
