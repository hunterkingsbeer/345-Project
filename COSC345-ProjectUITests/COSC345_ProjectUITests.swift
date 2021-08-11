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
        buttons["Add from Camera"].tap()
        buttons["Add from Camera"].tap()
        // assert for camera view
        sleep(3)
        let cameraText = app.staticTexts["CameraSimCheck"]// checking if its in the sim or not
        sleep(2)
        XCTAssertEqual(cameraText.label, "Camera not supported in the simulator!\n\nPlease use a physical device.") // checks for
                        
    }

    func testMainSettings() throws {
        app.terminate()
        app.launch()
        app.buttons["Settings"].tap()
        app.switches["DarkModeToggle"].tap()
        sleep(2)
        //XCTAssert(switches["DarkModeToggle"].value as? Int != temp as? Int)
        //dark mode toggle assert
        

    }
    
//    func testMainView() throws {
//        app.launch()
//        self.load(urlString: "https://th.bing.com/th/id/R.337b44db5d3df726ce00b185c9373c59?rik=AAtf2NG4m90OsQ&riu=http%3a%2f%2fwww.angryasianman.com%2fimages%2fangry%2fbebe_yokoono01.jpg&ehk=fd5IonSO0pSqQy4mpynFUtFhW8CHqSWWRgf1n9t06TI%3d&risl=&pid=ImgRaw&r=0")
//        let image: UIImageView = UIImageView(image: image)
//    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func load(urlString : String) {
        guard let url = URL(string: urlString)else {
            return
        }
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }

  

}

