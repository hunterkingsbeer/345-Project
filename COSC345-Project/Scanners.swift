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

///``RecognizedContent``
/// is an observable object that holds an array of ReceiptItem type variables. This is what is passed to the ScanTranslation process and receipt processes.
class RecognizedContent: ObservableObject {
    ///``items`` holds the array of ReceiptItem variables.
    @Published var items = [ReceiptItem]()
}

/// ``ReceiptItem``
/// is an identifiable object that holds information relating to a scanned receipt.
class ReceiptItem: Identifiable {
    ///``uuid`` holds a unique ID that allows the object to be identifiable
    var uuid: UUID = UUID()
    ///``text`` is the text extracted from the image of the receipt the user has scanned.
    var text: String = ""
    ///``image`` is a UI Image that the user has scanned of their receipt, and which the receipt is based on.
    var image: UIImage = UIImage()
}

/// ``ScanSelection``
/// is an enum with three cases that relate to the active scanning in the ScanView.
enum ScanSelection: Int {
    ///``none``: When none is active, the ScannerSelectView is active. Showing the user the option to pick between camera or gallery to scan.
    case none = 0
    ///``camera``: When camera is active, the DocumentScannerView is active. Showing the user the document scanner to scan with.
    case camera = 1
    ///``gallery``:  When camera is active, the GalleryScannerView is active. Showing the user the gallery to scan with.
    case gallery = 2
}

/// ``SaveState``
/// is an enum with three cases that relate to the states a receipt may be in while being saved to the database.
enum SaveState {
    ///``none``: When none is active, the receipt doesn't need saving. This is its default state.
    case none
    ///``recognizing``: When confirming is active, the receipt is being confirmed by the user.
    case recognizing
    
    case saving
    
    case confirming
}

/// ``ScanView``
/// is a Parent View struct that holds the scanner views (GalleryScannerView, DocumentScannerView, and ScannerSelectView).
/// This manages the visibility of the scanners based on the ScanSelection variable. A Loading screen is displayed when translating a scanned image.
/// - Called by ContentView.
/// - ScanSelection
///     - .none = ScannerSelectView
///     - .camera = DocumentScannerView
///     - .gallery  = GalleryScannerView
struct ScanView: View {
    ///``settings`` Alters the view based on the user's settings. Imports the UserSettings EnvironmentObject allowing unified usage and updating of the users settings across all classes.
    @EnvironmentObject var settings: UserSettings
    ///``inSimulator`` provides a bool based on if the application is in a simulator. Allows the view to avoid errors relating to the camera being available or not.
    let inSimulator: Bool = UIDevice.current.inSimulator
    ///``scanSelection`` is used to manage the screens active view, based on the values presented in the ScanView's documentation.
    @State var scanSelection: ScanSelection = .none
    ///``SaveState`` is used to manage the receipts save states while its being saved and processed. (via ScanTranslation).
    @State var saveState: SaveState = .none
    @State var unusedBool = false
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            VStack {
                TitleText(buttonBool: $unusedBool, title: "scan", icon: getIcon())
                    .padding(.horizontal)
                
                if scanSelection == .gallery { // scan via gallery
                    GalleryScannerView(scanSelection: $scanSelection,
                                       saveState: $saveState)
                    
                } else if scanSelection == .camera { // scan via camera
                    DocumentScannerView(scanSelection: $scanSelection,
                                        saveState: $saveState)
                } else { // default "gallery or camera" screen
                    ScannerSelectView(scanSelection: $scanSelection)
                        .transition(AnyTransition.scale(scale: 0.8).combined(with: .opacity).combined(with: .move(edge: .bottom)))
                }
            }
        }.onAppear(perform: {
            scanSelection = ScanSelection(rawValue: settings.scanDefault) ?? .none
        })
    }
    func getIcon() -> String {
        if scanSelection == .camera {
            return "camera"
        } else if scanSelection == .gallery {
            return "photo"
        }
        return "plus"
    }
}

