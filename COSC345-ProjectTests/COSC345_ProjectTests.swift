//
//  COSC345_ProjectTests.swift
//  COSC345-ProjectTests
//
//  Created by Hunter Kingsbeer on 14/05/21.
//

import XCTest
import CoreData
@testable import COSC345_Project

class COSC345_ProjectTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testReceipt() throws {
        var image = [UIImage()]
        let content = RecognizedContent()
        //var documentView = DocumentScannerView()
        let url = URL(string: "https://i.pinimg.com/originals/c4/33/54/c433548d29ff98a7c0694403047b44d7.jpg")!
        print("Fetching: \(String(describing: url.absoluteString))")
            // Fetch Image Data
        if let data = try? Data(contentsOf: url) {
            // Create Image and Update Image View
            image[0] = UIImage(data: data) ?? UIImage()
            //print((image[0] == UIImage())) // checking if it is storing default or not
        }

        let storedImage = [UIImage(systemName: "receipt") ?? UIImage()]
        ScanTranslation(scannedImages: storedImage, recognizedContent: content){
            print(content.items[0].text)
            var temp = 0;
            print("IS THIS WORKING")
            for receipt in content.items {
                temp += 1
                print("RECEIPT TEXT \(temp) \(receipt.text)")
            }
        }.recognizeText()
        print(content.items)
    }
    
    
    
    /**
     Checks if the recpits are being stored and fetched in folders correctly
     */
    func testFolders() throws {
        let scans = ["Cotton On","Jb Hifi", "Countdown","Invoice"]
        Receipt.generateKnownReceipts()
        var count = 0
        for i in Receipt.getReceipts(){
            XCTAssert(scans.contains(i.title ?? ""))
            if(count < scans.count-1){
                count += 1
            }
            else{
                break
            }
            
        }
       
    }
    
    
    
    func assertDiffs(){
        
    }
    
    
}


//*let result = PersistenceController(inMemory: true)
///// Context in relation to Core Data
//let viewContext = result.container.viewContext
//
//
//for folder in Folder.folders {
//    let newFolder = Folder(context: viewContext)
//    newFolder.title = folder.title.capitalized
//    newFolder.color = folder.color
//    newFolder.icon = folder.icon
//    newFolder.id = UUID()
//}
//
//PersistenceController.save(viewContext: viewContext)
//
//
//var count = 0
//for index in 0..<10 {
//    let newReceipt = Receipt(context: viewContext)
//    newReceipt.body = "BODY TEXT EXAMPLE"
//    newReceipt.date = Date()
//    newReceipt.id = UUID()
//    newReceipt.title = "Example Store \(count)"
//    newReceipt.folder = Prediction.pointPrediction(text: ((newReceipt.title ?? "") + (newReceipt.body ?? "")))
//    count += 1
//}
//
//PersistenceController.save(viewContext: viewContext)
//
//let fetchRequest: NSFetchRequest<Receipt> = Receipt.fetchRequest()
//fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Receipt.date, ascending: false)]
//let managedObjectContext = PersistenceController.shared.getContext()
//let receipts = try managedObjectContext.fetch(fetchRequest)*/
