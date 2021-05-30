//
//  UserSettings.swift
//  COSC345-Project
//
//  Created by Hunter Kingsbeer on 28/05/21.
//

import Foundation
import SwiftUI
import Combine

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
    
    @Published var contrast: Bool {
        didSet {
            UserDefaults.standard.set(contrast, forKey: "contrast")
        }
    }
    
    @Published var style: Int {
        didSet {
            UserDefaults.standard.set(style, forKey: "style")
        }
    }

    init() {
        self.darkMode = UserDefaults.standard.object(forKey: "darkMode") as? Bool ?? true
        self.minimal = UserDefaults.standard.object(forKey: "minimal") as? Bool ?? false
        self.contrast = UserDefaults.standard.object(forKey: "contrast") as? Bool ?? false
        self.style = UserDefaults.standard.object(forKey: "style") as? Int ?? 0
    }
}
