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
    @State private var remoteImage : UIImage? = nil
    let placeholderOne = UIImage(named: "dynamsoft")
    @State var status = "Not connected."
    @State var json = ""
    @State private var selectedSDK = Aggregator.mlKit
    @State var currentImageURL = "http://192.168.8.65:5111/session/abc7b55641cf11eca240e84e068e29b8/image/QR1a.jpg"
    var body: some View {
        VStack{
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
            
            Button("Local Test"){
                Task  {
                    await buttonPressed()
                }
            }
            Text(status)
            Image(uiImage: remoteImage ?? placeholderOne!)
                .resizable()
                .aspectRatio((remoteImage ?? placeholderOne!).size, contentMode: .fit)
                .onAppear(perform: fetchRemoteImage)
            Text(json)
            
        }.frame(maxWidth: .infinity, // Full Screen Width
                maxHeight: .infinity, // Full Screen Height
                alignment: .topLeading) // Align To top
            .onAppear(perform: onViewLoaded)
        
    }
    
    func switchSDK(){
        barcodeReader.switchSDK(name: selectedSDK)
    }
    
    func onViewLoaded(){
        
    }
    
    func decode() async{
        
        let results:NSArray = await barcodeReader.decode(image: remoteImage!)
        print(results.count)
        if results.count>0{
            let result: NSDictionary = results[0] as! NSDictionary
            print(result["barcodeText"] ?? "")
            let json = JSON(results)

            let representation = json.rawString(options: [])
            print(representation!)
            self.json = representation ?? ""
        }
    }
    
    func buttonPressed() async{
        print("pressed")
        self.status="Connected"
        self.currentImageURL="http://192.168.8.65:5111/session/658840b94c2a11ecba69e84e068e29b8/image/DMX2a.jpg"
        fetchRemoteImage()
        await decode()
    }
    
    func fetchRemoteImage(){
        let url = URL(string: self.currentImageURL)
        let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
        self.remoteImage = UIImage(data: data!)
    }
    
    func fetchRemoteImageAsync()
    {
        guard let url = URL(string: self.currentImageURL) else { return }
        URLSession.shared.dataTask(with: url){ (data, response, error) in
            if let image = UIImage(data: data!){
                self.remoteImage = image
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