/// ``ScannerSelectView``
/// is a View struct that displays the option of scanning by camera (DocumentScanner) or gallery (ImagePicker). Upon user interaction it will set the ScanSelection to ther respective value, changing the view.
/// - Called by ScanView.
struct ScannerSelectView: View {
    ///``scanSelection`` is used to manage the screens active view. This is @Binding as it controls the parent views value, allowing it to change the screen as desired.
    @Binding var scanSelection: ScanSelection
    ///``settings``: Imports the UserSettings environment object allowing unified usage and updating of the users settings across all classes.
    @EnvironmentObject var settings: UserSettings
    
    var body: some View {
        VStack {
            Spacer()
            Button(action: {
                scanSelection = scanSelection == .camera ? .none : .camera
            }){
                Blur(effect: UIBlurEffect(style: .systemThinMaterial))
                    .opacity(0.9)
                    .cornerRadius(12)
                    .overlay(
                        // the title and body
                        VStack (alignment: .center){
                            Spacer()
                            Image(systemName: "camera")
                                .font(.system(size: 50))
                            VStack(alignment: .center) {
                                Text("Camera")
                                    .font(.system(size: 22, weight: .bold, design: .rounded))
                                Text("Use the camera to scan a physical item.")
                                    .font(.system(size: 14, weight: .regular, design: .rounded))
                                    .frame(width: UIScreen.screenWidth * 0.35)
                                    .multilineTextAlignment(.center)
                                    .padding(.top, 10)
                            }
                            Spacer()
                        }.padding()
                    ).frame(width: UIScreen.screenWidth * 0.65, height: UIScreen.screenHeight * 0.25)
                    .padding(.bottom)
            }.buttonStyle(ShrinkingButtonSpring())
            .accessibility(identifier: "Add from Camera")
            
            Spacer()
        
            Button(action: {
                scanSelection = scanSelection == .gallery ? .none : .gallery
            }){
                Blur(effect: UIBlurEffect(style: .systemThinMaterial))
                    .opacity(0.9)
                    .cornerRadius(12)
                    .overlay(
                        // the title and body
                        VStack (alignment: .center){
                            Spacer()
                            Image(systemName: "photo")
                                .font(.system(size: 50))
                            VStack(alignment: .center) {
                                Text("Gallery")
                                    .font(.system(size: 22, weight: .bold, design: .rounded))
                                Text("Use the gallery to import an image.")
                                    .font(.system(size: 14, weight: .regular, design: .rounded))
                                    .multilineTextAlignment(.center)
                                    .frame(width: UIScreen.screenWidth * 0.3)
                                    .padding(.top, 10)
                            }
                            Spacer()
                        }.padding()
                    ).frame(width: UIScreen.screenWidth * 0.65, height: UIScreen.screenHeight * 0.25)
                    .padding(.top)
            }.buttonStyle(ShrinkingButtonSpring())
            .accessibility(identifier: "Add from Gallery")
            
            Spacer()
        }.padding()
    }
}


/// ``ConfirmationView``
/// is a View struct that shows the user its scanned receipt(s) and then provides them with an option of editing, discarding, or confirming the scan.
/// - Called by DocumentScannerView and GalleryScannerView.
struct ConfirmationView: View {
    ///``selectedTab`` Controls the TabView's active tab it is viewing. Imports the TabSelection EnvironmentObject, allowing for application wide changing of the selected tab.
    @EnvironmentObject var selectedTab: TabSelection
    
    @State var receipt: Receipt
    ///``scanSelection`` is used to manage the screens active view. This is @Binding as it controls the parent views value, allowing it to change the screen as desired.
    @Binding var scanSelection: ScanSelection
    ///``SaveState`` is used to manage the receipts save states while its being saved and processed. (via ScanTranslation).
    @Binding var saveState: SaveState
    ///``isConfirming`` is a bool used to control the confirmation screens sheet.
    @Binding var isConfirming: Bool
    ///``settings``: Imports the UserSettings environment object allowing unified usage and updating of the users settings across all classes.
    @EnvironmentObject var settings: UserSettings
    
