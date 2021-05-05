//
//  ContentView.swift
//  COSC345
//
//  Created by Hunter Kingsbeer on 18/04/21.
//

import SwiftUI
import CoreData
import VisionKit

class Global: ObservableObject {
    //some test names
    @Published var receipts = ["Countdown", "Noel Leeming", "Harvey Norman", "Countdown", "Pak n' Save"]
}

struct ContentView: View {
    @State var scanToggle = false
    @State var scannedText = ""
    
    @ObservedObject var global = Global()

    var body: some View {
        ZStack {
            Color("background").edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    Text("Receipt App.")
                        .font(.system(.body, design: .rounded)).bold()
                    Spacer()
                }
                
                VStack {
                    ScrollView(showsIndicators: false){
                        ForEach(0..<global.receipts.count){ index in
                            ReceiptView(scannedText: $scannedText, index: index)
                        }.padding(.bottom, 85)
                    }.cornerRadius(30)
                }.padding(.top, 0)

                Spacer()
            }.padding().padding(.horizontal)
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        scanToggle = true
                    }){
                        Circle()
                            .frame(width: 70, height: 70).foregroundColor(Color("accentGray"))
                            .overlay(
                                Image(systemName: "camera")
                                    .font(.system(size: 30, weight: .bold))
                            )
                    }.buttonStyle(PlainButtonStyle())
                }
            }.padding()
            
            if scanToggle {
                ScanDocumentView(recognizedText: self.$scannedText, scanToggle: self.$scanToggle)
                    .cornerRadius(35)
            }
        }
    }
}

struct ReceiptView: View {
    @Binding var scannedText : String
    var index : Int
    
    @ObservedObject var global = Global()
    @State var detailView = false
    
    var body: some View {
        Button(action: {
            detailView.toggle()
        }){
            Color(.white)
                .frame(height: detailView ? 800 : 400)
                .cornerRadius(30)
                .overlay(
                    VStack(alignment: .leading){
                        HStack {
                            Text("Receipt \(index+1)")
                                .font(.system(.title, design: .rounded)).bold()
                            Spacer()
                        }
                        Text("\(global.receipts[index])")
                        Text(scannedText).font(.system(size: 10))
                        Spacer()
                    }.foregroundColor(.black)
                    .padding().frame(height: detailView ? 800 : 400)
                )
        }.buttonStyle(PlainButtonStyle()).animation(.spring())
    }
}

extension UIScreen{
   static let screenWidth = UIScreen.main.bounds.size.width
   static let screenHeight = UIScreen.main.bounds.size.height
   static let screenSize = UIScreen.main.bounds.size
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
