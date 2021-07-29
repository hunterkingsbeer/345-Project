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

/// Retrieves the screen size of the user's device.
extension UIScreen {
   static let screenWidth = UIScreen.main.bounds.size.width
   static let screenHeight = UIScreen.main.bounds.size.height
   static let screenSize = UIScreen.main.bounds.size
}

extension UIDevice {
    var isSimulator: Bool {
        return TARGET_OS_SIMULATOR != 0
    }
}

/// Shrinking a=nimation for the UI buttons.
struct ShrinkingButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.99 : 1)
            .animation(.spring())
    }
}

// Normal TextField doesn't allow colored placeholder text, this does. SOLUTION FOUND AT THIS LINK https://stackoverflow.com/questions/57688242/swiftui-how-to-change-the-placeholder-color-of-the-textfield
/// Workaround to allow for coloured placeholder text.
struct CustomTextField: View {
    var placeholder: Text
    @Binding var text: String
    var editingChanged: (Bool) -> Void = { _ in }
    var commit: () -> Void = { }

    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty { placeholder }
            TextField("", text: $text, onEditingChanged: editingChanged, onCommit: commit)
        }
    }
}

// --------------------------------------------------------- COLORS
/// Extension of the Color object
extension Color {
    /// Define all gradient schemes for the background colours. Two colours each gradient, top and bottom.
    static let colors = [(top1: Color("purple"), top2: Color("orange"),
                          bottom1: Color("cyan"), bottom2: Color("purple")),
                         
                         (top1: Color("green"), top2: Color("cyan"),
                          bottom1: Color("cyan"), bottom2: Color("blue")),
                         
                         (top1: Color("object"), top2: Color("text"),
                          bottom1: Color("object"), bottom2: Color("text"))]
    
    /// Returns the defined colours
    static func getColors() -> [(top1: Color, top2: Color, bottom1: Color, bottom2: Color)] {
        return colors
    }
}
