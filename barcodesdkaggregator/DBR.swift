//
//  DBR.swift
//  barcodesdkaggregator
//
//  Created by xulihang on 2021/11/23.
//

import Foundation
import DynamsoftBarcodeReader

class DBR:Reader {
    private var barcodeReader: DynamsoftBarcodeReader! = nil
    init() {
        barcodeReader = DynamsoftBarcodeReader.init(license: "t0068NQAAAABqtDczOvXnHchYhEDwihE9AlhgUoufsIS8/fvgiSB9oU4x8Q4zTN47N7ksSXWCH8bfFREbMklPNnt39BdcfSo=")
    }
    
    func decode(image:UIImage) async ->NSArray{
        let outResults = NSMutableArray()
        do{
            let results = try barcodeReader.decode(image, withTemplate: "")
            print(results.count)
            for result in results {
                let points = result.localizationResult?.resultPoints as! [CGPoint]
                let subDic = NSMutableDictionary()
                subDic.setObject(result.barcodeText ?? "", forKey: "barcodeText" as NSCopying)
                subDic.setObject(result.barcodeFormatString ?? "", forKey: "barcodeFormat" as NSCopying)
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
}
