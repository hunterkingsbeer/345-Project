//
//  ScanView.swift
//  COSC345-Project
//
//  Created by Hunter Kingsbeer on 4/08/21.
//

import SwiftUI


enum ScanSelection {
    case none
    case camera
    case gallery
}

// TODO: when adding multiple images the doc scanner will duplicate previous images in the respective scan
    // e.g. Scanning receipt 1 & 2. Saving them results in Receipt 1 saved, then receipt 1 (dupe) and receipt 2 saved.
struct ScanView: View {
    @EnvironmentObject var settings: UserSettings
    let inSimulator: Bool = UIDevice.current.isSimulator
    
    @State var scanSelection: ScanSelection = .none
    @State var isRecognizing: Bool = false
    @State var isConfirming: Bool = false
    @State var invalidAlert: Bool = false
    @ObservedObject var recognizedContent: RecognizedContent  = RecognizedContent()
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            VStack{
                TitleText(title: "scan")
                    .padding(.horizontal)
                
                if !isRecognizing {
                    // default "gallery or camera" screen
                    if scanSelection == .none {
                        ScannerSelectView(scanSelection: $scanSelection)
                            .transition(.scale(scale: 0.8).combined(with: .opacity).combined(with: .move(edge: .bottom)))
                        
                    } else if scanSelection == .gallery { // scan via gallery
                        ImagePicker { result in
                            switch result {
                                case .success(let scannedImages):
                                    isRecognizing = true
                                    print(recognizedContent.items.count)
                                    TextRecognition(scannedImages: scannedImages, recognizedContent: recognizedContent) {
                                        if saveReceipt(){ // if save receipt returns true (valid scan), exit the scanner
                                            scanSelection = .none
                                        } else { // else stay in the scanner and alert them to scan again
                                            invalidAlert = true
                                        }
                                        isRecognizing = false // Text recognition is finished, hide the progress indicator.
                                    }.recognizeText()
                                case .failure(let error):
                                    print(error.localizedDescription)
                            }
                        } didCancelScanning: {
                            // Dismiss the scanner
                            scanSelection = .none
                        }.alert(isPresented: $invalidAlert) {
                            Alert(
                                title: Text("Receipt Not Saved!"),
                                message: Text("This image is not valid. Try again."),
                                dismissButton: .default(Text("Okay"))
                            )
                        }
                        
                    } else if scanSelection == .camera { // scan via camera
                        if !UIDevice.current.isSimulator { // if device is physical (supports camera)
                            VStack {
                                DocumentScanner { result in
                                    switch result {
                                        case .success(let scannedImages):
                                            isRecognizing = true
                                            print(recognizedContent.items.count)
                                            TextRecognition(scannedImages: scannedImages, recognizedContent: recognizedContent) {
                                                if saveReceipt(){ // if save receipt returns true (valid scan), exit the scanner
                                                    scanSelection = .none
                                                } else { // else stay in the scanner and alert them to scan again
                                                    invalidAlert = true
                                                }
                                                isRecognizing = false // Text recognition is finished, hide the progress indicator.
                                            }.recognizeText()
                                        case .failure(let error):
                                            print(error.localizedDescription)
                                    }
                                } didCancelScanning: {
                                    // Dismiss the scanner
                                    scanSelection = .none
                                }.alert(isPresented: $invalidAlert) {
                                    Alert(
                                        title: Text("Receipt Not Saved!"),
                                        message: Text("This image is not valid. Try again."),
                                        dismissButton: .default(Text("Okay"))
                                    )
                                }
                            }
                        } else { // else if its in the simulator (no camera)
                            Text("Camera not supported in the simulator!\n\nPlease use a physical device.")
                                .font(.system(.title, design: .rounded))
                                .padding()
                            Button(action: {
                                scanSelection = .none
                            }){
                                Text("BACK")
                                    .padding().padding(.horizontal)
                                    .background(RoundedRectangle(cornerRadius: 25).fill(Color("object")))
                                    .padding()
                            }.buttonStyle(ShrinkingButton())
                            Spacer()
                        }                    }
                } else {
                    Spacer()
                    Text("Saving...")
                        .font(.system(.title, design: .rounded))
                    ProgressView()
                        .font(.largeTitle)
                        .progressViewStyle(CircularProgressViewStyle(tint: Color("text")))
                        .padding(.bottom, 20)
                    Spacer()
                }
            }.animation(.spring())
        }
    }
    
    func saveReceipt() -> Bool{
        if recognizedContent.items.count > 0 {
            for receipt in recognizedContent.items {
                if receipt.text.count < 2 {
                    return false
                } else {
                    Receipt.saveScan(recognizedText: receipt.text)
                    return true
                }
            }
            scanSelection = .none
        }
        return false
    }
}

