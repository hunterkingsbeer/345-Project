//
//  COSC345_ProjectApp.swift
//  COSC345-Project
//
// Created by Hunter Kingsbeer on 7/05/21.
//

import SwiftUI

@main
/// ``COSC345_ProjectApp``
/// is an App that initializes the application on a device. The first struct it calls is ContentView, which forms the basis and acts as the parent of all other views called after.
/// ContentView has the UserSettings and TabSelection environment objects applied to it to allow for application wide modifying of each, as well as viewContext to allow synced database updates.
struct COSC345_ProjectApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(UserSettings())
                .environmentObject(TabSelection())
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
