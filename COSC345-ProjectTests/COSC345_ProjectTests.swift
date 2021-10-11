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
        var receipt: Receipt
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
        
        //Receipt.saveScan(recognizedText: generatedString, image: image2)
        receipt = Receipt.getReceipt(title: "Blond")
        let splitString = generatedString.components(separatedBy: CharacterSet.newlines).first!
        print(splitString)
        XCTAssert(splitString == testGen)
            
             let preview: PersistenceController = {
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
                
                for index in 0..<2 {
                    let newReceipt = Receipt(context: viewContext)
                    newReceipt.body = "BODY TEXT EXAMPLE"
                    newReceipt.date = Date()
                    newReceipt.id = UUID()
                    newReceipt.title = "Example Store"
                    newReceipt.folder = "Documents"
                }
                        
                 PersistenceController.save(viewContext: viewContext)
                return result
            }()
            XCTAssert(PersistenceController.preview.getContext() != preview.getContext() )
        
        }
        
        let scans = ["Countdown\nLettuce - $2.00,\nDoritos - $2.99,\nMilk - $3", // groceries
                     
                     "JB Hifi\nKeyboard - $120.00,\nTablet - $2300.99,\nEar buds - $119.99", // tech
                     
                     "Mitre 10\nAxe - $110.00,\nTimber - $2009.10,\nGlue - $10.00", //hardware
                     
                     "Kitchen Things\nWashing Machine - $2560.10", //appliance
                     
                     "Animates\nDog Food - $30.00,\nBowl - $20.00", //pets
                     
                     "Dunedin Pharmacy\nVitamins - $65.00,\nLip Balm - $4.50", // Health/Beauty
                     
                     "Big Save Furniture\nCouch - $1450.00,\nBed Frame - $1000.00", // home
                     
                     "Paper Plus\nPaper - $10.00,\nToner - $39.50,\nCalendar - $25.00",
                     
                     "Cotton on\n2x Tee - $30.00,\nPants - $45.00", // apparel
                     
                     "Paper Plus\nPaint - $25.00,\nClay - $5.99,\nEraser - $3.00", // arts
                     
                     "JetBrains\nJava IDE - $250.00", // software
                     
                     "JB Hifi\nPS5 - $500.00,\nPlaystation Game - $120.00", // games
                     
                     "Nike\nSoccer Shoes - $150.00,\n Mouthguard - $15.00", // sports
                     
                     "SuperCheap Auto\nSteering Wheel - $320.00,\n Battery - $450.00,\nRims - $75.00" // vehicles
        ]
        
        
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
            XCTAssert(Folder.getFolder(title: receipt.title) != Folder.getFolder(title: ""))
            if count < scans.count-1 {
                count += 1
            }else {
                break
            }
        }
        Folder.deleteAll()
        print(Folder.folders.count)
        XCTAssert(Folder.folders.count == 15)
        
        Folder.addFolder(title: "TEST1234", icon: "TEST1234")
        XCTAssert(Folder.folderExists(title: "TEST1234"))
        let recepitCount = Folder.getCount(title: "TEST1234")
        XCTAssert(recepitCount > 0)
        Folder.ifEmptyDelete(title: "TEST1234")
        Folder.verifyFolder(title: "TEST1234")
        XCTAssert(Folder.getCount(title: "TEST1234") == recepitCount+1)
        
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
        
        var color = Color.white
        let colorRgb = color.rgb
        let bound = color.description.range(of: "name: \"")
        color = Color.red
        let colorRgb2 = color.rgb
        let bound2 = color.description.range(of: "name: \"")
        XCTAssert(colorRgb2?.green != colorRgb?.green && bound == bound2)
        
    }
}
