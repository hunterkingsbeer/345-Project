//
//  Receipt.swift
//  COSC345-Project
//
//  Created by Hunter Kingsbeer on 27/07/21.
//

import Foundation
import CoreData
import SwiftUI

/// ``DetailState``
/// is an enum that is used to control the state of the DetailReceiptView, relating to each of the buttons present in the view.
enum DetailState {
    ///``none``: When this is active it will present the view in its default view, with nothing active.
    case none
    ///``image``: When this is active it will present the image of the receipt.
    case image
    ///``deleting``: When this is active it will present the user with a delete confirmation button, allowing them to delete a receipt.
    case deleting
    ///``editing``: When this is active it will allow the user to edit the receipt they are viewing. NOT IMPLEMENTED YET.
    case editing
}

/// ``ReceiptView``
/// is a View struct that displays a small 'preview' receipt which upon interaction will display a sheet holding the ReceiptDetailView.
/// - Called by HomeView.
struct ReceiptView: View {
    ///``receipt``: is a Receipt variable that is passed to the view which holds the information about the receipt this view will represent.
    @State var receipt: Receipt
    ///``selected``: is a Bool that controls the visibility of the ReceiptDetailView sheet, when true the sheet is visible, when false the sheet is not visible.
    @State var selected: Bool = false
    /// ``pendingDelete``: is a Bool that shows the delete button for a user to confirm a deletion of a receipt.
    @State var pendingDelete = false
    ///``settings``: Imports the UserSettings environment object allowing unified usage and updating of the users settings across all classes.
    @EnvironmentObject var settings: UserSettings
    
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(settings.shadows ? "shadowObject" : "object"))
            .dropShadow(isOn: settings.shadows, opacity: settings.darkMode ? 0.45 : 0.075, radius: 4)
            .overlay(
                // the title and body
                HStack (alignment: .center){
                    VStack(alignment: .leading) {
                        Text(receipt.title ?? "".trimmingCharacters(in: .whitespacesAndNewlines))
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
            .sheet(isPresented: $selected) {
                ReceiptDetailView(receipt: receipt).colorScheme(settings.darkMode ? .dark : .light)
            }
    }
}

/// ``ReceiptDetailView``
/// is a View struct that displays the detail view of the Receipt that is passed to it. It shows all the information available about a receipt, usually presented in a sheet.
/// - Called by ReceiptView.
struct ReceiptDetailView: View  {
    ///``receipt``: is a Receipt variable that is passed to the view which holds the information about the receipt this view will represent.
    @State var receipt: Receipt
    ///``detailState``: allows the view to update based on how the user desired to interact with the receipt. Allows the user to delete, edit, view the image, and view the receipt.
    @State var detailState: DetailState = .none
    ///``settings``: Imports the UserSettings environment object allowing unified usage and updating of the users settings across all classes.
    @EnvironmentObject var settings: UserSettings
    
    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                VStack (alignment: .leading){
                    HStack {
                        VStack(alignment: .leading) {
                            Text("\(receipt.title ?? "".trimmingCharacters(in: .whitespacesAndNewlines))")
                                .font(.system(.title))
                            Text("\(getDate(date: receipt.date))")
                                .font(.caption)
                                .opacity(0.5)
                            Text("\(receipt.folder ?? "Default").")
                                .opacity(0.5)
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
                .dropShadow(isOn: settings.shadows, opacity: 0.15, radius: 15)
        }.padding(.bottom)
        .background(Color("background"))
        .ignoresSafeArea(edges: .bottom)
    }
}
/// ``ReceiptViewButtons``
/// is a View struct that displays the buttons at the bottom of the ReceiptDetailView, allowing the receipt to be modified as needed.
/// - Called by ReceiptDetailView.
struct ReceiptViewButtons: View {
    ///``presentationMode``: Controls the presentation of the sheet the receipt is being displayed on. Specifically used in the dismiss button
    @Environment(\.presentationMode) var presentationMode
    ///``detailState``:  binds to the parent views detailState, to update it based on the users interaction.
    @Binding var detailState: DetailState
    ///``receipt``: is a Receipt variable that is passed to the view which allows this view to delete and update it as needed.
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

/// Extension of the Receipt object.
extension Receipt {
    ///``saveScan``
    /// takes in an image and recognized text and applies it to a Receipt variable to be saved to the database.
    /// - Parameter recognizedText: The text from the scanned image, to be placed into a receipt variable.
    /// - Parameter image: The image of the receipt that was scanned.
    static func saveScan(recognizedText: String, image: UIImage = UIImage()){
        print("\n----------------------------")
        let viewContext = PersistenceController.shared.getContext()
        
        let newReceipt = Receipt(context: viewContext)
        let title = String(recognizedText.components(separatedBy: CharacterSet.newlines).first!).capitalized
    
        newReceipt.id = UUID()
        newReceipt.title = title
        print("New Receipt Saving: \(title)")
        newReceipt.body = String(recognizedText.dropFirst((newReceipt.title ?? "").count)).capitalized
        newReceipt.image = image.jpegData(compressionQuality: 0.5) // warning is incorrect, this is only true when a default value is applied. Valid images are passed.
        // image cant be compared to nil, but it can be compared to an empty UIImage
        newReceipt.date = Date()
        newReceipt.folder = Prediction.pointPrediction(text: (title + (newReceipt.body ?? "")))
        Folder.verifyFolder(title: newReceipt.folder ?? "Default")
        save()
        print("Receipt saved!")
    }
    
    ///``getReceipts``
    /// Gets an array of receipts from the database.
    /// It creates a fetch request and calls in the CoreData database's collection of Receipt entities, returning them as an array.
    /// - Returns: An array of the Receipt entities from the database.
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
    
    ///``delete``
    /// Deletes the receipt passed to it in the param.
    /// Creates a context and then deletes the receipt, before saving the context to confirm this.
    /// - Parameter receipt: The receipt you want to delete.
    static func delete(receipt: Receipt) {
        if Folder.folderExists(title: receipt.folder ?? "Default"){
            Folder.getFolder(title: receipt.folder ?? "Default").receiptCount -= 1
            Folder.ifEmptyDelete(title: receipt.folder ?? "")
        }
        let viewContext = PersistenceController.shared.getContext()
        print("Deleted Receipt: \(receipt.title ?? "")")
        viewContext.delete(receipt)
        save()
    }
    
    ///``deleteAll``
    /// Deletes all the receipts passed to it in the param.
    /// - Parameter receipts: The receipts you want to delete.
    static func deleteAll(receipts: FetchedResults<Receipt>) {
        for receipt in receipts {
            delete(receipt: receipt)
        }
    }
    
    ///``getReceipt``
    /// Gets the receipt you want to retrieve.
    /// Performs this by doing a for loop, checking each receipt until the matching receipt title (and receipt) is found, where it returns the Receipt.
    /// - Parameter title: The title of the receipt you want to retrieve.
    /// - Returns A Receipt with the matching title as the parameter.
    static func getReceipt(title: String) -> Receipt{
        for receipt in getReceipts() where receipt.title == title {
            return receipt
        }
        return Receipt()
    }
    
    ///``generateRandomReceipts``
    /// Uses a pre-determined array of strings to create receipts. This function generates the receipts at random varying ratios.
    /// Each receipt is saved to the database.
    static func generateRandomReceipts() {
        let scans = ["Countdown \nLettuce - $2.00,\nDoritos - $2.99,\nMilk - $3", // groceries
                     
                     "JB Hifi \nKeyboard - $120.00,\nTablet - $2300.99,\nEar buds - $119.99", // tech
                     
                     "Mitre 10 \nAxe - $110.00,\nTimber - $2009.10,\nGlue - $10.00", //hardware
                     
                     "Kitchen Things \nWashing Machine - $2560.10", //appliance
                     
                     "Animates \nDog Food - $30.00,\nBowl - $20.00", //pets
                     
                     "Dunedin Pharmacy \nVitamins - $65.00,\nLip Balm - $4.50", // Health/Beauty
                     
                     "Big Save Furniture \nCouch - $1450.00,\nBed Frame - $1000.00", // home
                     
                     "Paper Plus \nPaper - $10.00,\nToner - $39.50,\nCalendar - $25.00",
                     
                     "Cotton on \n2x Tee - $30.00,\nPants - $45.00", // apparel
                     
                     "Paper Plus\nPaint - $25.00,\nClay - $5.99,\nEraser - $3.00", // arts
                     
                     "JetBrains\nJava IDE - $250.00", // software
                     
                     "JB Hifi \nPS5 - $500.00,\nPlaystation Game - $120.00", // games
                     
                     "Nike \nSoccer Shoes - $150.00,\n Mouthguard - $15.00", // sports
                     
                     "SuperCheap Auto \nSteering Wheel - $320.00,\n Battery - $450.00,\nRims - $75.00" // vehicles
        ]
        for _ in 0..<10 {
            Receipt.saveScan(recognizedText: scans.randomElement() ?? "")
        }
    }
    
    ///``generateKnownReceipts``
    /// Uses a pre-determined array of strings to create receipts. This function generates the receipts at 1:1 ratios, which is useful in testing.
    /// Each receipt is saved to the database.
    static func generateKnownReceipts() {
        let scans = ["Cotton On\n TEE - $12.00, PANTS - $23.99, HOODIE - $33.99",
                     "JB Hifi\n Airpods - $300.00, Keyboard - $30.99, Monitor - $275.00",
                     "Countdown\n Lettuce - $2.00, Doritos - $2.99, Milk - $3",
                     "Invoice\n LABOR $25p/h, HOURS WORKED - 25. TOTAL $625"]
        
        for index in 0..<4 {
            Receipt.saveScan(recognizedText: scans[index])
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
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
}