    var body: some View {
        VStack {
            Text("Does this look correct?")
                .font(.system(.title, design: .rounded)).bold()
            ZStack { // receipt
                VStack {
                    ZStack (alignment: .top) {
                        Blur(effect: UIBlurEffect(style: .systemThinMaterial))
                            .ignoresSafeArea()
                            .overlay(Color(Folder.getColor(title: "software"))
                                        .blendMode(.color)
                                        .opacity(settings.darkMode ? 0.2 : 1.0))
                        
                        HStack(alignment: .center) {
                            VStack(alignment: .leading) {
                                Text("\(getDate(date: receipt.date))")
                                    .font(.caption)
                                
                                Text(receipt.title ?? "")
                                    .font(.title)
                                
                                Text(receipt.folder ?? "")
                            }
                            Spacer()
                            Image(systemName: Folder.getIcon(title: receipt.folder))
                                .font(.system(size: 30, weight: .semibold))
                                .padding(10)
                                .foregroundColor(Color(Folder.getColor(title: receipt.folder)))
                                .cornerRadius(12)
                        }.foregroundColor(Color("text"))
                        .padding()
                    }.frame(height: UIScreen.screenHeight * 0.14)
                    Spacer()
                }.zIndex(1)
                
                ScrollView(showsIndicators: false) {
                    HStack(alignment: .top) {
                        VStack {
                            if Image(data: receipt.image) != nil {
                                (Image(data: receipt.image) ?? Image(""))
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .padding(.top)
                            }
                            Text(receipt.body ?? "")
                            Spacer()
                        }
                        Spacer()
                    }.padding(.horizontal)
                    .padding(.top, UIScreen.screenHeight * 0.14)
                    .fixedSize(horizontal: false, vertical: true)
                }.background(Color("object"))
                .frame(height: UIScreen.screenHeight * 0.675)
                .zIndex(0)
            }.cornerRadius(12)
            
            VStack { // buttons
                HStack (alignment: .center){
                    Button(action:{ // cancel
                        exit(success: false)
                    }){
                        Blur(effect: UIBlurEffect(style: .systemMaterial))
                            .cornerRadius(12)
                            .overlay(Image(systemName: "xmark"))
                    }.buttonStyle(ShrinkingButton())
                    
                    Button(action:{ // view image of scan
                        
                    }){
                        Blur(effect: UIBlurEffect(style: .systemMaterial))
                            .cornerRadius(12)
                            .overlay(Image(systemName: "photo"))
                    }.buttonStyle(ShrinkingButton())
                    
                    Button(action:{ // edit scan
                        
                    }){
                        Blur(effect: UIBlurEffect(style: .systemMaterial))
                            .cornerRadius(12)
                            .overlay(Image(systemName: "pencil"))
                    }.buttonStyle(ShrinkingButton())
                    
                    Button(action:{ // confirmation
                        exit(success: true)
                    }){
                        Blur(effect: UIBlurEffect(style: .systemMaterial))
                            .cornerRadius(12)
                            .overlay(Image(systemName: "checkmark"))
                    }.buttonStyle(ShrinkingButton())
                }
            }
        }.padding()
    }
    
    func exit(success: Bool){
        if success {
            Receipt.save()
            saveState = .none
            isConfirming = false
            selectedTab.changeTab(tabPage: .home)
        } else {
            Receipt.delete(receipt: receipt)
            saveState = .none
            isConfirming = false
        }
    }
}

