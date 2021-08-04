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

// GALLERY SCANNER
struct GalleryScannerView: View {
    @Binding var scanSelection: ScanSelection
    @Binding var isRecognizing: Bool
    @ObservedObject var recognizedContent: RecognizedContent = RecognizedContent()
    
    var body: some View {
        ImagePicker { result in
            switch result {
                case .success(let scannedImages):
                    isRecognizing = true
                    print(recognizedContent.items.count)
                    TextRecognition(scannedImages: scannedImages, recognizedContent: recognizedContent) {
                        saveReceipt()
                        isRecognizing = false // Text recognition is finished, hide the progress indicator.
                        print(recognizedContent.items[0])
                    }.recognizeText()
                case .failure(let error):
                    print(error.localizedDescription)
            }
            scanSelection = .none
        } didCancelScanning: {
            // Dismiss the scanner
            scanSelection = .none
        }
    }
    
    func saveReceipt(){
        if recognizedContent.items.count > 0 {
            for receipt in recognizedContent.items {
                Receipt.saveScan(recognizedText: receipt.text)
                print("TEXT: " + receipt.text)
            }
            scanSelection = .none
        }
    }
}

/// ImagePicker handles the gallery importing of images to be read.
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

// CAMERA SCANNER
struct DocumentScannerView: View {
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
                        TextRecognition(scannedImages: scannedImages, recognizedContent: recognizedContent) {
                            saveReceipt()
                            isRecognizing = false // Text recognition is finished, hide the progress indicator.
                            print(recognizedContent.items[0])
                        }.recognizeText()
                    case .failure(let error):
                        print(error.localizedDescription)
                }
                scanSelection = .none
            } didCancelScanning: {
                // Dismiss the scanner
                scanSelection = .none
            }
        } else { // else if its in the simulator (no camera)
            Text("Not supported in the simulator!\n\nPlease use a physical device.")
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
    
    func saveReceipt(){
        if recognizedContent.items.count > 0 {
            for receipt in recognizedContent.items {
                Receipt.saveScan(recognizedText: receipt.text)
                print("TEXT: " + receipt.text)
            }
            scanSelection = .none
        }
    }
}

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

