//
//  ImagePicker.swift
//  COSC345-Project
//
//  Created by AppCoda - https://github.com/appcoda
//  Modified by Hunter Kingsbeer on 26/05/21.
//

import UIKit
import SwiftUI
import VisionKit
import Vision

/// ImagePicker handles the gallery importing of images to be read
struct ImagePicker: UIViewControllerRepresentable {
    /// The recognized text from the scan
    @Binding var recognizedText: String
    /// Returns if the scan contains a minimum number of words
    @Binding var validScan : ValidScanType

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = context.coordinator
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
        // nothing to do here, required for the UIViewControllerRepresentable type
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    
    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
        var parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        /// Controller for ImagePicker
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                //parent.selectedImage = image
                parent.recognizedText = recognizeText(from: image.cgImage!)
            }
            parent.validScan = parent.recognizedText.count < 20 ? .invalidScan : .validScan // less than 20 chars? perhaps this isnt a valid scan
        }
        
        /// translates a CG Image into a string
        fileprivate func recognizeText(from image: CGImage) -> String {
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
            
            let requestHandler = VNImageRequestHandler(cgImage: image, options: [:])
            try? requestHandler.perform([recognizeTextRequest])
            
            return entireRecognizedText
        }
    }
}
