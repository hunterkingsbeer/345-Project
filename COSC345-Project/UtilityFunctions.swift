//
//  UtilityFunctions.swift
//  COSC345-Project
//
//  Created by Hunter Kingsbeer on 28/05/21.
//

import Foundation
import SwiftUI
import CoreData
import Swift

class GameSettings: ObservableObject {
    @Published var score = 0
}

// --------------------------------------------------------- RECEIPT
extension Receipt {
    /// takes scanned text and puts it into a receipt entity
    static func saveScan(recognizedText: String){
        let viewContext = PersistenceController.shared.getContext()
        
        let newReceipt = Receipt(context: viewContext)
        let title = String(recognizedText.components(separatedBy: CharacterSet.newlines).first!).capitalized
    
        newReceipt.id = UUID()
        newReceipt.store = title
        newReceipt.body = String(recognizedText.dropFirst((newReceipt.store ?? "").count)).capitalized
        newReceipt.date = Date()
        newReceipt.folder = Prediction.predictFolderType(text: (title + (newReceipt.body ?? "")))
        Folder.verifyFolder(folderTitle: newReceipt.folder ?? "Default")
        save()
        print("New receipt: \(title)")
    }
    
    static func delete(receipt: Receipt) {
        if Folder.folderExists(folderTitle: receipt.folder ?? "Default"){
            Folder.getFolder(folderTitle: receipt.folder ?? "Default").receiptCount -= 1
            Folder.ifEmptyDelete(folderTitle: receipt.folder ?? "")
        }
        let viewContext = PersistenceController.shared.getContext()
        print("Deleted Receipt: \(String(describing: receipt.store))")
        viewContext.delete(receipt)
        save()
    }

    static func save() {
        let viewContext = PersistenceController.shared.getContext()
        
        do {
            try  viewContext.save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
}

// --------------------------------------------------------- FOLDER
extension Folder {
    static let folderMatch = [(title: "Default", icon: "folder", color: "black"),
                              (title: "Retail", icon: "tag", color: "blue"),
                              (title: "Groceries", icon: "cart", color: "green"),
                              (title: "Clothing", icon: "bag", color: "pink")]
    
    static func getIcon(title: String) -> String {
        for match in folderMatch {
            if match.title.lowercased() == title.lowercased() {
                return match.icon.lowercased()
            }
        }
        return "folder".lowercased()
    }
    
    static func getColor(title: String) -> String {
        for match in folderMatch {
            if match.title.lowercased() == title.lowercased() {
                return match.color.lowercased()
            }
        }
        return "black".lowercased()
    }
    
    /// returns back array of all folders
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
    
    ///returns folder with matching title
    static func getFolder(folderTitle: String) -> Folder {
        for folder in getFolders() {
            if folder.title == folderTitle.capitalized {
                return folder
            }
        }
        return Folder()
    }
    
    /// adds a folder to the database, taking a title and icon
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
    
    /// deletes folder
    static func delete(folder: Folder) {
        if folder.title != nil {
            let viewContext = PersistenceController.shared.getContext()
            print("Deleted folder: \(String(describing: folder.title))")
            viewContext.delete(folder)
            save()
        }
        
    }
    
    static func ifEmptyDelete(folderTitle: String) {
        let folder = getFolder(folderTitle: folderTitle)
        if folder.receiptCount == 0 {
            delete(folder: folder)
        }
    }
    
    /// takes a folders title in and checks whether it exists, creating a new folder if not
    // function name could be better but im tired
    static func verifyFolder(folderTitle: String){
        if folderExists(folderTitle: folderTitle) { //if the folder exists, increment its count
            getFolder(folderTitle: folderTitle).receiptCount += 1
            print("Added to: \(folderTitle) folder")
        } else {
            addFolder(title: folderTitle, icon: "folder")
        }
    }
    
    /// input folder title, returns true if folder exists
    static func folderExists(folderTitle: String) -> Bool {
        let folders = Folder.getFolders()
        for folder in folders {
            if folder.title?.capitalized == folderTitle.capitalized {
                return true
            }
        }
        return false
    }
    /// saves context
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

// --------------------------------------------------------- UTILITIES

/// checks whether an input string contains words found in parameters, true if it does, false otherwise
func matchString(parameters: [String], input: String) -> Bool{
    for parameter in parameters { // and check it against the parameter
        if input.lowercased().contains(parameter){
            print("\nMatched word '\(parameter)'")
            return true
        }
    }
    return false
}

/// used for getting screen sizes
extension UIScreen{
   static let screenWidth = UIScreen.main.bounds.size.width
   static let screenHeight = UIScreen.main.bounds.size.height
   static let screenSize = UIScreen.main.bounds.size
}

/// shrinking button effect
struct ShrinkingButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.99 : 1)
            .animation(.spring())
    }
}

// Normal TextField doesn't allow colored placeholder text, this does. SOLUTION FOUND AT THIS LINK https://stackoverflow.com/questions/57688242/swiftui-how-to-change-the-placeholder-color-of-the-textfield
struct CustomTextField: View {
    var placeholder: Text
    @Binding var text: String
    var editingChanged: (Bool)->() = { _ in }
    var commit: ()->() = { }

    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty { placeholder }
            TextField("", text: $text, onEditingChanged: editingChanged, onCommit: commit)
        }
    }
}
