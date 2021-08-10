//
//  Scanners.swift
//  COSC345-Project
//
//  Created by Hunter Kingsbeer on 4/08/21.
//

import UIKit
import SwiftUI
import VisionKit
import Vision

class RecognizedContent: ObservableObject {
    @Published var items = [ReceiptItem]()
    @Published var images = [UIImage]()
}

class ReceiptItem: Identifiable {
    var id: UUID = UUID()
    var text: String = ""
    var image: UIImage = UIImage()
}

enum ScanSelection {
    case none
    case camera
    case gallery
}

// TODO: when adding multiple images the doc scanner will duplicate previous images in the respective scan
    // e.g. Scanning receipt 1 & 2. Saving them results in Receipt 1 saved, then receipt 1 (dupe) and receipt 2 saved.

/// Parent View for the scanners.
/// Controls the background, and visibility of the gallery, document camera, and selection screen used in scanning receipts.
struct ScanView: View {
    @EnvironmentObject var settings: UserSettings
    let inSimulator: Bool = UIDevice.current.isSimulator
    
    @State var scanSelection: ScanSelection = .none
    @State var isRecognizing: Bool = false
    @State var isConfirming: Bool = false
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            VStack {
                TitleText(title: "scan")
                    .padding(.horizontal)
                
                if !isRecognizing {
                    if scanSelection == .gallery { // scan via gallery
                        GalleryScannerView(scanSelection: $scanSelection,
                                           isRecognizing: $isRecognizing)
                        
                    } else if scanSelection == .camera { // scan via camera
                        DocumentScannerView(scanSelection: $scanSelection,
                                            isRecognizing: $isRecognizing)
                    } else { // default "gallery or camera" screen
                        ScannerSelectView(scanSelection: $scanSelection)
                            .transition(AnyTransition.scale(scale: 0.8).combined(with: .opacity).combined(with: .move(edge: .bottom)))
                    }
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
}

/// Selection screen for picking either Gallery or Document Scanner to input a receipt to scan.
/// Controls the selection by altering the @Binding scanSelection passed to it from the parent view.
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

/// Confirmation view displays the receipt before saving the receipt. Allows user to confirm, edit, and delete the receipt along with providing the image of the receipt for reference.
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
                        Text("body text body text body text body text body text body text body text body text body text body text body text body text body text body text body text body text body text body text body text body text body text body text body text body text body text body text body text body text body text body text body text body text body text body text body text body text body text body text body text body text body text body text body text body text body text body text body text body text body text")
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

/// Document Camera used for scanning receipts to save.
/// Controls the DocumentScanner which is used to get a array of images. The images are passed to TextRecognition to extract the text and create a recognizedContent variable, which is saved as a receipt.
struct DocumentScannerView: View {
    @State var invalidAlert: Bool = false
    @Binding var scanSelection: ScanSelection
    @Binding var isRecognizing: Bool
    @ObservedObject var recognizedContent: RecognizedContent  = RecognizedContent()
    
    var body: some View {
        if !UIDevice.current.isSimulator { // if device is physical (supports camera)
            DocumentScanner { result in
                switch result {
                    case .success(let scannedImages):
                        isRecognizing = true
                        print(recognizedContent.items.count)
                        ScanTranslation(scannedImages: scannedImages,
                                        recognizedContent: recognizedContent) {
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
        }
    }
    
    /* i would put saveReceipt() in a separate function since its duplicated in both scanners,
    but scanSelection keeps saying "im a let tho, you cant change me"
    despite me assigning it as a Binding<ScanSelection> in the function params :( */
    func saveReceipt() -> Bool{
        if recognizedContent.items.count > 0 {
            for receipt in recognizedContent.items {
                if receipt.text.count < 2 {
                    return false
                } else {
                    Receipt.saveScan(recognizedText: receipt.text, image: receipt.image)
                    return true
                }
            }
            scanSelection = .none
        }
        return false
    }
}

/// Gallery Scanner used for scanning receipts to save.
/// Controls the ImagePicker (gallery) which is used to get a array of images. The images are passed to TextRecognition to extract the text and create a recognizedContent variable, which is saved as a receipt.
struct GalleryScannerView: View {
    @State var invalidAlert: Bool = false
    @Binding var scanSelection: ScanSelection
    @Binding var isRecognizing: Bool
    @ObservedObject var recognizedContent: RecognizedContent  = RecognizedContent()
    
    var body: some View {
        ImagePicker { result in
            switch result {
                case .success(let scannedImages):
                    print("github please just give me the 'passing' badge")
                    isRecognizing = true
                    print(recognizedContent.items.count)
                    ScanTranslation(scannedImages: scannedImages,
                                    recognizedContent: recognizedContent) {
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
    
    /* i would put saveReceipt() in a separate function since its duplicated in both scanners,
    but scanSelection keeps saying "im a let tho, you cant change me"
    despite me assigning it as a Binding<ScanSelection> in the function params :( */
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

/// ImagePicker handles the gallery importing of images to be stored.
struct ImagePicker: UIViewControllerRepresentable {
    var didFinishScanning: ((_ result: Result<[UIImage], Error>) -> Void)
    var didCancelScanning: () -> Void
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = context.coordinator
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) { }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(with: self)
    }
    
    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var galleryView: ImagePicker
        
        init(with gallery: ImagePicker) {
            self.galleryView = gallery
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                galleryView.didFinishScanning(.success([image]))
            }
        }
        
        func imagePickerControllerDidCancel(_ controller: UIImagePickerController) {
            galleryView.didCancelScanning()
        }
        
        func imagePickerViewController(_ controller: UIImagePickerController, didFailWithError error: Error) {
            galleryView.didFinishScanning(.failure(error))
        }
    }
}

/// DocumentScanner handles the camera importing of images to be stored.
struct DocumentScanner: UIViewControllerRepresentable {
    var didFinishScanning: ((_ result: Result<[UIImage], Error>) -> Void)
    var didCancelScanning: () -> Void
    
    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let scannerViewController = VNDocumentCameraViewController()
        scannerViewController.delegate = context.coordinator
        return scannerViewController
    }
    
    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) { }
    
    
    func makeCoordinator() -> Coordinator {
        Coordinator(with: self)
    }
    
    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        let scannerView: DocumentScanner
        
        init(with scannerView: DocumentScanner) {
            self.scannerView = scannerView
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            var scannedPages = [UIImage]()
            
            for i in 0..<scan.pageCount {
                scannedPages.append(scan.imageOfPage(at: i))
            }
            scannerView.didFinishScanning(.success(scannedPages))
        }
        
        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            scannerView.didCancelScanning()
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
            scannerView.didFinishScanning(.failure(error))
        }
    }
}

