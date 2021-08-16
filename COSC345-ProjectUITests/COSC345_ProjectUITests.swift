import XCTest
import UIKit
@testable import COSC345_Project

class COSC345_ProjectUITests: XCTestCase {
    private var image: UIImage?
    var app = XCUIApplication()
    
    override func setUp() {
        super.setUp()
        app.launchArguments = ["testMode"]
        //XCTAssert(isTesting())
    }

    func testHomeView() throws {
        
        app.launch()
        let tabBar = XCUIApplication().tabBars["Tab Bar"]
        
        XCTAssertEqual(app.images["Search"].exists, app.images["Search"].isHittable)
        
        tabBar.buttons["Scan"].forceTap()
        XCTAssertEqual(app.staticTexts["Scan."].exists, app.staticTexts["Scan."].isHittable)
        
        tabBar.buttons["Settings"].forceTap()
        XCTAssertEqual(app.staticTexts["Settings."].exists,app.staticTexts["Settings."].exists)
        
    }
    
    
    func testSettingsView() throws {
                        
        app.launch()
        
        let tabBar = app.tabBars["Tab Bar"]
        tabBar.buttons["Settings"].forceTap()
        
        if( app.switches["DarkModeToggle: true"].exists){
            var darkMode = app.switches["DarkModeToggle: true"]
            darkMode.forceTap()
            darkMode = app.switches["DarkModeToggle: false"]
            tabBar.buttons["Settings"].forceTap() // will remove one the toggle to home screen issue is fixed
            XCTAssert(darkMode.identifier == "DarkModeToggle: false")
        }
                
    }
    
    func testFolderView() throws {
        
        
        app.launch()
        let tabBar = app.tabBars["Tab Bar"]
        tabBar.buttons["Settings"].tap()
        
        //generate recepits
        let elementsQuery = app.scrollViews["ReceiptHomeView"].otherElements
        elementsQuery.buttons["Delete All"].tap()
        elementsQuery.buttons["Delete All"].tap()
        elementsQuery.buttons["Generate Receipts"].tap()
        tabBar.buttons["Home"].tap()
        
        //check recepits
        let elementsQuery2 = app.scrollViews.otherElements
        elementsQuery2.buttons["1 Technology"].tap()
        
        XCTAssert(elementsQuery2.staticTexts["Jb Hifi"].exists)
        elementsQuery2.buttons["1 Default"].tap()
        
        XCTAssert(!elementsQuery2.staticTexts["Jb Hifi"].exists)
        elementsQuery2.staticTexts["Invoice"].tap()
        sleep(2)

        XCTAssert(!elementsQuery2.staticTexts["Invoice"].isHittable)
        
        sleep(2)
        XCUIApplication().buttons["chevron.down"].tap()
        XCTAssert(elementsQuery2.staticTexts["Invoice"].isHittable)
        elementsQuery2.staticTexts["Invoice"].tap()
        
        app.buttons["photo"].tap()
        XCTAssert(!app.buttons["go down"].isHittable)
       // this should be passing just fine
        
        app.buttons["photo"].tap()
        XCTAssert(app.buttons["go down"].exists)
        
        app.buttons["trash"].tap()
        app.buttons["trash"].tap()
        
        XCTAssert(!elementsQuery2.staticTexts["Invoice"].isHittable)
        

    }
    
    func testSearchView() throws {
        
        
        app.launch()
        let tabBar = app.tabBars["Tab Bar"]
        tabBar.buttons["Settings"].tap()
        
        //generate recepits
        let elementsQuery = app.scrollViews["ReceiptHomeView"].otherElements
        elementsQuery.buttons["Delete All"].tap()
        elementsQuery.buttons["Generate Receipts"].tap()
        tabBar.buttons["Home"].tap()
        
        //check searcbar
        app.textFields["SearchBar"].tap()
        app.textFields["SearchBar"].typeText("J")
        sleep(5)
        XCTAssert(app.staticTexts["Jb Hifi"].exists)
        app.textFields["SearchBar"].typeText("I")
        XCTAssert(!app.staticTexts["Jb Hifi"].exists)
                        
       
    }
    
    func testScanView() throws {
        
        app.launch()
        let tabBar = XCUIApplication().tabBars["Tab Bar"]
        
        tabBar.buttons["Scan"].forceTap()
        XCTAssertEqual(app.staticTexts["Scan."].exists, app.staticTexts["Scan."].isHittable)
        
        
        app.tabBars["Tab Bar"].buttons["Scan"].tap()
        app/*@START_MENU_TOKEN@*/.buttons["Add from Gallery"]/*[[".buttons[\"photo\"]",".buttons[\"Add from Gallery\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.forceTap()
        XCTAssert(!app/*@START_MENU_TOKEN@*/.buttons["Add from Gallery"]/*[[".buttons[\"photo\"]",".buttons[\"Add from Gallery\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.exists)
        
        app.terminate()
        app.launch()
        
        tabBar.buttons["Scan"].forceTap()
        XCTAssertEqual(app.staticTexts["Scan."].exists, app.staticTexts["Scan."].isHittable)
        
        
        app.tabBars["Tab Bar"].buttons["Scan"].tap()
        app.buttons["Add from Camera"].forceTap()
        
        XCTAssert(app/*@START_MENU_TOKEN@*/.staticTexts["CameraSimCheck"]/*[[".staticTexts[\"Camera not supported in the simulator!\\n\\nPlease use a physical device.\"]",".staticTexts[\"CameraSimCheck\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.exists)
        
        

        
        
        
    }
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    

    public func isTesting() -> Bool {
        return (ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil || ProcessInfo().arguments.contains("testMode"))
    }
}

extension XCUIElement {
    func forceTap() {
        coordinate(withNormalizedOffset: CGVector(dx:0.5, dy:0.5)).tap()
    }
}


