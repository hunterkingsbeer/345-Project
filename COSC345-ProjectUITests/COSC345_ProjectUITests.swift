import XCTest
import UIKit
@testable import COSC345_Project

class COSC345_ProjectUITests: XCTestCase {
    private var image: UIImage?
    
    override func setUp() {
        super.setUp()
    }

    func testHomeView() throws {
        let app = XCUIApplication()
        app.launch()
        let tabBar = XCUIApplication().tabBars["Tab Bar"]
        
        XCTAssertEqual(app.images["Search"].exists, app.images["Search"].isHittable)
        
        tabBar.buttons["Scan"].forceTap()
        XCTAssertEqual(app.staticTexts["Scan."].exists, app.staticTexts["Scan."].isHittable)
        
        tabBar.buttons["Settings"].forceTap()
        XCTAssertEqual(app.staticTexts["Settings."].exists,app.staticTexts["Settings."].exists)
        
    }
    
    
    func testSettingsView() throws {
                        
        let app = XCUIApplication()
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
        
        let app = XCUIApplication()
        app.launch()
        let tabBar = app.tabBars["Tab Bar"]
        tabBar.buttons["Settings"].tap()
        
        //generate recepits
        let elementsQuery = app.scrollViews["ReceiptHomeView"].otherElements
        elementsQuery.buttons["Delete All"].tap()
        elementsQuery.buttons["Generate Receipts"].tap()
        tabBar.buttons["Home"].tap()
        
        //check recepits
        let elementsQuery2 = app.scrollViews.otherElements
        elementsQuery2.buttons["1 Technology"].tap()
        
        XCTAssert(elementsQuery2.staticTexts["Jb Hifi"].exists)
        elementsQuery2.buttons["1 Default"].tap()
        
        XCTAssert(!elementsQuery2.staticTexts["Jb Hifi"].exists)
        elementsQuery2.staticTexts["Invoice"].forceTap()
        XCTAssert(!elementsQuery2.staticTexts["Invoice"].isHittable)
        
        app.buttons["go down"].firstMatch.forceTap()
        XCTAssert(elementsQuery2.staticTexts["Invoice"].isHittable)
        elementsQuery2.staticTexts["Invoice"].forceTap()
        
        app.buttons["photo"].forceTap()
        XCTAssert(!app.buttons["go down"].firstMatch.isHittable)
        
        app.buttons["photo"].forceTap()
        XCTAssert(app.buttons["go down"].firstMatch.exists)
        
        app.buttons["trash"].tap()
        app.buttons["trash"].tap()
        
        XCTAssert(!elementsQuery2.staticTexts["Invoice"].isHittable)
        
        
                
        
                
        
        
        
                
    }
    
