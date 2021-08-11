//
//  UserSettings.swift
//  COSC345-Project
//
//  Created by Hunter Kingsbeer on 28/05/21.
//

import Foundation
import SwiftUI
import Combine

/// Class of settings that the user may specify, impacting the interface.
class UserSettings: ObservableObject {
    @Published var darkMode: Bool {
        didSet {
            UserDefaults.standard.set(darkMode, forKey: "darkMode")
        }
    }
    
    @Published var minimal: Bool {
        didSet {
            UserDefaults.standard.set(minimal, forKey: "minimal")
        }
    }
    
    @Published var style: Int {
        didSet {
            UserDefaults.standard.set(style, forKey: "style")
        }
    }
    
    @Published var thinFolders: Bool {
        didSet {
            UserDefaults.standard.set(thinFolders, forKey: "thinFolders")
        }
    }

    /// Default settings.
    init() {
        /// Dark mode.
        self.darkMode = UserDefaults.standard.object(forKey: "darkMode") as? Bool ?? true
        /// Mimimal mode.
        self.minimal = UserDefaults.standard.object(forKey: "minimal") as? Bool ?? false
        /// Colour scheme for background gradients.
        self.style = UserDefaults.standard.object(forKey: "style") as? Int ?? 0
        
        self.thinFolders = UserDefaults.standard.object(forKey: "thinFolders") as? Bool ?? false
    }
}