/// ``GalleryScannerView``
/// is a View struct that manages the ImagePicker and its outputs and surrounding processes.
/// - Called by ScanView.
/// - The ImagePicker outputs a result, which is either a success or a failure.
///     - A success holds scanned images, which are passed to ScanTranslation which extracts the information from the images and applies it into the recognizedContent variable. ScanTranslation holds the saveReceipt function which saves the receipt to the database.
///     - A failure prints an error to the debug console and places the user back on the image picker.
struct GalleryScannerView: View {
    ///``selectedTab`` Controls the TabView's active tab it is viewing. Imports the TabSelection EnvironmentObject, allowing for application wide changing of the selected tab.
    @EnvironmentObject var selectedTab: TabSelection
    ///``scanSelection`` is used to manage the screens active view. This is @Binding as it controls the parent views value, allowing it to change the screen as desired.
    @Binding var scanSelection: ScanSelection
    ///``SaveState`` is used to manage the receipts save states while its being saved and processed. (via ScanTranslation).
    @Binding var saveState: SaveState
    
    @State var receipt: Receipt = Receipt()
    ///``invalidAlert`` is used to set whether the scan is valid or not. This links with the parent ScanView which actually displays the error.
    @State var invalidAlert: Bool = false
    ///``isConfirming`` is a bool used to control the confirmation screens sheet.
    @State var isConfirming: Bool = false
    ///``recognizedContent`` is an object that holds an array of ReceiptItems, holding the information about the scan performed by the user.
    @ObservedObject var recognizedContent: RecognizedContent  = RecognizedContent()
    
    var body: some View {
        ImagePicker { result in
            switch result {
            case .success(let scannedImages):
                ScanTranslation(scannedImages: scannedImages, recognizedContent: recognizedContent) {
                    if saveReceipt() { // if save receipt returns true (valid scan), exit the scanner
                        saveState = .saving // set the state to saving
                    } else { // else stay in the scanner and alert them to scan again
                        invalidAlert = true
                    }
                }.recognizeText()
            case .failure(let error):
                print(error.localizedDescription)
            }
        } didCancelScanning: {
            // Dismiss the scanner
            scanSelection = .none
        }.sheet(isPresented: $isConfirming, content: {
            ConfirmationView(receipt: Receipt.getReceipt(title: getTitle(text: recognizedContent.items[recognizedContent.items.count-1].text)),
                             scanSelection: $scanSelection, saveState: $saveState, isConfirming: $isConfirming)
        }).alert(isPresented: $invalidAlert) {
            Alert(
                title: Text("Receipt Not Saved!"),
                message: Text("This image is not valid. Try again."),
                dismissButton: .default(Text("Okay"))
            )
        }.onChange(of: receipt, perform: { _ in
            if (receipt.body ?? "").count > 10 {
                isConfirming = true
            }
        })
    }
    
    /// ``saveReceipt``
    /// is a function that is used to save a RecognizedContent objects receipts. It is used in an if statement to determine whether there is actually translated text, and if its at an acceptable number.
    /// - Returns
    ///     - True if the scan is being saved, and passed the validity tests, False if the scan isn't able to be saved, and didn't pass the validity tests.
    func saveReceipt() -> Bool {
        if recognizedContent.items.count > 0 {
            for receiptIn in recognizedContent.items {
                if receiptIn.text.count > 2 { // if the text in receipt is a suitable size
                    receipt = Receipt.returnScan(recognizedText: receiptIn.text)
                    return true
                } else {
                   
                    return false
                }
            }
            scanSelection = .none
        }
        return false
    }
}

/// ``DocumentScannerView``
/// is a View struct that manages the DocumentScanner and its outputs and surrounding processes.
/// The document scanner is only displayed if the application is being run on a physical iPhone, otherwise an error message is displayed.
/// - Called by ScanView.
/// - The DocumentScanner outputs a result, which is either a success or a failure.
///     - A success holds scanned images, which are passed to ScanTranslation which extracts the information from the images and applies it into the recognizedContent variable. ScanTranslation holds the saveReceipt function which saves the receipt to the database.
///     - A failure prints an error to the debug console and places the user back on the document scanner.
struct DocumentScannerView: View {
    ///``scanSelection`` is used to manage the screens active view. This is @Binding as it controls the parent views value, allowing it to change the screen as desired.
    @Binding var scanSelection: ScanSelection
    ///``SaveState`` is used to manage the receipts save states while its being saved and processed. (via ScanTranslation).
    @Binding var saveState: SaveState
    ///``isConfirming`` is a bool used to control the confirmation screens sheet.
    @State var isConfirming: Bool = false
    ///``invalidAlert`` is used to set whether the scan is valid or not. This links with the parent ScanView which actually displays the error.
    @State var invalidAlert: Bool = false
    ///``recognizedContent`` is an object that holds an array of ReceiptItems, holding the information about the scan performed by the user.
    @ObservedObject var recognizedContent: RecognizedContent  = RecognizedContent()
    
