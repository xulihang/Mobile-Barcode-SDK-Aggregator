//
//  ContentView.swift
//  barcodesdkaggregator
//
//  Created by xulihang on 2021/11/23.
//

import SwiftUI
import DynamsoftBarcodeReader
import SwiftyJSON

struct ContentView: View {
    @State private var remoteImage : UIImage? = nil
    let placeholderOne = UIImage(named: "dynamsoft")
    @State var status = "Not connected."
    @State var ip: String = "192.168.8.65"
    @State var currentImageURL = "http://192.168.8.65:5111/session/abc7b55641cf11eca240e84e068e29b8/image/QR1a.jpg"
    var body: some View {
        VStack{
            HStack(alignment: .center) {
                Text("Server IP:")
                TextField("IP address", text: $ip)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }.padding()
            Button("Connect"){
                Task  {
                    await buttonPressed()
                }
            }
            Text(status)
            Image(uiImage: remoteImage ?? placeholderOne!)
                .onAppear(perform: fetchRemoteImage)
            
        }.frame(maxWidth: .infinity, // Full Screen Width
                maxHeight: .infinity, // Full Screen Height
                alignment: .top) // Align To top
        
    }
    
    func decode() async{
        let barcodeReader = Aggregator(name: "MLKit")
        let results:NSArray = await barcodeReader.decode(image: remoteImage!)
        print(results.count)
        if results.count>0{
            let result: NSDictionary = results[0] as! NSDictionary
            print(result["barcodeText"] ?? "")
            let json = JSON(results)
            let representation = json.rawString()
            print(representation!)
        }
    }
    
    func buttonPressed() async{
        print("pressed")
        self.status="Connected"
        //self.currentImageURL="http://192.168.8.65:5111/session/658840b94c2a11ecba69e84e068e29b8/image/DMX2a.jpg"
        //fetchRemoteImage()
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

