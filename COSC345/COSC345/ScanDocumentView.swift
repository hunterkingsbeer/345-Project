import SwiftUI
import VisionKit
import Vision

struct ScanDocumentView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var recognizedText: String
    @Binding var scanToggle: Bool
        
    func makeCoordinator() -> Coordinator {
        Coordinator(recognizedText: $recognizedText, parent: self, scanToggle: $scanToggle)
    }
    
    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let documentViewController = VNDocumentCameraViewController()
        documentViewController.delegate = context.coordinator
        return documentViewController
    }
    
    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {
        // nothing to do here
    }
    
}

class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
    var recognizedText: Binding<String>
    var parent: ScanDocumentView
    var scanToggle: Binding<Bool>
    
    init(recognizedText: Binding<String>, parent: ScanDocumentView, scanToggle: Binding<Bool>) {
        self.recognizedText = recognizedText
        self.parent = parent
        self.scanToggle = scanToggle
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        
        let extractedImages = extractImages(from: scan)
        let processedText = recognizeText(from: extractedImages)
        recognizedText.wrappedValue = processedText
        
        scanToggle.wrappedValue = false //for boolean view
        //parent.presentationMode.wrappedValue.dismiss() //for sheet view
    }
    
    fileprivate func extractImages(from scan: VNDocumentCameraScan) -> [CGImage] {
        var extractedImages = [CGImage]()
        for index in 0..<scan.pageCount {
            let extractedImage = scan.imageOfPage(at: index)
            guard let cgImage = extractedImage.cgImage else { continue }
            
            extractedImages.append(cgImage)
        }
        return extractedImages
    }
    
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
