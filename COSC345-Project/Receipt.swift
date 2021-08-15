//
//  Receipt.swift
//  COSC345-Project
//
//  Created by Hunter Kingsbeer on 27/07/21.
//

import Foundation
import CoreData
import SwiftUI

/// States for the Receipt Detail View. None - no buttons active, Image - Viewing the receipts image, Deleting - pending delete, Editing - Editing the receipt.
enum DetailState {
    case none
    case image
    case deleting
    case editing
}

/// Receipt view is the template receipt design, that starts minimized then after interaction expands to full size
/// - Main Parent: ReceiptCollectionView
struct ReceiptView: View {
    /// An induvidual receipt entity that the view will be based on
    @State var receipt: Receipt
    /// Whether the receipt is selected and displaying further details
    @State var selected: Bool = false
    /// Whether the user has held down the receipt (performed the delete action), and is pending delete
    @State var pendingDelete = false
    @EnvironmentObject var settings: UserSettings
    
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(settings.shadows ? "shadowObject" : "accent"))
            .dropShadow(on: settings.shadows, opacity: settings.darkMode ? 0.45 : 0.15, radius: 4)
            .overlay(
                // the title and body
                HStack (alignment: .center){
                    VStack(alignment: .leading) {
                        Text(receipt.title ?? "")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                        Text("\(getDate(date: receipt.date))")
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                    }

                    Spacer()
                    Group {
                        if pendingDelete == true {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.red)
                                .overlay(Image(systemName: "xmark")
                                            .foregroundColor(Color("background"))
                                            .font(.system(size: 15, weight: .bold, design: .rounded)))
                                .frame(height: UIScreen.screenWidth * 0.08)
                                .onTapGesture {
                                    Receipt.delete(receipt: receipt)
                                }
                        } else {
                            Image(systemName: Folder.getIcon(title: receipt.folder ?? "doc.plaintext"))
                                .font(.system(size: 20))
                        }
                    }.frame(width: UIScreen.screenWidth * 0.08)
                    .transition(AnyTransition.scale(scale: 0.0).combined(with: .opacity))
                }.padding(.horizontal)
                .padding(.vertical, 10)
            ).animation(.spring())
            .frame(height: UIScreen.screenHeight * 0.08)
            .sheet(isPresented: $selected) { ReceiptDetailView(receipt: receipt).colorScheme(settings.darkMode ? .dark : .light) }
            .onTapGesture {
                selected.toggle()
            }
            .onLongPressGesture(minimumDuration: 0.25, maximumDistance: 2, perform: {
                pendingDelete.toggle()
            })
            .onChange(of: pendingDelete, perform: { _ in
                withAnimation(.spring()){
                    if pendingDelete == true {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            pendingDelete = false // turns off delete button after 3 secs
                        }
                    }
                }
            })
    }
}

 
struct ReceiptDetailView: View  {
    /// An induvidual receipt entity that the view will be based on
    @State var receipt: Receipt
    @State var detailState: DetailState = .none
    @EnvironmentObject var settings: UserSettings
    
    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                VStack (alignment: .leading){
                    HStack {
                        VStack(alignment: .leading) {
                            Text("\(receipt.title ?? "").")
                                .font(.system(.title))
                            Text("\(getDate(date: receipt.date))")
                                .font(.caption)
                        }
                        Spacer()
                        Image(systemName: Folder.getIcon(title: receipt.folder))
                            .font(.system(size: 30, weight: .semibold))
                            .foregroundColor(Color("background"))
                            .padding(10)
                            .background(Color(Folder.getColor(title: receipt.folder)))
                            .cornerRadius(12)
                    }
                    Divider()
                    Text(receipt.body ?? "")
                    Spacer()
                }.padding(.horizontal).padding(.bottom, 50).padding(.top, 20)
            }
            ReceiptViewButtons(detailState: $detailState, receipt: receipt)
                .dropShadow(on: settings.shadows, opacity: 0.15, radius: 15)
        }.padding(.bottom)
        .background(Color("background"))
        .ignoresSafeArea(edges: /*@START_MENU_TOKEN@*/.bottom/*@END_MENU_TOKEN@*/)
    }
}

