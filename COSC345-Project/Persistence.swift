//
//  Persistence.swift
//  COSC345-Project
//
//  Created by Hunter Kingsbeer on 7/05/21.
//

import CoreData
import SwiftUI

///``PersistenceController``
/// is a struct that is used to control the CoreData database entities.
/// In here, we set the previews fake values so we have something to view in the canvas preview within Xcode.
struct PersistenceController {
    ///``shared`` allows the PersistanceController to be accessed as an object outside of this struct.
    static let shared = PersistenceController()
    ///``preview`` initializes Xcode's canvas database with the specified values.
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        for folder in Folder.folders {
            let newFolder = Folder(context: viewContext)
            newFolder.title = folder.title.capitalized
            newFolder.color = folder.color
            newFolder.icon = folder.icon
            newFolder.id = UUID()
        }
        
        save(viewContext: viewContext)
        
        for index in 0..<10 {
            let newReceipt = Receipt(context: viewContext)
            newReceipt.body = "BODY TEXT EXAMPLE"
            newReceipt.date = Date()
            newReceipt.id = UUID()
            newReceipt.title = "Example Store"
            newReceipt.folder = Prediction.pointPrediction(text: ((newReceipt.title ?? "") + (newReceipt.body ?? "")))
        }
                
        save(viewContext: viewContext)
        return result
    }()

    ///``container`` is a NSPersistentContainer that holds the apps database.
    let container: NSPersistentContainer
    /// The applications container is initialized.
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "COSC345_Project")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
            /// Typical reasons for an error here include:
            /// The parent directory does not exist, cannot be created, or disallows writing.
            /// The persistent store is not accessible, due to permissions or data
            /// protection when the device is locked.
            /// The device is out of space.
            /// The store could not be migrated to the current model version.
            /// Check the error message to determine what the actual problem was. */
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
    
    ///``getContext``
    /// allows application wide access to the databases context.
    /// If the view creates its own context, the database will be out of sync, therefore usage of this is important.
    /// - Returns: the context of the database.
    func getContext() -> NSManagedObjectContext {
        return container.viewContext
    }
    
    ///``save``
    /// Used to save the context to confirm changes with the CoreData database.
    /// This should be performed after any changes to the database entities.
    static func save(viewContext: NSManagedObjectContext) {
        let viewContext = shared.getContext()
        do {
            try  viewContext.save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
            /// Replace this implementation with code to handle the error appropriately.
            /// fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
    }
}
