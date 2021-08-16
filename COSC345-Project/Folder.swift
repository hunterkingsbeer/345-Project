//
//  Folder.swift
//  COSC345-Project
//
//  Created by Hunter Kingsbeer on 29/07/21.
//

import Foundation
import CoreData
import SwiftUI

/// ``FolderView``
/// is a View struct that displays a folder with the functionality to change the selectedFolder string (to it's folder name) to filter receipt results on the HomeView.
/// - Called by HomeView.
struct FolderView: View {
    ///``folder``: is a Folder variable that is passed to the view which holds the information about the folder this view will represent.
    @ObservedObject var folder: Folder
    ///``selectedFolder``: is a String that holds the text of the folders title, used in filtering receipt results in HomeView.
    @Binding var selectedFolder: String
    ///``settings``: Imports the UserSettings environment object allowing unified usage and updating of the users settings across all classes.
    @EnvironmentObject var settings: UserSettings
    
    var body: some View {
        Button(action: {
            withAnimation(.spring()){
                selectedFolder = selectedFolder == folder.title ? "" : folder.title ?? "Default"
            }
        }){
            if settings.thinFolders {
                // Original Thin Folders
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(Folder.getColor(title: folder.title ?? "default")))
                        .dropShadow(on: settings.shadows, opacity: settings.darkMode ? 0.6 : 0.2, radius: 4)
                    
                    HStack {
                        Image(systemName: folder.icon ?? "folder")
                        Text("\(folder.receiptCount) \(folder.title ?? " Default")")
                        Spacer()
                    }.font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color("background"))
                    .padding(10)
                    .padding(.vertical, 4)
                }.fixedSize()
            } else {
                // New Bigger Folders
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(Folder.getColor(title: folder.title ?? "default")))
                        .dropShadow(on: settings.shadows, opacity: settings.darkMode ? 0.6 : 0.2, radius: 4)
                    
                    VStack {
                        HStack {
                            Image(systemName: folder.icon ?? "folder")
                            Spacer()
                            Text("\(folder.receiptCount)")
                        }.padding(.trailing, 8)
                        Text("\(folder.title ?? " Default")")
                    }.padding(10)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color("background"))
                }.fixedSize()
            }
        }.buttonStyle(ShrinkingButton())
    }
}

extension Folder {
    /// All functions in here can be called by the code ``Folder.functionName()``.
    
    /// ``folders``
    /// Defines the title of folders, with their respective icons and colours. NEEDS UPDATING TO HAVE NEW FOLDERS WE HAVE CREATED.
    static let folders = [(title: "Default", icon: "doc.plaintext", color: "text"),
                              (title: "Retail", icon: "tag", color: "lightYellow"),
                              (title: "Groceries", icon: "cart", color: "green"),
                              (title: "Technology", icon: "desktopcomputer", color: "blue"),
                              (title: "Clothing", icon: "bag", color: "pink")]
    
    ///``getIcon``
    /// Gets the icon of the folder you want to check.
    /// Performs this by doing a for loop, checking each folder until the matching folder title (and folder) is found, where it returns the string.
    /// - Parameter title: The title of the folder you want the icon of.
    /// - Returns: A string that can be placed inside an Image(), e.g. Image()
    static func getIcon(title: String?) -> String {
        for match in folders where match.title.lowercased() == title?.lowercased(){
            return match.icon.lowercased()
        }
        return "folder".lowercased()
    }
    
    ///``getColor``
    /// Gets the color of the folder you want to check.
    /// Performs this by doing a for loop, checking each folder until the matching folder title (and folder) is found, where it returns the string.
    /// - Parameter title: The title of the folder you want the color of.
    /// - Returns: A string that can be placed inside a Color(), e.g. Color("green").
    static func getColor(title: String?) -> String {
        for match in folders where match.title.lowercased() == title?.lowercased(){
            return match.color
        }
        return "text"
    }
    
    ///``folderExists``
    /// Lets you know if a folder exists or not.
    /// Performs this by doing a for loop, checking each folder until the matching folder title (and folder) is found, where it returns the bool.
    /// - Parameter title: The title of the folder you want to check the existance of.
    /// - Returns:
    ///     - True if the folder exists.
    ///     - False if the folder doesn't exist.
    static func folderExists(title: String?) -> Bool {
        for match in getFolders() where match.title ?? "Default".lowercased() == title?.lowercased() {
            return true
        }
        return false
    }
    
    ///``getFolders``
    /// Gets the folders you want to retrieve.
    /// It creates a fetch request and calls in the CoreData database's collection of Folder entities, returning them as an array.
    /// - Returns: An array of the Folder entities from the database.
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
    
    ///``getFolder``
    /// Gets the folder you want to retrieve.
    /// Performs this by doing a for loop, checking each folder until the matching folder title (and folder) is found, where it returns the Folder.
    /// - Parameter title: The title of the folder you want to retrieve.
    /// - Returns A Folder with the matching title as the parameter.
    static func getFolder(title: String?) -> Folder {
        for folder in getFolders() where folder.title == title?.capitalized {
            return folder
        }
        return Folder()
    }
    
    ///``getCount``
    /// Gets the number of receipts in the folder you want to check.
    /// Performs this by doing a for loop, checking each folder until the matching folder title (and folder) is found, where it returns the Int.
    /// - Parameter title: The title of the folder you want to retrieve to receipt count of.
    /// - Returns A Folder with the matching title as the parameter.
    static func getCount(title: String?) -> Int {
        return Int(getFolder(title: title).receiptCount)
    }
    
    ///``addFolder``
    /// Gets the number of receipts in the folder you want to check.
    /// Performs this by doing a for loop, checking each folder until the matching folder title (and folder) is found, where it returns the Int.
    /// - Parameter title: The title of the folder you want to retrieve to receipt count of.
    /// - Returns A Folder with the matching title as the parameter.
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
    
    ///``delete``
    /// Deletes the folder passed to it in the param.
    /// Creates a context and then deletes the folder, before saving the context to confirm this.
    /// - Parameter folder: The folder you want to delete.
    static func delete(folder: Folder) {
        if folder.title != nil {
            let viewContext = PersistenceController.shared.getContext()
            print("Deleted folder: \(String(describing: folder.title))")
            viewContext.delete(folder)
            save()
        }
    }
    
    ///``ifEmptyDelete``
    /// Used to check if a folder is empty, if it is empty then delete it.
    /// Checks if a folders receipt count is 0.
    /// - Parameter title: The title of the folder you want to check.
    static func ifEmptyDelete(title: String) {
        if getCount(title: title) == 0 {
            delete(folder: getFolder(title: title))
        }
    }
    
    ///``verifyFolder``
    /// Used to check if a folder exists or needs to be created; if it does exist then its receipt count is incremented, otherwise a folder with the params folder name is created.
    /// This is performed when creating a receipt, to make sure it has a valid folder to be added to.
    /// - Parameter title: The folder you want to verify.
    static func verifyFolder(title: String){
        if folderExists(title: title) {
            getFolder(title: title).receiptCount += 1
            print("Added to: \(title) folder")
        } else {
            addFolder(title: title, icon: "folder")
        }
    }
    
    ///``save``
    /// Used to save the context to confirm changes with the CoreData database.
    /// This should be performed after any changes to the database entities.
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
