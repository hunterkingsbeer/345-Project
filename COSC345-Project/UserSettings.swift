//
//  UserSettings.swift
//  COSC345-Project
//
//  Created by Hunter Kingsbeer on 28/05/21.
//

import Foundation
import SwiftUI
import Combine

///``UserSettings``
/// is an ObservableObject that is used as an environment object throughout the application to retrieve and set user settings in sync.
class UserSettings: ObservableObject {
    ///``darkMode`` is a Boolean that controls the applications UI dark mode setting. True results in dark mode, whereas False results in light mode.
    @Published var darkMode: Bool {
        didSet {
            UserDefaults.standard.set(darkMode, forKey: "darkMode")
        }
    }
    ///``style`` is an Int that controls the index of the color style array used in the accent colors of the applicaiton.
    @Published var style: Int {
        didSet {
            UserDefaults.standard.set(style, forKey: "style")
        }
    }
    ///``thinFolders`` is a Boolean that controls whether the folders in HomeView are the original thinner version (true), or the newer bigger version (false).
    @Published var thinFolders: Bool {
        didSet {
            UserDefaults.standard.set(thinFolders, forKey: "thinFolders")
        }
    }
    ///``shadows`` is a Boolean that controls whether the shadows appear on folders and receipt objects in HomeView. True for shadows enabled, False for shadows disabled.
    @Published var shadows: Bool {
        didSet {
            UserDefaults.standard.set(shadows, forKey: "shadows")
        }
    }

    ///Initializes the variables to their default variables if not already set.
    init() {
        /// Dark mode defaults to false. Light mode Enabled by default.
        self.darkMode = UserDefaults.standard.object(forKey: "darkMode") as? Bool ?? false
        /// Shadows defaults to true. Shadows Enabled by default.
        self.shadows = UserDefaults.standard.object(forKey: "shadows") as? Bool ?? true
        /// Style defaults to 0. Style color set to "text" by default.
        self.style = UserDefaults.standard.object(forKey: "style") as? Int ?? 0
        /// Thin folders defaults to true. Thin folders Enabled by default.
        self.thinFolders = UserDefaults.standard.object(forKey: "thinFolders") as? Bool ?? true
    }
}
