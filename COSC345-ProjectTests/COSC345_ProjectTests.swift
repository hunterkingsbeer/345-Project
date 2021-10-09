//
//  COSC345_ProjectTests.swift
//  COSC345-ProjectTests
//
//  Created by Hunter Kingsbeer on 14/05/21.
//

import XCTest
import CoreData
@testable import COSC345_Project
import SwiftUI

class COSC345_ProjectTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testReceipt() throws {
        var image = [UIImage()]
        var image2 =  UIImage()
        let recognizedContent = RecognizedContent()
        let bundle = Bundle(for: COSC345_ProjectTests.self)
        var generatedString = ""
        var testString = ""
        var recepit = Receipt();
        //var documentView = DocumentScannerView()
        
            // Fetch Image Data
        if let path = bundle.path(forResource: "testRec", ofType: "jpg"){
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                image[0] = UIImage.init(data: data)!
                image2 = UIImage.init(data: data)!
//                print(image[0]) // checking if it is storing the image or not, it will print the size
            } catch {
                debugPrint("local picture missing")
                
            }
        }
    
        ScanTranslation(scannedImages: image, recognizedContent: recognizedContent){
            generatedString = recognizedContent.items[0].text
            print("GENERATED STRING:\n------------\n\(generatedString)\n------------\n")
        }.recognizeTextDebug()
        print()
        
        if let path = bundle.path(forResource: "test", ofType: "txt"){
            do {
                testString = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
                print("TEST STRING:\n------------\n\(testString)\n------------\n") // checking if it is storing the image or not, it will print the size
            } catch {
                debugPrint("local file missing")
                
            }
        
        print(recognizedContent.items)
            let genString = generatedString.components(separatedBy: CharacterSet.newlines).first
            let testGen = testString.components(separatedBy:  CharacterSet.newlines).first
            XCTAssert(genString == testGen )
        
        Receipt.saveScan(recognizedText: generatedString, image: image2)
        recepit = Receipt.getReceipt(title: "Blond")
        let splitString = generatedString.components(separatedBy: CharacterSet.newlines).first!
        print(splitString)
        XCTAssert(splitString == recepit.title?.lowercased())
             var preview: PersistenceController = {
                let result = PersistenceController(inMemory: true)
                let viewContext = result.container.viewContext
                
                for folder in Folder.folders {
                    let newFolder = Folder(context: viewContext)
                    newFolder.title = folder.title.capitalized
                    newFolder.color = folder.color
                    newFolder.icon = folder.icon
                    newFolder.id = UUID()
                }
                
                 PersistenceController.save(viewContext: viewContext)
                
                for index in 0..<10 {
                    let newReceipt = Receipt(context: viewContext)
                    newReceipt.body = "BODY TEXT EXAMPLE"
                    newReceipt.date = Date()
                    newReceipt.id = UUID()
                    newReceipt.title = "Example Store"
                    newReceipt.folder = Prediction.pointPrediction(text: ((newReceipt.title ?? "") + (newReceipt.body ?? "")))
                }
                        
                 PersistenceController.save(viewContext: viewContext)
                return result
            }()
            XCTAssert(PersistenceController.preview.getContext() != preview.getContext() )
        }
    }
    
    /**
     Checks if the recpits are being stored and fetched in folders correctly
     */
    func testFolders() throws {
        let scans = ["Cotton On", "Jb Hifi", "Countdown", "Invoice"]
        Receipt.generateKnownReceipts()
        var count = 0
        for receipt in Receipt.getReceipts() {
            XCTAssert(scans.contains(receipt.title ?? ""))
            if count < scans.count-1 {
                count += 1
            } else {
                break
            }
        }
    }
    
    func testUserSettings() throws {
        let userSet = UserSettings()
        userSet.darkMode = true
        var testVar = UserDefaults.standard.bool(forKey: "darkMode")
        var testString = ""
        var testInt = 0
        XCTAssert(testVar == userSet.darkMode)
        userSet.darkMode = false
        testVar = UserDefaults.standard.bool(forKey: "darkMode")
        XCTAssert(testVar == userSet.darkMode)
        
        userSet.accentColor = "0000"
        testString = UserDefaults.standard.string(forKey: "accentColor")!
        XCTAssert(testString == userSet.accentColor)
        userSet.accentColor = "0001"
        testString = UserDefaults.standard.string(forKey: "accentColor")!
        XCTAssert(testString == userSet.accentColor)

        userSet.thinFolders = true
        testVar = UserDefaults.standard.bool(forKey: "thinFolders")
        XCTAssert(testVar == userSet.thinFolders)
        userSet.thinFolders = false
        testVar = UserDefaults.standard.bool(forKey: "thinFolders")
        XCTAssert(testVar == userSet.thinFolders)

        userSet.shadows = true
        testVar = UserDefaults.standard.bool(forKey: "shadows")
        XCTAssert(testVar == userSet.shadows)
        userSet.shadows = false
        testVar = UserDefaults.standard.bool(forKey: "shadows")
        XCTAssert(testVar == userSet.shadows)

        userSet.autocomplete = true
        testVar = UserDefaults.standard.bool(forKey: "autocomplete")
        XCTAssert(testVar == userSet.autocomplete)
        userSet.autocomplete = false
        testVar = UserDefaults.standard.bool(forKey: "autocomplete")
        XCTAssert(testVar == userSet.autocomplete)

        userSet.devMode = true
        testVar = UserDefaults.standard.bool(forKey: "devMode")
        XCTAssert(testVar == userSet.devMode)
        userSet.devMode = false
        testVar = UserDefaults.standard.bool(forKey: "devMode")
        XCTAssert(testVar == userSet.devMode)

        userSet.scanDefault = 1
        testInt = UserDefaults.standard.integer(forKey: "scanDefault")
        XCTAssert(testInt == userSet.scanDefault)
        userSet.scanDefault = 2
        testInt = UserDefaults.standard.integer(forKey: "scanDefault")
        XCTAssert(testInt == userSet.scanDefault)

        userSet.firstUse = true
        testVar = UserDefaults.standard.bool(forKey: "firstUse")
        XCTAssert(testVar == userSet.firstUse)
        userSet.firstUse = false
        testVar = UserDefaults.standard.bool(forKey: "firstUse")
        XCTAssert(testVar == userSet.firstUse)
        
        userSet.passcodeProtection = true
        testVar = UserDefaults.standard.bool(forKey: "passcodeProtection")
        XCTAssert(testVar == userSet.passcodeProtection)
        userSet.passcodeProtection = false
        testVar = UserDefaults.standard.bool(forKey: "passcodeProtection")
        XCTAssert(testVar == userSet.passcodeProtection)
        
        userSet.passcode = "0001"
        testString = UserDefaults.standard.string(forKey: "passcode")!
        XCTAssert(testString == userSet.passcode)
        userSet.passcode = "0002"
        testString = UserDefaults.standard.string(forKey: "passcode")!
        XCTAssert(testString == userSet.passcode)

    }
    
    func testRandomFunctions() throws {
        let image: Image!
        let bundle = Bundle(for: COSC345_ProjectTests.self)
        if let path = bundle.path(forResource: "testRec", ofType: "jpg"){
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                image = Image.init(data: data)!
                XCTAssert(image != nil)
//                print(image[0]) // checking if it is storing the image or not, it will print the size
            } catch {
                debugPrint("local picture missing")
                
            }
        }
        
        let tab = TabSelection.init()
        tab.selection = 0
        XCTAssert(tab.selection == 0)
        tab.changeTab(tabPage: TabPage.scan)
        XCTAssert(tab.selection == 1)
        
    }
}
