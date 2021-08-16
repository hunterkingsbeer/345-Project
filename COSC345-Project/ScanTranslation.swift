//
//  TextRecognition.swift
//  COSC345-Project
//
//  Created by Hunter Kingsbeer on 3/08/21.
//  Code template from: https://github.com/appcoda
//

import SwiftUI
import Vision
import Foundation

/// ``ScanTranslation``
/// is a struct that is used to take an array of scanned images, extract their information, and stitch them into the RecognizedContent object for the ScanView structs to utilize.
/// - Called by GalleryScannerView, and CameraScannerView.
struct ScanTranslation {
    ///``scannedImages`` is an array of UI Images that contains the images of the receipts the user has scanned.
    var scannedImages: [UIImage]
    ///``recognizedContent`` is an object that holds arrays of ReceiptItems, which contain the text and image of a processed receipt.
    @ObservedObject var recognizedContent: RecognizedContent
    ///``didFinishRecognition`` is a variable that allows the struct to return whether the recognition has finished.
    var didFinishRecognition: () -> Void
    
    ///``recognizeText``
    /// is a function that is used to recognize text in the scannedImages parameter of the ScanTranslation struct.
    /// It loops through all images in scannedImages, creates a ReceiptItem, and sets the image to the ReceiptItem before calling getTextRecognitionRequest to extract and set the images text.
    func recognizeText() {
        let queue = DispatchQueue(label: "textRecognitionQueue", qos: .userInitiated)
        queue.async {
            for image in scannedImages {
                guard let cgImage = image.cgImage else { return }
                
                let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
                
                do {
                    let receiptItem = ReceiptItem()
                    receiptItem.image = image
                    try requestHandler.perform([getTextRecognitionRequest(with: receiptItem)])
                    
                    DispatchQueue.main.async {
                        recognizedContent.items.append(receiptItem)
                    }
                } catch {
                    print("\nERROR HAS OCCURED: \(error.localizedDescription)")
                }
                
                DispatchQueue.main.async {
                    didFinishRecognition()
                }
            }
        }
    }
    
    ///``getTextRecognitionRequest``
    /// is a function that recognizes text in images, and assigns the recognized text to the passed ReceiptItem.
    /// - Parameter receiptItem: The object which the extracted text needs to be set to.
    /// - Returns: A VNRecognizeTextRequest that is managed by a request handler to assign the ReceiptItems text variable.
    private func getTextRecognitionRequest(with receiptItem: ReceiptItem) -> VNRecognizeTextRequest {
        let request = VNRecognizeTextRequest { request, error in
            if let error = error {
                print("\nERROR HAS OCCURED: \(error.localizedDescription)")
                return
            }
            
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            observations.forEach { observation in
                guard let recognizedText = observation.topCandidates(1).first else { return }
                receiptItem.text += "\(recognizedText.string)\n"
            }
        }
        print(receiptItem.text)
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        
        return request
    }
    
    ///``recognizeTextDebug``
    /// is a function that is used to recognize text in the scannedImages parameter of the ScanTranslation struct.
    /// It loops through all images in scannedImages, creates a ReceiptItem, and sets the image to the ReceiptItem before calling getTextRecognitionRequest to extract and set the images text.
    /// This has been modified to be compatible with the UI testing performed.
    func recognizeTextDebug(){
        for image in scannedImages {
            guard let cgImage = image.cgImage else { return }
            let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            let receiptItem = ReceiptItem()
            receiptItem.image = image
            try? requestHandler.perform([getTextRecognitionRequest(with: receiptItem)])
            recognizedContent.items.append(receiptItem)
            didFinishRecognition()
        }
    }
}
