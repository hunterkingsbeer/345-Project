//
//  COSC345App.swift
//  COSC345
//
//  Created by Hunter Kingsbeer on 18/04/21.
//

import SwiftUI

/**
 elite bois
 */
@main
struct COSC345App: App {
    let persistenceController = PersistenceController.shared
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
