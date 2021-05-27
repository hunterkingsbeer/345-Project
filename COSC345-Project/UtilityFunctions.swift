//
//  UtilityFunctions.swift
//  COSC345-Project
//
//  Created by Hunter Kingsbeer on 28/05/21.
//
// --------------------------------------------------------- UTILITIES


import Foundation
import SwiftUI
import CoreData
import Swift

extension Receipt {
    static func saveScan(viewContext: NSManagedObjectContext, recognizedText: String){
        let newReceipt = Receipt(context: viewContext)
        let title = String(recognizedText.components(separatedBy: CharacterSet.newlines).first!).capitalized
    
        newReceipt.id = UUID()
        newReceipt.store = title
        newReceipt.body = String(recognizedText.dropFirst((newReceipt.store ?? "").count)).capitalized
        newReceipt.date = Date()
        newReceipt.folder = Receipt.predictFolderType(text: (title + (newReceipt.body ?? "")))
        save(viewContext: viewContext)
    }
    
    /// Predict Folder Type -- Input the text compared against keywords to predict a folder name
    static func predictFolderType(text: String) -> String{
        let groceries = ["new world", "paknsave", "countdown",
                         "freshchoice", "supermarket", "mart"]
        let retail = ["harvey norman", "noel leeming", "smith city",
                      "jb hifi", "farmers"]
        let clothing = ["cotton on", "hallensteins", "countdown"]
        print("\nDetected: ")
        
        if matchString(parameters: groceries, input: text){
            print("Category Groceries")
            return "Groceries"
            
        } else if matchString(parameters: retail, input: text){
            print("Category Retail")
            return "Retail"
            
        } else if matchString(parameters: clothing, input: text){
            print("Category Clothing")
            return "Clothing"
            
        } else {
            print("Category Default")
            return "Default"
        }
    }
    
    static func delete(viewContext: NSManagedObjectContext, receipt: Receipt) {
        viewContext.delete(receipt)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
            do {
                try viewContext.save()
            } catch {
                print("Failed to delete and save the context: \(error.localizedDescription)")
            }
        }
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

extension Folder {
    static func addFolder(viewContext: NSManagedObjectContext, title: String, icon: String){
        let newFolder = Folder(context: viewContext)
        
        newFolder.id = UUID()
        newFolder.title = title.capitalized
        newFolder.icon = icon.lowercased()
        save(viewContext: viewContext)
    }
    
    static func delete(viewContext: NSManagedObjectContext, folder: Folder) {
        viewContext.delete(folder)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
            do {
                try viewContext.save()
            } catch {
                print("Failed to delete and save the context: \(error.localizedDescription)")
            }
        }
    }
    
    static func doesFolderExist(search: String, folders: FetchedResults<Folder>) -> Bool {
        for folder in folders {
            if folder.title?.capitalized == search.capitalized {
                return true
            }
        }
        return false
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

/// checks whether an input string contains words found in parameters, true if it does, false otherwise
func matchString(parameters: [String], input: String) -> Bool{
    for parameter in parameters { // and check it against the parameter
        if input.lowercased().contains(parameter){
            print("Match for '\(parameter)'")
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
