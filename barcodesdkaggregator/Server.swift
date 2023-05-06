//
//  Server.swift
//  barcodesdkaggregator
//
//  Created by xulihang on 2021/11/24.
//

import Foundation
import GCDWebServer
import SwiftyJSON

class Server:ObservableObject{
    private var webServer:GCDWebServer
    private var barcodeReader:Aggregator! = nil
    @Published var currentImage:UIImage = UIImage(named: "DMX1a")!
    @Published var resultsString:String = ""
    init(){
        webServer = GCDWebServer()
        webServer.addDefaultHandler(forMethod: "GET", request: GCDWebServerRequest.self) { request in
            return GCDWebServerDataResponse(html:"<html><body><p>Hello World</p></body></html>")
        }
        webServer.addDefaultHandler(forMethod: "POST", request: GCDWebServerDataRequest.self, asyncProcessBlock: {request,completion  in
            DispatchQueue.main.async() {
                let get = request as! GCDWebServerDataRequest
                do{
                    let json = try JSON(data: get.data)
                    let sdk = json["sdk"].rawString() ?? "MLKit"
                    let template = json["sdk"].rawString() ?? ""
                    if template != "" {
                        if self.barcodeReader.name == Aggregator.dbr{
                            self.barcodeReader.updateDBRSettings(template: template)
                        }
                    }
                    if sdk != self.barcodeReader.name{
                        self.barcodeReader.switchSDK(name: sdk)
                    }
                    let imageBase64 = json["base64"]
                    print(self.barcodeReader.name)
                    let imageData = Data(base64Encoded: imageBase64.rawString() ?? "", options: .ignoreUnknownCharacters)
                    let image = UIImage(data: imageData!)!
                    self.currentImage = image.copy() as! UIImage
                    Task() {
                        do {
                            let startTime = Date.now.timeIntervalSince1970
                            let results = await self.barcodeReader.decode(image: image)
                            let endTime = Date.now.timeIntervalSince1970
                            
                            let elapsedTime = Int((endTime - startTime)*1000)
                            let dictionary = NSMutableDictionary()
                            dictionary["results"] = results
                            dictionary["elapsedTime"] = elapsedTime
                            let json2 = JSON(dictionary)
                            self.resultsString = json2.rawString(options: []) ?? ""
                            let response = GCDWebServerDataResponse(text:self.resultsString)
                            response?.setValue("*", forAdditionalHeader: "Access-Control-Allow-Origin")
                            response?.setValue("*", forAdditionalHeader: "Access-Control-Allow-Headers")
                            response?.setValue("*", forAdditionalHeader: "Access-Control-Allow-Methods")
                            completion(response)
                        }
                    }
                } catch{
                    print(error)
                    completion(GCDWebServerErrorResponse(text: error.localizedDescription))
                }
            }
        })
        webServer.start(withPort: 8888, bonjourName: "GCD Web Server")
    }
    
    func passBarcodeReader(barcodeReader:Aggregator){
        self.barcodeReader = barcodeReader
    }
    
    func getServerURL() -> String{
        return webServer.serverURL?.absoluteString ?? ""
    }
    
}
