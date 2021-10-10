//
//  UserSettings.swift
//  COSC345-Project
//
//  Created by Hunter Kingsbeer on 28/05/21.
//

import Foundation
import SwiftUI
import Combine

enum ScanDefault: Int {
    case choose = 0
    case camera = 1
    case gallery = 2
}

///``UserSettings``
/// is an ObservableObject that is used as an environment object throughout the application to retrieve and set user settings in sync.
class UserSettings: ObservableObject {
    ///``darkMode`` is a Boolean that controls the applications UI dark mode setting. True results in dark mode, whereas False results in light mode.
    @Published var darkMode: Bool {
        didSet {
            UserDefaults.standard.set(darkMode, forKey: "darkMode")
        }
    }
    ///``accentColor`` is an Int that controls the index of the color style array used in the accent colors of the applicaiton.
    @Published var accentColor: String {
        didSet {
            UserDefaults.standard.set(accentColor, forKey: "accentColor")
        }
    }
    
    ///``autocomplete`` is a Boolean that controls whether the scanner will ask for confirmation of a correct scan. True will disable confirmation, False will enable comfirmation.
    @Published var autocomplete: Bool {
        didSet {
            UserDefaults.standard.set(autocomplete, forKey: "autocomplete")
        }
    }
    
    ///``devMode`` is a Boolean that controls whether the Settings show the developer options. True for dev mode, false for regular mode.
    @Published var devMode: Bool {
        didSet {
            UserDefaults.standard.set(devMode, forKey: "devMode")
        }
    }
    
    ///``scanDefault`` is a ScanDefault that picks a default for the users scan method. 0 will give the user the option, 1 defaults to document scanner, and 2 default to image picker.
    @Published var scanDefault: Int {
        didSet {
            UserDefaults.standard.set(scanDefault, forKey: "scanDefault")
        }
    }
    
    ///``firstUse`` is a Boolean that holds whether a user is using the app for the first time. True if its a first use, false if not.
    @Published var firstUse: Bool {
        didSet {
            UserDefaults.standard.set(firstUse, forKey: "firstUse")
        }
    }
    
    ///``passcodeProtection`` is a Boolean that enabled passcode protection, requiring a passcode for access.
    @Published var passcodeProtection: Bool {
        didSet {
            UserDefaults.standard.set(passcodeProtection, forKey: "passcodeProtection")
        }
    }
    
    ///``passcode`` holds the users passcode used for passcode protection.
    @Published var passcode: String {
        didSet {
            UserDefaults.standard.set(passcode, forKey: "passcode")
        }
    }

    ///Initializes the variables to their default variables if not already set.
    init() {
        /// Dark mode defaults to false. Light mode Enabled by default.
        self.darkMode = UserDefaults.standard.object(forKey: "darkMode") as? Bool ?? false
        /// Accent color defaults to "UI2". Color is Receipted Fluro Green by default.
        self.accentColor = UserDefaults.standard.object(forKey: "accentColor") as? String ?? "UI2"
        /// Auto Complete defaults to false. Confirmation by user required by default.
        self.autocomplete = UserDefaults.standard.object(forKey: "autocomplete") as? Bool ?? false
        /// Dev Mode defaults to false. Regular mode enabled by default.
        self.devMode = UserDefaults.standard.object(forKey: "devMode") as? Bool ?? false
        /// Scan Default defaults to choose. Allows user to choose their scan method.
        self.scanDefault = UserDefaults.standard.object(forKey: "scanDefault") as? Int ?? 0
        /// First Use defaults to true, once the user loads up the app for its first use its set to false.
        self.firstUse = UserDefaults.standard.object(forKey: "firstUse") as? Bool ?? true
        /// Passcode Protection defaults to false, requiring the user to enable it if desired.
        self.passcodeProtection = UserDefaults.standard.object(forKey: "passcodeProtection") as? Bool ?? false
        /// Passcode defaults to 0000, in a temporary disabled state.
        self.passcode = UserDefaults.standard.object(forKey: "passcode") as? String ?? "0000"
    }
}
