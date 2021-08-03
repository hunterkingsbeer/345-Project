//
//  Receipt.swift
//  COSC345-Project
//
//  Created by Hunter Kingsbeer on 27/07/21.
//

import Foundation
import CoreData
import SwiftUI

/// Receipt view is the template receipt design, that starts minimized then after interaction expands to full size
/// - Main Parent: ReceiptCollectionView
struct ReceiptView: View {
    /// An induvidual receipt entity that the view will be based on
    @State var receipt: Receipt
    /// Whether the receipt is selected and displaying further details
    @State var selected: Bool = false
    /// Whether the user has held down the receipt (performed the delete action), and is pending delete
    @State var pendingDelete = false
    
    var body: some View {
        RoundedRectangle(cornerRadius: 18)
            .fill(Color("accent"))
            .overlay(
                // the title and body
                HStack {
                    VStack(alignment: .leading) {
                        HStack {
                            Image(systemName: Folder.getIcon(title: receipt.folder ?? "doc.plaintext"))
                            Text(receipt.store ?? "")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                        }
                        if selected {
                            ScrollView {
                                Text(receipt.body ?? "")
                            }
                        }
                        Spacer()
                    }
                    Spacer()
                }.padding(10)
            ).frame(height: UIScreen.screenHeight * (selected ? 0.4 : 0.08))
            .onTapGesture {
                selected.toggle()
            }.onLongPressGesture(minimumDuration: 0.25, maximumDistance: 2, perform: {
                pendingDelete.toggle()
            }).onChange(of: pendingDelete, perform: { _ in
                withAnimation(.spring()){
                    if pendingDelete == true {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            pendingDelete = false // turns off delete button after 3 secs
                        }
                    }
                }
            })
            .overlay( // the delete button
                VStack {
                    if pendingDelete == true {
                        HStack {
                            Spacer()
                            Circle()
                                .fill(Color.red)
                                .overlay(Image(systemName: "xmark")
                                            .foregroundColor(Color("background"))
                                            .font(.system(size: 15, weight: .bold, design: .rounded)))
                                           
                                .frame(width: UIScreen.screenHeight*0.035,
                                       height: UIScreen.screenHeight*0.035)
                                .padding(8)
                                .onTapGesture {
                                    Receipt.delete(receipt: receipt)
                                }
                        }
                        Spacer()
                    }
                }
            )
    }
}

/*
/// Receipt view is the template receipt design, that starts minimized then after interaction expands to full size
/// - Main Parent: ReceiptCollectionView
struct ReceiptView: View {
    /// An induvidual receipt entity that the view will be based on
    @State var receipt : Receipt
    /// Whether the receipt is selected and displaying further details
    @State var selected : Bool = false
    /// Whether the user has held down the receipt (performed the delete action), and is pending delete
    @State var pendingDelete = false
    
    var body: some View {
        RoundedRectangle(cornerRadius: 18)
            .fill(Color("accent"))
            .overlay(
                // the title and body
                VStack {
                    HStack (alignment: .top){
                        // title
                        VStack(alignment: .leading) {
                            Text(receipt.store ?? "")
                                .font(.system(.title, design: .rounded)).bold()
                            Text(receipt.folder ?? "Default")
                                .font(.system(.body, design: .rounded))
                        }
                        Spacer()
                    }
                    if selected {
                        Spacer()
                        // body
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack (alignment: .leading){
                                Text(receipt.body ?? "")
                                    .padding(.vertical, 5)
                                    .frame(minWidth: 0, maxWidth: .infinity)
                            }.frame(minWidth: 0, maxWidth: .infinity)
                        }
                    }
                    Spacer()
                    HStack {
                        Spacer()
                        VStack (alignment: .trailing){
                            /*Text("Total")
                                .font(.system(.subheadline, design: .rounded))
                                .padding(.bottom, -5)*/
                            Divider()//.padding(.leading, 20)
                            Text(receipt.total > 0 ? "$\(receipt.total , specifier: "%.2f")" : "")
                                .font(.system(.body, design: .rounded))
                        }
                    }
                }.padding().foregroundColor(Color("text"))
                
            ).frame(height: selected ? UIScreen.screenHeight*0.5 : UIScreen.screenHeight*0.16)
            .onTapGesture {
                selected.toggle()
            }
            .onLongPressGesture(minimumDuration: 0.25, maximumDistance: 2, perform: {
                pendingDelete.toggle()
            }).onChange(of: pendingDelete, perform: { _ in
                withAnimation(.spring()){
                    if pendingDelete == true {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            pendingDelete = false // turns off delete button after 2 secs
                        }
                    }
                }
            })
        .overlay( // the delete button
            VStack {
                if pendingDelete == true {
                    HStack {
                        Spacer()
                        Circle().fill(Color.red)
                            .overlay(Image(systemName: "xmark")
                                        .foregroundColor(Color("white")))
                            .frame(width: UIScreen.screenHeight*0.04,
                                   height: UIScreen.screenHeight*0.04)
                            .padding(8)
                            .onTapGesture {
                                Receipt.delete(receipt: receipt)
                            }
                    }
                    Spacer()
                }
            }
        )
    }
}*/

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
        newReceipt.folder = Prediction.pointPrediction(text: (title + (newReceipt.body ?? "")))
        Folder.verifyFolder(folderTitle: newReceipt.folder ?? "Default")
        save()
        print("New receipt: \(title)")
        print("-----------------------")
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