    var body: some View {
        if !UIDevice.current.inSimulator { // if device is physical (supports camera)
            DocumentScanner { result in
                switch result {
                case .success(let scannedImages):
                    saveState = .confirming
                    print(recognizedContent.items.count)
                    if saveState == .recognizing {
                        ScanTranslation(scannedImages: scannedImages, recognizedContent: recognizedContent) {
                            if saveReceipt() { // if save receipt returns true (valid scan), exit the scanner
                                saveState = .saving // set the state to saving
                            } else { // else stay in the scanner and alert them to scan again
                                invalidAlert = true
                            }
                        }.recognizeText()
                    }
                    if saveState == .saving { // is the receipt was able to save then make the user confirm it. (receipt needs to be saved first, to make sure there is a database entry to edit.)
                        saveState = .confirming
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            } didCancelScanning: {
                // Dismiss the scanner
                scanSelection = .none
            }.onChange(of: saveState, perform: { _ in
                if saveState == .confirming {
                    isConfirming = true
                } else {
                    isConfirming = false
                }
            })
            .sheet(isPresented: $isConfirming, content: {
                ConfirmationView(receipt: Receipt.getReceipt(title: getTitle(text: recognizedContent.items[0].text)),
                                 scanSelection: $scanSelection, saveState: $saveState, isConfirming: $isConfirming)
            }).alert(isPresented: $invalidAlert) {
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
                .accessibility(identifier: "CameraSimCheck")
            Button(action: {
                scanSelection = .none
            }){
                Text("BACK")
                    .padding().padding(.horizontal)
                    .background(RoundedRectangle(cornerRadius: 25).fill(Color("object")))
                    .padding()
            }.buttonStyle(ShrinkingButton())
            .accessibility(identifier: "BackButtonCamera")
            Spacer()
        }
    }
    
    /// ``saveReceipt``
    /// is a function that is used to save a RecognizedContent objects receipts. It is used in an if statement to determine whether there is actually translated text, and if its at an acceptable number.
    /// - Returns
    ///     - True if the scan is being saved, and passed the validity tests, False if the scan isn't able to be saved, and didn't pass the validity tests.
    func saveReceipt() -> Bool {
        if recognizedContent.items.count > 0 {
            for receipt in recognizedContent.items {
                if receipt.text.count > 2 { // if the text in receipt is a suitable size
                    
                    Receipt.saveScan(recognizedText: receipt.text)
                    return true
                } else {
                   
                    return false
                }
            }
            scanSelection = .none
        }
        return false
    }
}

/// ``ImagePicker``
/// is a UIViewControllerRepresentable struct that initializes the ImagePicker.
/// - ImagePicker outputs either didFinishScanning or didCancelScanning.
///     - didFinishScanning holds a Result containing an array of UI Images and an error. These are the scanned images and whether the scan was a success or not.
///     - didCancelScanning returns empty, allowing error handling.
///
/// - Called by GalleryScannerView.
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

/// ``DocumentScanner``
/// is a UIViewControllerRepresentable struct that initializes the DocumentCamera.
/// - DocumentScanner outputs either didFinishScanning or didCancelScanning.
///     - didFinishScanning holds a Result containing an array of UI Images and an error type. These are the scanned images and whether the scan was a success or not.
///     - didCancelScanning returns empty, allowing error handling.
///
/// - Called by DocumentScannerView.
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
            
            for index in 0..<scan.pageCount {
                scannedPages.append(scan.imageOfPage(at: index))
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
