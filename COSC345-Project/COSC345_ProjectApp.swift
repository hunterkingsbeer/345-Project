//
//  COSC345_ProjectApp.swift
//  COSC345-Project
//
// Created by Hunter Kingsbeer on 7/05/21.
//

import SwiftUI

@main
/// Initializes the application.
struct COSC345_ProjectApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(UserSettings())
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
