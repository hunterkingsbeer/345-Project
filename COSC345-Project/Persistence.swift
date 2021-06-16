//
//  Persistence.swift
//  COSC345-Project
//
//  Created by Hunter Kingsbeer on 7/05/21.
//

import CoreData
import SwiftUI

/// Initializes default Core Data information with example Core Data entries when previewing the application within Xcode, also holds the context in relation to Core Data
struct PersistenceController {
    
    static let shared = PersistenceController()
 

    static var preview: PersistenceController = {

        let result = PersistenceController(inMemory: true)
        /// Context in relation to Core Data
        let viewContext = result.container.viewContext
        
        let newFolder = Folder(context: viewContext)
        newFolder.title = "groceries".capitalized
        newFolder.color = "green"
        newFolder.icon = "folder"
        newFolder.id = UUID()
        newFolder.favorite = false
        
        save(viewContext: viewContext)
        
        for index in 0..<10 {
            let newReceipt = Receipt(context: viewContext)
            newReceipt.body = "BODY TEXT EXAMPLE"
            newReceipt.date = Date()
            newReceipt.id = UUID()
            newReceipt.store = "Example Store"
            newReceipt.folder = Prediction.predictFolderType(text: ((newReceipt.store ?? "") + (newReceipt.body ?? "")))
            newReceipt.tags = "tag1,tag2,tag3,tag4"
            newReceipt.warrenty = ""
            newReceipt.total = Double(index)
        }
                
        save(viewContext: viewContext)
        return result
    }()

    let container: NSPersistentContainer
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "COSC345_Project")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                /* Typical reasons for an error here include:
                * The parent directory does not exist, cannot be created, or disallows writing.
                * The persistent store is not accessible, due to permissions or data
                * protection when the device is locked.
                * The device is out of space.
                * The store could not be migrated to the current model version.
                * Check the error message to determine what the actual problem was. */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
    
    func getContext() -> NSManagedObjectContext {
        return container.viewContext
    }
    
    static func save(viewContext: NSManagedObjectContext) {
        do {
            try  viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
}