struct ScannerSelectView: View {
    @Binding var scanSelection: ScanSelection
    
    var body: some View {
        VStack {
            Spacer()
            Button(action: {
                scanSelection = scanSelection == .gallery ? .none : .gallery
            }){
                VStack {
                    if scanSelection == .none {
                        Image(systemName: "photo.fill")
                            .font(.system(.largeTitle, design: .rounded))
                            .padding()
                        Text("Add from Gallery")
                            .font(.system(.title, design: .rounded))
                    }
                }.contentShape(Rectangle())
            }.buttonStyle(ShrinkingButton())
            
            Spacer()
            Divider()
            Spacer()
            
            Button(action:{
                scanSelection = scanSelection == .camera ? .none : .camera
            }){
                VStack {
                    if scanSelection == .none {
                        Text("Add from Camera")
                            .font(.system(.title, design: .rounded))
                        Image(systemName: "camera.fill")
                            .font(.system(.largeTitle, design: .rounded))
                            .padding()
                            .transition(.opacity)
                    }
                }.contentShape(Rectangle())
            }.buttonStyle(ShrinkingButton())
            Spacer()
        }
    }
}

struct ConfirmationView: View {
    @ObservedObject var recognizedContent: RecognizedContent = RecognizedContent()
    
    var body: some View {
        VStack {
            TitleText(title: "Confirm")
            ScrollView(showsIndicators: false) {
                //ForEach(recognizedContent.items){ receipt in
                    VStack (alignment: .leading){
                        Text("Title")
                            .font(.system(.title))
                        Text("15/10/2021")
                            .font(.caption)
                        Divider()
                        Text("body text body text body text body text body text body text body text body text body text body text body text body text body text body text body text body text body text body text body text body text body text body text body text body text body text body text body text body text body text body text body text body text body text body text body text body text body text body text body text body text body text body text body text body text body text body text body text body text body text ")
                    }.padding()
                    .background(Color("object")).cornerRadius(15)
                    .padding()
                    .frame(width: UIScreen.screenWidth * 0.85)
                //}
            }
            HStack {
                let buttonHeight = UIScreen.screenHeight * 0.06
                Button(action:{
                    // cancel scan
                }){
                    RoundedRectangle(cornerRadius: 15)
                        .foregroundColor(Color("object"))
                        .frame(height: buttonHeight)
                        .overlay(Image(systemName: "xmark"))
                }.buttonStyle(ShrinkingButton())
                
                Button(action:{
                    // view image of scan
                }){
                    RoundedRectangle(cornerRadius: 15)
                        .foregroundColor(Color("object"))
                        .frame(height: buttonHeight)
                        .overlay(Image(systemName: "photo"))
                }.buttonStyle(ShrinkingButton())
                
                Button(action:{
                    // edit scan
                }){
                    RoundedRectangle(cornerRadius: 15)
                        .foregroundColor(Color("object"))
                        .frame(height: buttonHeight)
                        .overlay(Image(systemName: "pencil"))
                }.buttonStyle(ShrinkingButton())
                
                Button(action:{
                    // confirm scan
                }){
                    RoundedRectangle(cornerRadius: 15)
                        .foregroundColor(Color("object"))
                        .frame(height: buttonHeight)
                        .overlay(Image(systemName: "checkmark"))
                }.buttonStyle(ShrinkingButton())
            }
        }.padding(.horizontal)
    }
}
