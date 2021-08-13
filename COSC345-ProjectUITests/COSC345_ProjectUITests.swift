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
        
        tabBar.buttons["Scan"].tap()
        XCTAssertEqual(app.staticTexts["Scan."].exists, app.staticTexts["Scan."].isHittable)
        
        tabBar.buttons["Settings"].tap()
        XCTAssertEqual(app.staticTexts["Settings."].exists,app.staticTexts["Settings."].exists)
        
    }
    
//    func testSettingsView() throws {
//                        
//        
//        let app = XCUIApplication()
//        app.launch()
//        let tabBar = app.tabBars["Tab Bar"]
//        tabBar.buttons["Settings"].tap()
//        
//        let scrollViewsQuery = app.scrollViews
//        let elementsQuery = scrollViewsQuery
//        //app.switches["DarkModeToggle"].forcetap()
//        elementsQuery.children(matching: .switch).matching(identifier: "0").element(boundBy: 0).tap()
//        elementsQuery.children(matching: .switch).matching(identifier: "0").element(boundBy: 1).tap()
//        
//        let elementsQuery2 = elementsQuery
//        elementsQuery.buttons["Generate Receipts"].tap()
//        tabBar.buttons["Home"].tap()
//        
//        let invoiceElement = scrollViewsQuery.otherElements.containing(.staticText, identifier:"Invoice.").element
//        
//        
//                
//    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    

}

extension XCUIElement {
    func forceTap() {
        coordinate(withNormalizedOffset: CGVector(dx:0.5, dy:0.5)).tap()
    }
}

//extension XCUIApplication {
//    func forceTap() {
//        coordinate(withNormalizedOffset: CGVector(dx:0.5, dy:0.5)).tap()
//    }
//}


//
//        let tabBar = app.tabBars["Tab Bar"]
//        let homeButton = tabBar.buttons["Home"]
//
//        homeButton.tap()
//        tabBar.buttons["Scan"].tap()
//        app.buttons["Add from Camera"].tap()
//
//        let cameraText = app.staticTexts["CameraSimCheck"]// checking if its in the sim or not
//        XCTAssertEqual(cameraText.label, "Camera not supported in the simulator!\n\nPlease use a physical device.")
//
//        app/*@START_MENU_TOKEN@*/.buttons["BackButtonCamera"]/*[[".buttons[\"BACK\"]",".buttons[\"BackButtonCamera\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
//        XCTAssert((app.buttons["Add from Camera"].exists && app.buttons["Add from Camera"].isHittable))
//
//        app.buttons["Add from Gallery"].tap()
//        // app.scrollViews.otherElements.images["Photo, March 31, 2018, 8:14 AM"].tap()
//        // need to add a reciet here to check for valid output
//
//
//        let scanButton = tabBar.buttons["Scan"]
//        scanButton.tap()
//        scanButton.tap()
//        app.buttons["Add from Camera"].tap()
//        app/*@START_MENU_TOKEN@*/.staticTexts["CameraSimCheck"].press(forDuration: 0.5);/*[[".staticTexts[\"Camera not supported in the simulator!\\n\\nPlease use a physical device.\"]",".tap()",".press(forDuration: 0.5);",".staticTexts[\"CameraSimCheck\"]"],[[[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0,0]]@END_MENU_TOKEN@*/
//        app/*@START_MENU_TOKEN@*/.buttons["BackButtonCamera"]/*[[".buttons[\"BACK\"]",".buttons[\"BackButtonCamera\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
//        tabBar.buttons["Settings"].tap()
//
//        let scrollViewsQuery = app.scrollViews
//        let elementsQuery = scrollViewsQuery.otherElements
//        elementsQuery.switches["DarkModeToggle"].tap()
//
//        let darkModeElementsQuery = scrollViewsQuery.otherElements.containing(.staticText, identifier:"Dark Mode")
//        darkModeElementsQuery.children(matching: .switch).matching(identifier: "0").element(boundBy: 0).tap()
//        darkModeElementsQuery.children(matching: .switch).matching(identifier: "0").element(boundBy: 1).tap()
//
//        let elementsQuery2 = elementsQuery
//        elementsQuery2/*@START_MENU_TOKEN@*/.buttons["Style 2"]/*[[".segmentedControls.buttons[\"Style 2\"]",".buttons[\"Style 2\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
//        elementsQuery2/*@START_MENU_TOKEN@*/.buttons["Style 3"]/*[[".segmentedControls.buttons[\"Style 3\"]",".buttons[\"Style 3\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
//        elementsQuery2/*@START_MENU_TOKEN@*/.buttons["Style 4"]/*[[".segmentedControls.buttons[\"Style 4\"]",".buttons[\"Style 4\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
//        elementsQuery2/*@START_MENU_TOKEN@*/.buttons["Style 5"]/*[[".segmentedControls.buttons[\"Style 5\"]",".buttons[\"Style 5\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
//        elementsQuery.buttons["Generate Receipts"].tap()
//        elementsQuery.buttons["Delete All"].tap()
//        tabBar.buttons["Home"].tap()
//        elementsQuery.staticTexts["Tap the 'Scan' button at the bottom."].tap()
//        scanButton.tap()
//
//
//        let tabBar = app.tabBars["Tab Bar"]
//        let settingsButton = tabBar.buttons["Settings"]
//        settingsButton.tap()
//        app.scrollViews.otherElements/*@START_MENU_TOKEN@*/.buttons["Style 1"]/*[[".segmentedControls.buttons[\"Style 1\"]",".buttons[\"Style 1\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        //print(app.scrollViews.otherElements["Horizontal scroll bar, 1 page"].value)


//    func testAddPanel() throws {
//        let buttons = app.buttons
//        app.launch()
//        buttons["Scan"].tap()
//        buttons["Add from Gallery"].tap()
//        sleep(2)
//        app.terminate()
//        app.launch()
//        buttons["Scan"].tap()
//        // xct enum for camera state
//        buttons["Add from Camera"].forceTap()
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
//        app.buttons["Settings"].forceTap()
//        app.switches["DarkModeToggle"].forceTap()
//        sleep(2)
//        //dark mode toggle assert
//
//
//    }
//
