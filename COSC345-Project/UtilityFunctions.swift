//
//  UtilityFunctions.swift
//  COSC345-Project
//
//  Created by Hunter Kingsbeer on 28/05/21.
//

import Foundation
import SwiftUI
import CoreData
import Swift

extension Color {

    var rgb: (red: Double, green: Double, blue: Double, o: Double)? {
        let uiColor: UIColor
        
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var o: CGFloat = 0
        
        if self.description.contains("NamedColor") {
            let lowerBound = self.description.range(of: "name: \"")!.upperBound
            let upperBound = self.description.range(of: "\", bundle")!.lowerBound
            let assetsName = String(self.description[lowerBound..<upperBound])
            
            uiColor = UIColor(named: assetsName)!
        } else {
            uiColor = UIColor(self)
        }

        guard uiColor.getRed(&r, green: &g, blue: &b, alpha: &o) else { return nil }
        
        return (Double(r), Double(g), Double(b), Double(o))
    }
}

struct Blur: UIViewRepresentable {
    var effect: UIVisualEffect?
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { uiView.effect = effect }
}

func hapticFeedback(type: UIImpactFeedbackGenerator.FeedbackStyle){
    UIImpactFeedbackGenerator(style: type).impactOccurred()
}

/// ``getDate``
/// is used to convert an optional Date value into a formatted date in a String type.
/// - Format: EEEE, d MMM yyyy. (E.g. : Wednesday, 11 Aug 2021.)
/// - Parameter date: The Date variable that will be converted into a formatted String.
/// - Returns
///     - The formatted date in a String type.
func getDate(date: Date?) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEEE, d MMM yyyy."
    return formatter.string(from: date ?? Date())
}

/// ``isTesting``
/// is used to check if the environment is being tested via UITests or Tests.
/// - Parameters
///     -    None required.
/// - Returns
///     - True if the environment is in testing.
///     - False if the environment is not in testing.
public func isTesting() -> Bool {
    return (ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil || ProcessInfo().arguments.contains("testMode"))
}

extension UIScreen {
    /// Returns the UIScreens size of width in the form of a CGFloat
    static let screenWidth = UIScreen.main.bounds.size.width
    /// Returns the UIScreens size of height in the form of a CGFloat
    static let screenHeight = UIScreen.main.bounds.size.height
    /// Returns the UIScreens size of width and height in the form of a CGFloat
    static let screenSize = UIScreen.main.bounds.size
}

extension View {
    /// ``underlineTextField``
    /// is a property than can be applied to any View object to provide a predetermined underline to it. However, this is specifically designed to be applied to text.
    /// - Returns
    ///     - A (text) view with an underline.
    func underlineTextField(opacity: Double = 1) -> some View {
        self
            .padding(.vertical, 10)
            .overlay(Rectangle()
                        .opacity(opacity)
                        .frame(height: 2)
                        .padding(.top, 45))
            .padding(10)
    }
    
    /// ``dropShadow``
    /// is a property than can be applied to any View object to provide a desired shadow on it. This is a quality of life function, and only serves to make the calling parameters more straight forward while using an already set shadow color.
    ///
    /// - Parameter on: True if you want the shadow on. False if you want to turn it off. Handy for hooking into UserSettings.
    /// - Parameter opacity: Adjusts the opacity of the shadow.
    /// - Parameter radius: Adjusts the radius of the shadow.
    /// - Returns
    ///     - A shadow as specified in the params.
    func dropShadow(isOn: Bool, opacity: Double, radius: CGFloat) -> some View {
        self
            .shadow(color: Color("shadow").opacity(isOn ? opacity : 0.0), radius: radius)
    }
}

extension Image {
    /// Overrides the Image(data: Data) parameter to allow for optional values without a default value. This is a quality of life function, serving to make code look prettier.
    /// - Parameter data: The data to be translated into an image.
    public init?(data: Data?) {
        guard let data = data,
            let uiImage = UIImage(data: data) else {
                return nil
        }
        self = Image(uiImage: uiImage)
    }
}

extension UIDevice {
    /// ``inSimulator``
    /// is used to check if the environment is in the simulator or not.
    /// - True if the environment is in the simulator.
    /// - False if the environment is not in the simulator.
    var inSimulator: Bool {
        return TARGET_OS_SIMULATOR != 0
    }
}

/// ``ShrinkingButton``
/// is a ButtonStyle that transforms a button when tapped.
/// It scales the button from 1 to 0.98 its size, to give a shrinking effect.
struct ShrinkingButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeInOut)
    }
}

extension UIApplication {
    /// ``endEditing``
    /// is a function that can be called to dismiss the keyboard. This is useful when needing a button to dismiss the keyboard.
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension Color {
    /// ``colors``
    /// is an array of tuples that hold Color types, associated with the UserSettings Style setting.
    /// Can be called by using 'Color.colors'
    /// - Usage with UserSettings: colors[userSettings.style].
    /// - Format: (leading: Color(The leading color of a linear gradient), trailing: Color(The trailing color of a linear gradient))
    static let colors = ["UIContrast", "UI1", "UI2", "UI3", "UI4", "UI5", "UI6", "UI7", "UI8", "UI9",
                         "UI10", "UI11", "UI12", "UI13", "UI14", "UI15", "UI16"]
}

/// ``Loading``
/// is a loading screen than can be called to display a loading animation. This displays a rotating sun icon.
struct Loading: View {
    @State var rotation: Double = 0
    var body: some View {
        Image(systemName: "sun.min")
            .font(.largeTitle)
            .rotationEffect(.degrees(getRotation()))
            .animation(.spring())
    }
    
    func getRotation() -> Double {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            rotation += 100
        }
        return rotation
    }
}

/// ``TabPage``
/// is an enum of type Int. It is used to control the ContentView's tabview's active page in the TabSelection.changeTab function.
enum TabPage: Int {
    ///``home``: When this is active it will change the TabView to index 0, resulting in HomeView being active.
    case home = 0
    ///``home``: When this is active it will change the TabView to index 1, resulting in ScanView being active.
    case scan = 1
    ///``home``: When this is active it will change the TabView to index 2, resulting in SettingsView being active.
    case settings = 2
}

/// ``TabSelection``
///  is an Observable Object class that allows application wide control of the active tab.
///  This class is placed as an environment object in the App struct, allowing all views to update the active tab in sync.
class TabSelection: ObservableObject {
    ///``selection``: Used to set the active tab of the ContentView's TabView. Controlled either by directly setting, or through the changeTab function.
    @Published var selection: Int
    
    /// Initializes the selection to the index,
    init() {
        self.selection = 0
    }
    
    /// Used to change the active tab using a TabPage value. This allows for easy tab changing, meaning we don't need to remember the raw values of each page.
    /// - Parameter tabPage: The new tab you want to be active [.home, .scan. or .settings].
    func changeTab(tabPage: TabPage) {
        self.selection = tabPage.rawValue
    }
}
