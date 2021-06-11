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

// --------------------------------------------------------- RECEIPT
/// Extension of the Receipt object.
extension Receipt {
    /// Converts scanned text into a new Receipt object.
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
    
    /// Deletes a Receipt object.
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
    
    static func deleteAll(receipts: FetchedResults<Receipt>) {
        for receipt in receipts {
            delete(receipt: receipt)
        }
    }
    
    static func generateRandomReceipts() {
        let scans = ["Cotton On\n TEE - $12.00, PANTS - $23.99, HOODIE - $33.99",
                     "JB Hifi\n Airpods - $300.00, Keyboard - $30.99, Monitor - $275.00",
                     "Countdown\n Lettuce - $2.00, Doritos - $2.99, Milk - $3",
                     "Invoice\n LABOR $25p/h, HOURS WORKED - 25. TOTAL $625"]
        for _ in 0..<10 {
            Receipt.saveScan(recognizedText: scans.randomElement() ?? "")
        }
    }

    /// Saves the Receipt object
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
/// Extension of the Folder object
extension Folder {
    /// Defines the folders utilized, with their respective icons and colours.
    static let folderMatch = [(title: "Default", icon: "folder", color: "accent"),
                              (title: "Retail", icon: "tag", color: "blue"),
                              (title: "Groceries", icon: "cart", color: "green"),
                              (title: "Clothing", icon: "bag", color: "pink")]
    
    /// Retreives the icon of a folder based on it's title.
    static func getIcon(title: String) -> String {
        for match in folderMatch {
            if match.title.lowercased() == title.lowercased() {
                return match.icon.lowercased()
            }
        }
        return "folder".lowercased()
    }
    
    /// Retreives the colour of a folder based on it's title.
    static func getColor(title: String) -> String {
        for match in folderMatch {
            if match.title.lowercased() == title.lowercased() {
                return match.color.lowercased()
            }
        }
        return "black".lowercased()
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
    static func getFolder(folderTitle: String) -> Folder {
        for folder in getFolders() {
            if folder.title == folderTitle.capitalized {
                return folder
            }
        }
        return Folder()
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
        for folder in folders {
            if folder.title?.capitalized == folderTitle.capitalized {
                return true
            }
        }
        return false
    }
    /// Saves the CoreData state/context.
    static func save() {
        let viewContext = PersistenceController.shared.getContext()
        do {
            try  viewContext.save()
        } catch {
            // TODO: Replace this implementation with code to handle the error appropriately.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
}

// --------------------------------------------------------- COLORS
/// Extension of the Color object
extension Color {
    /// Define all gradient schemes for the background colours. Two colours each gradient, top and bottom.
    static let colors = [(top1: Color("purple"), top2: Color("orange"),
                          bottom1: Color("cyan"), bottom2: Color("purple")),
                         
                         (top1: Color("green"), top2: Color("cyan"),
                          bottom1: Color("cyan"), bottom2: Color("blue")),
                         
                         (top1: Color("object"), top2: Color("text"),
                          bottom1: Color("object"), bottom2: Color("text"))]
    
    /// Returns the defined colours
    static func getColors() -> [(top1: Color, top2: Color, bottom1: Color, bottom2: Color)] {
        return colors
    }
}

// --------------------------------------------------------- UTILITIES

/// Retrieves the screen size of the user's device.
extension UIScreen{
   static let screenWidth = UIScreen.main.bounds.size.width
   static let screenHeight = UIScreen.main.bounds.size.height
   static let screenSize = UIScreen.main.bounds.size
}

/// Shrinking a=nimation for the UI buttons.
struct ShrinkingButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.99 : 1)
            .animation(.spring())
    }
}

// Normal TextField doesn't allow colored placeholder text, this does. SOLUTION FOUND AT THIS LINK https://stackoverflow.com/questions/57688242/swiftui-how-to-change-the-placeholder-color-of-the-textfield
/// Workaround to allow for coloured placeholder text.
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
