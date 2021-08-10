//
//  Folder.swift
//  COSC345-Project
//
//  Created by Hunter Kingsbeer on 29/07/21.
//

import Foundation
import CoreData
import SwiftUI

/// Tag/Folder
struct TagView: View {
    @ObservedObject var folder: Folder
    var body: some View {
        //let color: String = Folder.getColor(title: folder.title ?? "default")
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(Folder.getColor(title: folder.title ?? "default")))
                //.frame(minWidth: UIScreen.screenWidth * 0.4)
                //.frame(height: UIScreen.screenHeight*0.05)
            HStack {
                Image(systemName: folder.icon ?? "folder")
                Text("\(folder.receiptCount) \(folder.title ?? " Default")")
                Spacer()
            }.font(.system(size: 16, weight: .bold, design: .rounded))
            .foregroundColor(Color("background"))
            .padding(10)
        }.fixedSize()
    }
}

/// Extension of the Folder object
extension Folder {
    /// Defines the folders utilized, with their respective icons and colours.
    static let folderMatch = [(title: "Default", icon: "doc.plaintext", color: "text"),
                              (title: "Retail", icon: "tag", color: "blue"),
                              (title: "Groceries", icon: "cart", color: "green"),
                              (title: "Clothing", icon: "bag", color: "pink")]
    
    /// Retreives the icon of a folder based on it's title.
    static func getIcon(title: String?) -> String {
        for match in folderMatch where match.title.lowercased() == title?.lowercased(){
            return match.icon.lowercased()
        }
        return "folder".lowercased()
    }
    
    /// Retreives the colour of a folder based on it's title.
    static func getColor(title: String?) -> String {
        for match in folderMatch where match.title.lowercased() == title?.lowercased(){
            return match.color.lowercased()
        }
        return "text"
    }
    
    /// Boolean true if folder exists, false if not.
    static func folderExists(title: String?) -> Bool {
        for match in folderMatch where match.title.lowercased() == title?.lowercased() {
            return true
        }
        return false
    }
    
    /// Returns an array of all folders.
    static func getFolders() -> [Folder] {
        let fetchRequest: NSFetchRequest<Folder> = Folder.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Folder.receiptCount, ascending: true)]
        do {
            let managedObjectContext = PersistenceController.shared.getContext()
            let folders = try managedObjectContext.fetch(fetchRequest)
            return folders
          } catch let error as NSError {
            print("Error fetching Folders: \(error.localizedDescription), \(error.userInfo)")
          }
        return [Folder]()
    }
    
    /// Returns the folder matching the input title
    static func getFolder(folderTitle: String?) -> Folder {
        for folder in getFolders() where folder.title == folderTitle?.capitalized {
            return folder
        }
        return Folder()
    }
    
    static func getCount(title: String?) -> Int {
        return Int(getFolder(folderTitle: title).receiptCount)
    }
    
    /// Adds a folder to the database with the specified title and icon.
    static func addFolder(title: String, icon: String){
        let viewContext = PersistenceController.shared.getContext()
        
        let newFolder = Folder(context: viewContext)
        newFolder.id = UUID()
        newFolder.title = title.capitalized
        newFolder.icon = getIcon(title: title)
        newFolder.color = getColor(title: title)
        newFolder.receiptCount = 1
        save()
        print("New folder: \(title) folder")
    }
    
    /// Deletes a folder
    static func delete(folder: Folder) {
        if folder.title != nil {
            let viewContext = PersistenceController.shared.getContext()
            print("Deleted folder: \(String(describing: folder.title))")
            viewContext.delete(folder)
            save()
        }
    }
    
    /// Deletes an input folder if empty.
    static func ifEmptyDelete(folderTitle: String) {
        let folder = getFolder(folderTitle: folderTitle)
        if folder.receiptCount == 0 {
            delete(folder: folder)
        }
    }
    
    /// Creates a new folder with the input title if the folder doesn't already exist.
    static func verifyFolder(folderTitle: String){
        if folderExists(folderTitle: folderTitle) {
            getFolder(folderTitle: folderTitle).receiptCount += 1
            print("Added to: \(folderTitle) folder")
        } else {
            addFolder(title: folderTitle, icon: "folder")
        }
    }
    
    /// Returns true if a folder with the input title exists.
    static func folderExists(folderTitle: String) -> Bool {
        let folders = Folder.getFolders()
        for folder in folders where folder.title?.capitalized == folderTitle.capitalized {
            return true
        }
        return false
    }
    /// Saves the CoreData state/context.
    static func save() {
        let viewContext = PersistenceController.shared.getContext()
        do {
            try  viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
}