    func testSearchView() throws {
        
        let app = XCUIApplication()
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
        let app = XCUIApplication()
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
    

}

extension XCUIElement {
    func forceTap() {
        coordinate(withNormalizedOffset: CGVector(dx:0.5, dy:0.5)).tap()
    }
}
//
//extension XCUIElement {
//
//    func clearAndEnterText(text: String) {
//        guard let stringValue = self.value
//
//        self.tap()
//
//        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
//
//        self.typeText(deleteString)
//        self.typeText(text)
//    }
//}

//extension XCUIApplication {
//    func forceforceTap() {
//        coordinate(withNormalizedOffset: CGVector(dx:0.5, dy:0.5)).forceTap()
//    }
//}


//
//        let tabBar = app.tabBars["Tab Bar"]
//        let homeButton = tabBar.buttons["Home"]
//
//        homeButton.forceTap()
//        tabBar.buttons["Scan"].forceTap()
//        app.buttons["Add from Camera"].forceTap()
//
//        let cameraText = app.staticTexts["CameraSimCheck"]// checking if its in the sim or not
//        XCTAssertEqual(cameraText.label, "Camera not supported in the simulator!\n\nPlease use a physical device.")
//
//        app/*@START_MENU_TOKEN@*/.buttons["BackButtonCamera"]/*[[".buttons[\"BACK\"]",".buttons[\"BackButtonCamera\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.forceTap()
//        XCTAssert((app.buttons["Add from Camera"].exists && app.buttons["Add from Camera"].isHittable))
//
//        app.buttons["Add from Gallery"].forceTap()
//        // app.scrollViews.otherElements.images["Photo, March 31, 2018, 8:14 AM"].forceTap()
//        // need to add a reciet here to check for valid output
//
//
//        let scanButton = tabBar.buttons["Scan"]
//        scanButton.forceTap()
//        scanButton.forceTap()
//        app.buttons["Add from Camera"].forceTap()
//        app/*@START_MENU_TOKEN@*/.staticTexts["CameraSimCheck"].press(forDuration: 0.5);/*[[".staticTexts[\"Camera not supported in the simulator!\\n\\nPlease use a physical device.\"]",".forceTap()",".press(forDuration: 0.5);",".staticTexts[\"CameraSimCheck\"]"],[[[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0,0]]@END_MENU_TOKEN@*/
//        app/*@START_MENU_TOKEN@*/.buttons["BackButtonCamera"]/*[[".buttons[\"BACK\"]",".buttons[\"BackButtonCamera\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.forceTap()
//        tabBar.buttons["Settings"].forceTap()
//
//        let scrollViewsQuery = app.scrollViews
//        let elementsQuery = scrollViewsQuery.otherElements
//        elementsQuery.switches["DarkModeToggle"].forceTap()
//
//        let darkModeElementsQuery = scrollViewsQuery.otherElements.containing(.staticText, identifier:"Dark Mode")
//        darkModeElementsQuery.children(matching: .switch).matching(identifier: "0").element(boundBy: 0).forceTap()
//        darkModeElementsQuery.children(matching: .switch).matching(identifier: "0").element(boundBy: 1).forceTap()
//
//        let elementsQuery2 = elementsQuery
//        elementsQuery2/*@START_MENU_TOKEN@*/.buttons["Style 2"]/*[[".segmentedControls.buttons[\"Style 2\"]",".buttons[\"Style 2\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.forceTap()
//        elementsQuery2/*@START_MENU_TOKEN@*/.buttons["Style 3"]/*[[".segmentedControls.buttons[\"Style 3\"]",".buttons[\"Style 3\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.forceTap()
//        elementsQuery2/*@START_MENU_TOKEN@*/.buttons["Style 4"]/*[[".segmentedControls.buttons[\"Style 4\"]",".buttons[\"Style 4\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.forceTap()
//        elementsQuery2/*@START_MENU_TOKEN@*/.buttons["Style 5"]/*[[".segmentedControls.buttons[\"Style 5\"]",".buttons[\"Style 5\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.forceTap()
//        elementsQuery.buttons["Generate Receipts"].forceTap()
//        elementsQuery.buttons["Delete All"].forceTap()
//        tabBar.buttons["Home"].forceTap()
//        elementsQuery.staticTexts["Tap the 'Scan' button at the bottom."].forceTap()
//        scanButton.forceTap()
//
//
//        let tabBar = app.tabBars["Tab Bar"]
//        let settingsButton = tabBar.buttons["Settings"]
//        settingsButton.forceTap()
//        app.scrollViews.otherElements/*@START_MENU_TOKEN@*/.buttons["Style 1"]/*[[".segmentedControls.buttons[\"Style 1\"]",".buttons[\"Style 1\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.forceTap()
        //print(app.scrollViews.otherElements["Horizontal scroll bar, 1 page"].value)


//    func testAddPanel() throws {
//        let buttons = app.buttons
//        app.launch()
//        buttons["Scan"].forceTap()
//        buttons["Add from Gallery"].forceTap()
//        sleep(2)
//        app.terminate()
//        app.launch()
//        buttons["Scan"].forceTap()
//        // xct enum for camera state
//        buttons["Add from Camera"].forceforceTap()
//        // assert for camera view
//        sleep(3)
//        let cameraText = app.staticTexts["CameraSimCheck"]// checking if its in the sim or not
//        sleep(2)
//        XCTAssertEqual(cameraText.label, "Camera not supported in the simulator!\n\nPlease use a physical device.") // checks for
//
//    }
//
//    func testMainSettings() throws {
//        app.terminate()
//        app.launch()
//        app.buttons["Settings"].forceforceTap()
//        app.switches["DarkModeToggle"].forceforceTap()
//        sleep(2)
//        //dark mode toggle assert
//
//
//    }
//
