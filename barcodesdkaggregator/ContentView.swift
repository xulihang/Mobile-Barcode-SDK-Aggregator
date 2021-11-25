//
//  ContentView.swift
//  barcodesdkaggregator
//
//  Created by xulihang on 2021/11/23.
//

import SwiftUI
import SwiftyJSON

struct ContentView: View {
    @ObservedObject private var barcodeReader:Aggregator = Aggregator(name: "MLKit")
    @ObservedObject private var webServer:Server = Server()
    @State var status = "Not connected."
    @State private var selectedSDK = Aggregator.mlKit
    @State var currentImageURL = "http://192.168.8.65:5111/session/abc7b55641cf11eca240e84e068e29b8/image/QR1a.jpg"
    @State private var showAlert = false
    var body: some View {
        Spacer()
        VStack{
            Text(status)
            HStack{
                Text("Selected SDK: ")
                Picker("SDK", selection: $selectedSDK) {
                    Text("DBR").tag(Aggregator.dbr)
                    Text("Apple Vision").tag(Aggregator.appleVision)
                    Text("MLKit").tag(Aggregator.mlKit)
                }.onChange(of: selectedSDK) { newValue in
                    switchSDK()
                }
            }

            TextField("Image URL", text: $currentImageURL).textFieldStyle(.roundedBorder)
            HStack{
                Button(action: fetchRemoteImage) {
                    Text("Fetch")
                }
                Button("Local Test"){
                    Task  {
                        await decode()
                    }
                }.alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("No barcodes found"),
                        message: Text("Try to decode with another SDK.")
                    )
                }
            }
            
            
            Image(uiImage: webServer.currentImage)
                .resizable()
                .aspectRatio((webServer.currentImage).size, contentMode: .fit)
                .onAppear(perform: fetchRemoteImage)
            ScrollView(.vertical) {
                Text(webServer.resultsString)
            }
            
            
        }.frame(maxWidth: .infinity, // Full Screen Width
                maxHeight: .infinity, // Full Screen Height
                alignment: .topLeading) // Align To top
            .onAppear(perform: onViewLoaded)
        
    }
    
    func switchSDK(){
        barcodeReader.switchSDK(name: selectedSDK)
    }
    
    func onViewLoaded(){
        webServer.passBarcodeReader(barcodeReader: barcodeReader)
        status = "Started at: "+webServer.getServerURL()
    }
    
    func decode() async{
        let startTime = Date.now.timeIntervalSince1970
        let results:NSArray = await barcodeReader.decode(image: webServer.currentImage)
        let endTime = Date.now.timeIntervalSince1970
        if results.count>0{
            //let result: NSDictionary = results[0] as! NSDictionary
            //print(result["barcodeText"]
            let elapsedTime = Int((endTime - startTime)*1000)
            let dictionary = NSMutableDictionary()
            dictionary["results"] = results
            dictionary["elapsedTime"] = elapsedTime
            let json = JSON(dictionary)
            let representation = json.rawString(options: [])
            DispatchQueue.main.async {
                webServer.resultsString = representation ?? ""
            }
        }else{
            showAlert = true
        }
    }
    
    func fetchRemoteImage(){
        let url = URL(string: self.currentImageURL)
        let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
        DispatchQueue.main.async {
            webServer.currentImage = UIImage(data: data!)!
        }
    }
    
    func fetchRemoteImageAsync()
    {
        guard let url = URL(string: self.currentImageURL) else { return }
        URLSession.shared.dataTask(with: url){ (data, response, error) in
            if let image = UIImage(data: data!){
                webServer.currentImage = image
            }
            else{
                print(error ?? "")
            }
        }.resume()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

