//
//  Scandit.swift
//  barcodesdkaggregator
//
//  Created by xulihang on 2021/11/25.
//

import Foundation
import ScanditCaptureCore
import ScanditBarcodeCapture


class Scandit:Reader{
    private var context:DataCaptureContext
    private var barcodeCapture:BarcodeCapture! = nil
    private var barcodeTracking:BarcodeTracking! = nil
    private var decodingResults:DecodingResults
    private var listener:Listener! = nil
    private var matrixListener:MatrixScanListener! = nil
    init(useMatrixScan:Bool){
        self.context = DataCaptureContext(licenseKey: "ASIwhi0vDCdJGQn1agvRXU1DDRo3BUe3S0sVxD13/BYXBkNA72YsMng6+2f+eR9vTy8IznMo8DLxUwxm2EaRwzJvPbjCJ0XM9RyxfihFfLBSZCD/Dlhe++ZdLK6sTumDiVkqxCQWtoARL/ErWiOqxBAMMf0DNgo2ou/WUHWggKo2Vrd5s54vbaIm/bxuFrIlvj4tbGcNU0xf/qUrsGIVuxvs0DDSTEberMW6eaaNECVMfDOSfV261hKpIVDA0vz9JWpGtm+WimcOHFtC2qyZCZPs2fGaWeA9v/I4sqpjmoz4FyGI/Ee14IW4quLZYdfReE8SrmwiubtoPh5P8/6ZdRUro9kQDeDZMRXCz8IB/RP+hoMFE+uICA378CYC9MHx8JR2aRycfTgSRkjNbteZoTjUWdZVLZ6WZZGM6xrqC4qVDPmr4If7z+oa1I8vVV0qgrTvBqkTiQSXpKJPjwr2amtqPjZm6uOQnM7FOSQSOSSTge53CgzhEqM3f7AJAi8Cs3FlWynX7nny/Zsoxj8dk4ty2TRO5xQlH+DmZP29qS9SmAPMkLOdMkjMQpi35kalq7aLGZ28kXDA+lbDi/y2TDGOYy90Mq1t0oLFGVaG0h15Q/2AuFULrZYrmIRjx4Rn65L/nyAWArjySCHGQgn3gbnK0hqkfUgwODjEnWBoteHyg2wzRhGGkLK+F4PArQEbGYlupjG31IiJusDaAHQvcsBOdBfhV7yibBr+kS9FrwpTK+nzt/SLHB5lbD3bfh9nW4F/lqUjLzXIDtk7pKsu8i86qlRcNh21x527Rgi/Tnjdw54ReHxPscZfLk+m7a5kUxX7XX3N")
       
        decodingResults = DecodingResults()
        if useMatrixScan {
            let settings = BarcodeTrackingSettings()
            settings.set(symbology: .dataMatrix, enabled: true)
            settings.set(symbology: .qr, enabled: true)
            matrixListener = MatrixScanListener(decodingResults: decodingResults)
            barcodeTracking = BarcodeTracking(context: context, settings: settings)
            barcodeTracking.addListener(matrixListener)
        }else{
            let settings = BarcodeCaptureSettings()
            settings.set(symbology: .dataMatrix, enabled: true)
            //settings.set(symbology: .code128, enabled: true)
            //settings.set(symbology: .code39, enabled: true)
            settings.set(symbology: .qr, enabled: true)
            //settings.set(symbology: .ean8, enabled: true)
            //settings.set(symbology: .upce, enabled: true)
            //settings.set(symbology: .ean13UPCA, enabled: true)
            listener = Listener(decodingResults: decodingResults)
            barcodeCapture = BarcodeCapture(context: context, settings: settings)
            barcodeCapture.addListener(listener)
        }
    }
    
    func decode(image: UIImage) async -> NSArray {
        decodingResults.complete = false
        let outResults = NSMutableArray()
        let image = ImageFrameSource.init(image: image)
        await context.setFrameSource(image)
        await image.switch(toDesiredState: FrameSourceState.on)
        var times = 0
        while decodingResults.complete == false {
            if times > 100 || image.currentState == FrameSourceState.off { // 10 seconds timeout or closed
                break
            }
            Thread.sleep(forTimeInterval: 0.1)
            times = times + 1
        }
        
        if decodingResults.complete == true {
            for barcode in decodingResults.recognizedBarcodes{
                let subDic = NSMutableDictionary()
                subDic.setObject(barcode.data ?? "", forKey: "barcodeText" as NSCopying)
                subDic.setObject(barcode.symbology.description, forKey: "barcodeFormat" as NSCopying)
                subDic.setObject(barcode.location.topLeft.x, forKey: "x1" as NSCopying)
                subDic.setObject(barcode.location.topLeft.y, forKey: "y1" as NSCopying)
                subDic.setObject(barcode.location.topRight.x, forKey: "x2" as NSCopying)
                subDic.setObject(barcode.location.topRight.y, forKey: "y2" as NSCopying)
                subDic.setObject(barcode.location.bottomRight.x, forKey: "x3" as NSCopying)
                subDic.setObject(barcode.location.bottomRight.y, forKey: "y3" as NSCopying)
                subDic.setObject(barcode.location.bottomLeft.x, forKey: "x4" as NSCopying)
                subDic.setObject(barcode.location.bottomLeft.y, forKey: "y4" as NSCopying)
                outResults.add(subDic)
            }
        }
        
        return outResults
    }
    
}

class Listener:NSObject, BarcodeCaptureListener {
    private var decodingResults:DecodingResults
    init(decodingResults:DecodingResults){
        self.decodingResults = decodingResults
    }
    
    func barcodeCapture(_ barcodeCapture: BarcodeCapture,
                   didScanIn session: BarcodeCaptureSession,
                   frameData: FrameData) {
        print("on recognized")
        decodingResults.complete = true
        decodingResults.recognizedBarcodes = session.newlyRecognizedBarcodes
    }
    
}

class MatrixScanListener: NSObject, BarcodeTrackingListener {
    private var decodingResults:DecodingResults
    init(decodingResults:DecodingResults){
        self.decodingResults = decodingResults
    }
    func barcodeTracking(_ barcodeTracking: BarcodeTracking,
                            didUpdate session: BarcodeTrackingSession,
                            frameData: FrameData) {
        let barcodes = session.trackedBarcodes.values.compactMap { $0.barcode }
        print(barcodes.count)
        decodingResults.complete = true
        decodingResults.recognizedBarcodes = barcodes
    }
}

class DecodingResults{
    public var recognizedBarcodes:[Barcode]! = nil
    public var complete:Bool = false
}
