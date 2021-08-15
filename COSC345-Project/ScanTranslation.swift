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

struct ScanTranslation {
    var scannedImages: [UIImage]
    @ObservedObject var recognizedContent: RecognizedContent
    var didFinishRecognition: () -> Void
    
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
                
                /*guard let recognizedText = observation.topCandidates(1).first else { return }
                receiptItem.text += recognizedText.string
                receiptItem.text += "\n"*/
            }
        }
        
        print(receiptItem.text)
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        
        return request
    }
}
