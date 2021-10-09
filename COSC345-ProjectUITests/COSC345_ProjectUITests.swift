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
        app.launchArguments = ["testMode"]
        app.launch()
        passcodeCheck()
        let tabBar = XCUIApplication().tabBars["Tab Bar"]
        
        XCTAssertEqual(app.images["Search"].exists, app.images["Search"].isHittable)
        
        tabBar.buttons["Scan"].forceTap()
        XCTAssertEqual(app.staticTexts["Scan."].exists, app.staticTexts["Scan."].isHittable)
        
        tabBar.buttons["Settings"].forceTap()
        XCTAssertEqual(app.staticTexts["Settings."].exists, app.staticTexts["Settings."].exists)
    }
    
    func testSettingsView() throws {
        app.launchArguments = ["testMode"]
        app.launch()
        passcodeCheck()
        
        let tabBar = app.tabBars["Tab Bar"]
        tabBar.buttons["Settings"].forceTap()
        
        if app.switches["DarkModeToggle: true"].exists {
            var darkMode = app.switches["DarkModeToggle: true"]
            darkMode.forceTap()
            darkMode = app.switches["DarkModeToggle: false"]
            tabBar.buttons["Settings"].forceTap() // will remove one the toggle to home screen issue is fixed
            XCTAssert(darkMode.identifier == "DarkModeToggle: false")
        }
    }

    func testFolderView() throws {
        
        let app = XCUIApplication()
        app.launchArguments = ["testMode"]
        app.launch()
        passcodeCheck()
        let tabBar = app.tabBars["Tab Bar"]
        tabBar.buttons["Settings"].tap()
        
        //generate recepits
        var elementsQuery = app.scrollViews["ReceiptHomeView"].otherElements
        tabBar.buttons["Settings"].tap()
        
        let scrollViewsQuery = app.scrollViews
        elementsQuery = scrollViewsQuery.otherElements
        if(app.scrollViews.otherElements.staticTexts["PASSCODE DISABLED "].exists || app.scrollViews.otherElements.staticTexts["PASSCODE ENABLED "].exists){
            app.buttons["hammer.fill"].tap()
        }
        
        
        scrollViewsQuery.otherElements.buttons["DELETE ALL"].tap()
        scrollViewsQuery.otherElements.containing(.button, identifier:"LIGHT MODE").element/*@START_MENU_TOKEN@*/.swipeLeft()/*[[".swipeUp()",".swipeLeft()"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        elementsQuery.buttons["+10 RECEIPTS"].tap()
        tabBar.buttons["Home"].tap()
        
        //check recepits
        let elementsQuery2 = app.scrollViews.otherElements
        elementsQuery2.buttons["1 Technology."].tap()
        
        XCTAssert(elementsQuery2.staticTexts["Jb Hifi"].exists)
        elementsQuery2.buttons["1 Default."].tap()
        XCTAssert(!elementsQuery2.staticTexts["Jb Hifi"].exists)
       
        app.scrollViews.otherElements.staticTexts["Invoice"].tap()
                
        sleep(2)

        XCTAssert(!elementsQuery2.staticTexts["Invoice"].isHittable)
        
        XCUIApplication().windows.children(matching: .other).element.children(matching: .other).element(boundBy: 0).swipeDown()
                
        sleep(5)
        XCTAssert(elementsQuery2.staticTexts["Invoice"].isHittable)
        
        
        elementsQuery2.staticTexts["Invoice"].tap()
        sleep(2)
        app.buttons["photo"].tap()
        
        XCTAssert(!app.buttons["trash"].firstMatch.isHittable)
       // this should be passing just fine
        
        app.buttons["photo"].tap()
        XCTAssert(XCUIApplication().buttons["photo"].firstMatch.exists)
        
        app.buttons["trash"].tap()
        app.buttons["trash"].tap()
        
        XCTAssert(!elementsQuery2.staticTexts["Invoice"].isHittable)
        
    }
    
    func testPassView() throws {

        let app = XCUIApplication()
        app.launchArguments = ["testMode"]
    
        app.launch()
        passcodeCheck()
        let tabBar = app.tabBars["Tab Bar"]
        let settingsButton = tabBar.buttons["Settings"]
        settingsButton.tap()
        
        let elementsQuery = app.scrollViews.otherElements
        
        elementsQuery.buttons["lock.slash"].forceTap()

        
        let button = app.buttons["1"]
        button.forceTap()
        
        let button2 = app.buttons["2"]
        button2.forceTap()
        
        let button3 = app.buttons["3"]
        button3.forceTap()
        
        let button4 = app.buttons["4"]
        button4.forceTap()
        sleep(2)
        button.tap()
        button2.tap()
        button3.tap()
        button4.tap()
        sleep(2)
        app.terminate()
        app.launchArguments = ["testMode"]
        app.launch()
        passcodeCheck()
        XCTAssert(app.images["magnifyingglass"].exists)
    }
    
    func testSearchView() throws {
        app.launchArguments = ["testMode"]
        app.launch()
        let tabBar = app.tabBars["Tab Bar"]
        passcodeCheck()
        
        
        app.launchArguments = ["testMode"]
        
        sleep(2)
        tabBar.buttons["Settings"].tap()
        
        
        
        let app = XCUIApplication()
        let settingsButton = app.tabBars["Tab Bar"].buttons["Settings"]
        settingsButton.tap()
        if(app.scrollViews.otherElements.staticTexts["PASSCODE DISABLED"].exists){
            app.buttons["hammer.fill"].tap()
        }
        
        let scrollViewsQuery = app.scrollViews
        scrollViewsQuery.otherElements.containing(.button, identifier:"LIGHT MODE").element/*@START_MENU_TOKEN@*/.swipeLeft()/*[[".swipeUp()",".swipeLeft()"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
    
        scrollViewsQuery.otherElements.buttons["DELETE ALL"].tap()
        //generate recepits
        var elementsQuery = app.scrollViews["ReceiptHomeView"].otherElements
        XCUIApplication().scrollViews.otherElements.buttons["DELETE ALL"].tap()
        elementsQuery = scrollViewsQuery.otherElements
        scrollViewsQuery.otherElements.containing(.button, identifier:"LIGHT MODE").element/*@START_MENU_TOKEN@*/.swipeLeft()/*[[".swipeUp()",".swipeLeft()"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        elementsQuery.buttons["+10 RECEIPTS"].tap()
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
        app.launchArguments = ["testMode"]
        app.launch()
        passcodeCheck()
        let tabBar = XCUIApplication().tabBars["Tab Bar"]
        
        tabBar.buttons["Scan"].forceTap()
        XCTAssertEqual(app.staticTexts["Scan."].exists, app.staticTexts["Scan."].isHittable)
        
        app.tabBars["Tab Bar"].buttons["Scan"].tap()
        app/*@START_MENU_TOKEN@*/.buttons["Add from Gallery"]/*[[".buttons[\"photo\"]",".buttons[\"Add from Gallery\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.forceTap()
        XCTAssert(!app/*@START_MENU_TOKEN@*/.buttons["Add from Gallery"]/*[[".buttons[\"photo\"]",".buttons[\"Add from Gallery\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.exists)
        
        app.terminate()
        app.launchArguments = ["testMode"]
        app.launch()
        passcodeCheck()
        
        tabBar.buttons["Scan"].forceTap()
        XCTAssertEqual(app.staticTexts["Scan."].exists, app.staticTexts["Scan."].isHittable)
        
        
        app.tabBars["Tab Bar"].buttons["Scan"].tap()
        app.buttons["Add from Camera"].forceTap()
        
        XCTAssert(app/*@START_MENU_TOKEN@*/.staticTexts["CameraSimCheck"]/*[[".staticTexts[\"Camera not supported in the simulator!\\n\\nPlease use a physical device.\"]",".staticTexts[\"CameraSimCheck\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.exists)
    }
    
    func testGalleryView() throws {
        let app = XCUIApplication()
        app.launch()
        passcodeCheck()
        
        XCUIDevice.shared.press(XCUIDevice.Button.home)
        let app2 = XCUIApplication(bundleIdentifier: "com.apple.mobilesafari")
        app2.launch()
        app2/*@START_MENU_TOKEN@*/.otherElements["URL"]/*[[".otherElements[\"SafariWindow?View=Narrow&BarsKeptMinimized=false&UUID=DE97B6C6-8E1F-4A40-804D-780FB54E9C0D&SupportsTabBar=false\"]",".otherElements[\"TopBrowserBar\"]",".buttons[\"Address\"]",".otherElements[\"Address\"]",".otherElements[\"URL\"]",".buttons[\"URL\"]"],[[[-1,4],[-1,3],[-1,5,3],[-1,2,3],[-1,1,2],[-1,0,1]],[[-1,4],[-1,3],[-1,5,3],[-1,2,3],[-1,1,2]],[[-1,4],[-1,3],[-1,5,3],[-1,2,3]],[[-1,4],[-1,3]]],[0]]@END_MENU_TOKEN@*/.tap()
        app2.textFields["URL"].typeText("https://i.ibb.co/Xp2C5k6/testRec.jpg")
        app2.buttons["Go"].tap()
        app2.tapCoordinate(at: CGPoint(x: 200, y: 200) )
        app2.collectionViews/*@START_MENU_TOKEN@*/.buttons["Add to Photos"]/*[[".cells.buttons[\"Add to Photos\"]",".buttons[\"Add to Photos\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        XCUIDevice.shared.press(XCUIDevice.Button.home)
        app2.terminate()
        app.launch()
        passcodeCheck()
        app.tabBars["Tab Bar"].buttons["Scan"].tap()
        app/*@START_MENU_TOKEN@*/.buttons["Add from Gallery"]/*[[".buttons[\"photo.fill\"]",".buttons[\"Add from Gallery\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        sleep(5)
        app.scrollViews.otherElements.images.element(boundBy: 0).tap()
        sleep(1)
        XCTAssert(app.staticTexts["Saving..."].exists)
        while app.staticTexts["Saving..."].exists{ continue }
        let tabBar = XCUIApplication().tabBars["Tab Bar"]
        tabBar.buttons["Home"].tap()
        sleep(2)
        
        let scrollViewsQuery = app.scrollViews
        let blondStaticText = scrollViewsQuery.otherElements.containing(.staticText, identifier:"Blond").children(matching: .staticText).matching(identifier: "Blond").element(boundBy: 0)
        XCTAssert(blondStaticText.exists)
 
        
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    public func isTesting() -> Bool {
        return (ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil || ProcessInfo().arguments.contains("testMode"))
    }
    func passcodeCheck(){
        sleep(2)
        let app = XCUIApplication()
        if( XCUIApplication().buttons["lock"].exists){
            app.buttons["1"].tap()
            app.buttons["2"].tap()
            app.buttons["3"].tap()
            app.buttons["4"].tap()
            sleep(2)
        }
    }
}

extension XCUIElement {
    func forceTap() {
        coordinate(withNormalizedOffset:CGVector(dx:0.5, dy:0.5)).tap()
    }
}


extension XCUIApplication {
    func tapCoordinate(at point: CGPoint) {
        let normalized = coordinate(withNormalizedOffset: .zero)
        let offset = CGVector(dx: point.x, dy: point.y)
        let coordinate = normalized.withOffset(offset)
        coordinate.press(forDuration: 4)
    }
}
