import XCTest
import UIKit
@testable import COSC345_Project

class COSC345_ProjectUITests: XCTestCase {
    private var app: XCUIApplication!
    private var image: UIImage?
    
    override func setUp() {
        super.setUp()
        self.app = XCUIApplication()
        //self.app.launch()
    }
    func testAddPanel() throws {
        let buttons = app.buttons
        app.launch()
        buttons["Scan"].tap()
        buttons["Add from Gallery"].tap()
        sleep(2)
        app.terminate()
        app.launch()
        buttons["Scan"].tap()
        // xct enum for camera state
        buttons["Add from Camera"].forceTap()
        // assert for camera view
        sleep(3)
        let cameraText = app.staticTexts["CameraSimCheck"]// checking if its in the sim or not
        sleep(2)
        XCTAssertEqual(cameraText.label, "Camera not supported in the simulator!\n\nPlease use a physical device.") // checks for
                        
    }

    func testMainSettings() throws {
        app.terminate()
        app.launch()
        app.buttons["Settings"].forceTap()
        app.switches["DarkModeToggle"].forceTap()
        sleep(2)
        //dark mode toggle assert
        

    }
    
    func testMainScene() throws {
        app.launch()
        
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

