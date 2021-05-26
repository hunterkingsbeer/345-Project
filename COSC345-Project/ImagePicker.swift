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

struct ImagePicker: UIViewControllerRepresentable {
    
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @Environment(\.presentationMode) private var presentationMode
    
    //@Binding var selectedImage: UIImage
    @Binding var recognizedText: String
    @Binding var validScan : ValidScanType

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.sourceType = sourceType
        imagePicker.delegate = context.coordinator
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
        var parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                //parent.selectedImage = image
                parent.recognizedText = recognizeText(from: image.cgImage!)
            }
            parent.validScan = parent.recognizedText.count < 20 ? .invalidScan : .validScan // less than 20 chars? perhaps this isnt a valid scan
        }
        
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
            
            //for image in images {
                let requestHandler = VNImageRequestHandler(cgImage: image, options: [:])
                
                try? requestHandler.perform([recognizeTextRequest])
            //}
            
            return entireRecognizedText
        }
    }
}
