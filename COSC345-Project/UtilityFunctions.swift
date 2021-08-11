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

// --------------------------------------------------------- UTILITIES

/// Formats and returns date (Format E.g. : Wednesday, 11 Aug 2021.)
func getDate(date: Date?) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEEE, d MMM yyyy."
    return formatter.string(from: date ?? Date())
}

/// Retrieves the screen size of the user's device.
extension UIScreen {
   static let screenWidth = UIScreen.main.bounds.size.width
   static let screenHeight = UIScreen.main.bounds.size.height
   static let screenSize = UIScreen.main.bounds.size
}

extension UIView {
    /// Rounds specific corners of a view.
    /// USAGE: view.roundCorners([.topLeft, .bottomRight], radius: 10)
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
         let path = UIBezierPath(roundedRect: self.bounds,
                                 byRoundingCorners: corners,
                                 cornerRadii: CGSize(width: radius, height: radius))
         let mask = CAShapeLayer()
         mask.path = path.cgPath
         self.layer.mask = mask
    }
}

extension View {
    func underlineTextField() -> some View {
        self
            .padding(.vertical, 10)
            .overlay(Rectangle().frame(height: 2).padding(.top, 45))
            .padding(10)
    }
    
    func dropShadow(on: Bool, opacity: Double, radius: CGFloat) -> some View {
        self
            .shadow(color: Color("shadow").opacity(on ? opacity : 0.0), radius: radius)
    }
}

extension Image {
    public init?(data: Data?) {
        guard let data = data,
            let uiImage = UIImage(data: data) else {
                return nil
        }
        self = Image(uiImage: uiImage)
    }
}

extension UIDevice {
    var isSimulator: Bool {
        return TARGET_OS_SIMULATOR != 0
    }
}

/// Shrinking animation for the UI buttons.
struct ShrinkingButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.99 : 1)
            .animation(.spring())
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// Normal TextField doesn't allow colored placeholder text, this does. SOLUTION FOUND AT THIS LINK https://stackoverflow.com/questions/57688242/swiftui-how-to-change-the-placeholder-color-of-the-textfield
/// Workaround to allow for coloured placeholder text.
struct CustomTextField: View {
    var placeholder: Text
    @Binding var text: String
    var font: Font = .body
    var editingChanged: (Bool) -> Void = { _ in }
    var commit: () -> Void = { }

    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty { placeholder }
            TextField("", text: $text, onEditingChanged: editingChanged, onCommit: commit)
        }.font(font)
    }
}

// --------------------------------------------------------- COLORS
/// Extension of the Color object
extension Color {
    /// Define all gradient schemes for the background colours. Two colours each gradient, top and bottom.
    static let colors = [(leading: Color("object"), trailing: Color("accent"), text: Color("text")),
                         (leading: Color("blue"), trailing: Color("lightBlue"), text: Color("blue")),
                         (leading: Color("lightPink"), trailing: Color("purple"), text: Color("lightPink")),
                         (leading: Color("green"), trailing: Color("grass"), text: Color("green"))
    ]
}

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