struct ReceiptViewButtons: View {
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var detailState: DetailState
    @State var receipt: Receipt
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack {
                // Deleting Button
                if detailState != .image {
                    Button(action: {
                        if detailState == .deleting {
                            Receipt.delete(receipt: receipt)
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        } else {
                            detailState = .deleting
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }
                    }){
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color(detailState == .deleting ? "red" : "object"))
                                .animation(.easeInOut)
                            VStack {
                                if detailState == .image && !UIDevice.current.inSimulator {
                                    Image(data: receipt.image)! // find some way to not use !, causes crashes by forcing a view with an optional variable (which is nil)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                } else {
                                    Image(systemName: "trash").scaleEffect(detailState == .deleting ? 1.25 : 1)
                                }
                            }
                        }.padding(.vertical)
                        .frame(height: UIScreen.screenHeight * 0.1)
                    }.buttonStyle(ShrinkingButton())
                    .transition(.offset(x: -150))
                    .onChange(of: detailState, perform: { _ in
                        withAnimation(.spring()){
                            if detailState == .deleting {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    if detailState == .deleting {
                                        detailState = .none // turns off delete button after 3 secs
                                    }
                                }
                            }
                        }
                    })
                }
                
                // Image Button
                Button(action: {
                    detailState = detailState == .image ? .none : .image
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }){
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color("object"))
                        VStack {
                            if detailState == .image && receipt.image != nil && !UIDevice.current.inSimulator {
                                (Image(data: receipt.image) ?? Image(""))
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            } else {
                                Image(systemName: "photo")
                                    .padding()
                            }
                        }.transition(AnyTransition.scale(scale: 0.1).combined(with: .opacity))
                        .cornerRadius(12)
                    }.padding(.vertical)
                    .frame(height: UIScreen.screenHeight * (detailState == .image ? 0.6 : 0.1))
                }.buttonStyle(ShrinkingButton())
                
                // temporary dismiss button, replace with functioning edit button
                if detailState != .image {
                    Button(action: {
                        detailState = .none
                        presentationMode.wrappedValue.dismiss()
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }){
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color("object"))
                            Image(systemName: "chevron.down").padding()
                        }.padding(.vertical)
                        .frame(height: UIScreen.screenHeight * 0.1)
                    }.buttonStyle(ShrinkingButton())
                    .transition(.offset(x: 150))
                }
                
                /*
                // Editing Button
                if detailState != .image {
                    Button(action: {
                        detailState = detailState == .editing ? .none : .editing
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }){
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color(detailState == .editing ? "green" : "object"))
                            Image(systemName: "pencil").padding()
                        }.padding(.vertical)
                        .frame(height: UIScreen.screenHeight * 0.1)
                    }.buttonStyle(ShrinkingButton())
                    .transition(.offset(x: 150))
                }*/
            }.padding(.horizontal)
        }
    }
}

struct ReceiptScan: Identifiable {
    var id: UUID
    var title: String
    var body: String
    var image: Data
    var date: Date
    var folder: String
}

/// Extension of the Receipt object.
extension Receipt {
    /// Converts scanned text into a new Receipt object.
    static func saveScan(recognizedText: String, image: UIImage = UIImage()){
        let viewContext = PersistenceController.shared.getContext()
        
        let newReceipt = Receipt(context: viewContext)
        let title = String(recognizedText.components(separatedBy: CharacterSet.newlines).first!).capitalized
    
        newReceipt.id = UUID()
        newReceipt.title = title
        newReceipt.body = String(recognizedText.dropFirst((newReceipt.title ?? "").count)).capitalized
        newReceipt.image = image.jpegData(compressionQuality: 0.5) // warning is incorrect, this is only true when a default value is applied. Valid images are passed.
        // image cant be compared to nil, but it can be compared to an empty UIImage
        newReceipt.date = Date()
        newReceipt.folder = Prediction.pointPrediction(text: (title + (newReceipt.body ?? "")))
        Folder.verifyFolder(folderTitle: newReceipt.folder ?? "Default")
        save()
        print("New receipt: \(title)")
        print("-----------------------")
    }
    
    /// Returns an array of all folders.
    static func getReceipts() -> [Receipt] {
        let fetchRequest: NSFetchRequest<Receipt> = Receipt.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Receipt.date, ascending: false)]
        
        do {
            let managedObjectContext = PersistenceController.shared.getContext()
            let receipts = try managedObjectContext.fetch(fetchRequest)
            return receipts
          } catch let error as NSError {
            print("Error fetching Folders: \(error.localizedDescription), \(error.userInfo)")
          }
        return [Receipt]()
    }
    
    
    
    /// Deletes a Receipt object.
    static func delete(receipt: Receipt) {
        if Folder.folderExists(folderTitle: receipt.folder ?? "Default"){ 
            Folder.getFolder(folderTitle: receipt.folder ?? "Default").receiptCount -= 1
            Folder.ifEmptyDelete(folderTitle: receipt.folder ?? "")
        }
        let viewContext = PersistenceController.shared.getContext()
        print("Deleted Receipt: \(receipt.title ?? "")")
        viewContext.delete(receipt)
        save()
    }
    
    static func deleteAll(receipts: FetchedResults<Receipt>) {
        for receipt in receipts {
            delete(receipt: receipt)
        }
    }
    
    static func getReceipt(title: String) -> Receipt{
        for receipt in getReceipts() where receipt.title == title {
            return receipt
        }
        return Receipt()
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
    
    static func generateKnownReceipts() {
        let scans = ["Cotton On\n TEE - $12.00, PANTS - $23.99, HOODIE - $33.99",
                     "JB Hifi\n Airpods - $300.00, Keyboard - $30.99, Monitor - $275.00",
                     "Countdown\n Lettuce - $2.00, Doritos - $2.99, Milk - $3",
                     "Invoice\n LABOR $25p/h, HOURS WORKED - 25. TOTAL $625"]
        
        for i in 0..<4 {
            Receipt.saveScan(recognizedText: scans[i])
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
