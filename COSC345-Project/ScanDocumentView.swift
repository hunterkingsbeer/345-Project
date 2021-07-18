//
//  ScanDocumentView.swift
//  COSC345-Project
//
//  Created by AppCoda - https://github.com/appcoda
//  Modified by Hunter Kingsbeer on 26/05/21.
//

import SwiftUI
import VisionKit
import Vision

/// ScanDocumentView handles the document scanner to read text
struct ScanDocumentView: UIViewControllerRepresentable {
    /// The recognized text from the scan
    @Binding var recognizedText: String
    /// Returns if the scan contains a minimum number of words
    @Binding var validScan: ValidScanType
    
    
    func makeCoordinator() -> Coordinator {
        Coordinator(recognizedText: $recognizedText, parent: self, validScan: $validScan)
    }
    
    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let documentViewController = VNDocumentCameraViewController()
        documentViewController.delegate = context.coordinator
        return documentViewController
    }
    
    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {
        // nothing to do here, required for the UIViewControllerRepresentable type
    }
}
/// Coordinator for ScanDocumentView
class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
    var recognizedText: Binding<String>
    var parent: ScanDocumentView
    var validScan: Binding<ValidScanType>
    
    init(recognizedText: Binding<String>, parent: ScanDocumentView, validScan: Binding<ValidScanType>) {
        self.recognizedText = recognizedText
        self.parent = parent
        self.validScan = validScan
    }
    
    /// Controller for the document camera
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
    
        let extractedImages = extractImages(from: scan)
        let processedText = recognizeText(from: extractedImages)
        recognizedText.wrappedValue = processedText
        validScan.wrappedValue = .validScan //always a valid scan if they take the pic themselves
    }
    
    /// converts the document scanners image into a CG Image
    fileprivate func extractImages(from scan: VNDocumentCameraScan) -> [CGImage] {
        var extractedImages = [CGImage]()
        for index in 0..<scan.pageCount {
            let extractedImage = scan.imageOfPage(at: index)
            guard let cgImage = extractedImage.cgImage else { continue }
            
            extractedImages.append(cgImage)
        }
        return extractedImages
    }
    
    /// translates a CG Image into a string
    fileprivate func recognizeText(from images: [CGImage]) -> String {
        var entireRecognizedText = ""
        let recognizeTextRequest = VNRecognizeTextRequest { (request, error) in
            guard error == nil else { return }
            
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            
            let maximumRecognitionCandidates = 1
            for observation in observations {
                guard let candidate = observation.topCandidates(maximumRecognitionCandidates).first else { continue }
                
                entireRecognizedText += "\(candidate.string)\n"
                
            }
        }
        recognizeTextRequest.recognitionLevel = .accurate
        
        for image in images {
            let requestHandler = VNImageRequestHandler(cgImage: image, options: [:])
            
            try? requestHandler.perform([recognizeTextRequest])
        }
        
        return entireRecognizedText
    }
}
