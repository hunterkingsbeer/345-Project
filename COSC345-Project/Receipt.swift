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
    @ObservedObject var receipt: Receipt
    ///``selected``: is a Bool that controls the visibility of the ReceiptDetailView sheet, when true the sheet is visible, when false the sheet is not visible.
    @State var selected: Bool = false
    /// ``pendingDelete``: is a Bool that shows the delete button for a user to confirm a deletion of a receipt.
    @State var pendingDelete = false
    ///``settings``: Imports the UserSettings environment object allowing unified usage and updating of the users settings across all classes.
    @EnvironmentObject var settings: UserSettings
    
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(settings.shadows ? "shadowObject" : "object"))
            .dropShadow(isOn: settings.shadows, opacity: settings.darkMode ? 0.25 : 0.06, radius: 5)
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
                    ZStack {
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
                    }
                }.padding(.horizontal)
                .padding(.vertical, 10)
            ).animation(.spring())
            .frame(height: UIScreen.screenHeight * 0.08)
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
            }).sheet(isPresented: $selected) {
                ReceiptDetailView(receipt: receipt)
                    .colorScheme(settings.darkMode ? .dark : .light)
                    .environmentObject(UserSettings())
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
    ///``editedReceipt`` is
    @State var editedReceipt = (title: "", folder: "", body: "", date: Date())
    
    var body: some View {
        let editing = detailState == .editing
        ZStack {
            VStack {
                ZStack {
                    Blur(effect: UIBlurEffect(style: .systemThinMaterial))
                        .ignoresSafeArea()
                        .overlay(getColor()
                                    .blendMode(.color)
                                    .opacity(settings.darkMode ? 0.2 : 1.0))
                    
                    HStack(alignment: .center) {
                        VStack(alignment: .leading) {
                            Text("\(getDate(date: receipt.date))")
                                .font(.caption)
                            
                            EditableReceiptText(placeholder: receipt.title ?? "Title",
                                                editedItem: $editedReceipt.title,
                                                editing: editing, font: .title) // title
                            
                            EditableReceiptText(placeholder: receipt.folder ?? "Folder",
                                                editedItem: $editedReceipt.folder,
                                                editing: false) // folder
                        }
                        Spacer()
                        Image(systemName: Folder.getIcon(title: receipt.folder))
                            .font(.system(size: 30, weight: .semibold))
                            .padding(10)
                            .foregroundColor(getColor())
                            .cornerRadius(12)
                    }.foregroundColor(Color("text"))
                    .padding()
                }.frame(height: UIScreen.screenHeight * 0.14)
                Spacer()
            }.zIndex(1)
            
            ScrollView(showsIndicators: false) {
                HStack {
                    VStack {
                        Text(editedReceipt.body)
                        //TextEditor(text: $editedReceipt.body) doesnt work :(
                        Spacer()
                    }
                    Spacer()
                }.padding(.horizontal)
                .padding(.vertical, UIScreen.screenHeight * 0.14)
            }.zIndex(0)

            ReceiptViewButtons(detailState: $detailState, receipt: receipt, editedReceipt: $editedReceipt)
                .zIndex(2)
        }.padding(.bottom)
        .background(Color("object"))
        .ignoresSafeArea(edges: .bottom)
    }
    
    func getColor() -> Color {
        return Color(Folder.getColor(title: receipt.folder))
    }
}

enum EditingState {
    case confirming
    case discarding
    case none
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
    ///``settings``: Imports the UserSettings environment object allowing unified usage and updating of the users settings across all classes.
    @EnvironmentObject var settings: UserSettings
    ///``editedReceipt`` is
    @Binding var editedReceipt: (title: String, folder: String, body: String,
                                 date: Date)
    ///``editingState`` is
    @State var editingState: EditingState = .none
    
    var body: some View {
        let buttonSize = UIScreen.screenHeight * 0.06
        VStack {
            Spacer()
            if detailState == .editing {
                HStack {
                    Spacer()
                    Text("Currently Editing.")
                        .padding(10)
                    Spacer()
                }.background(Blur(effect: UIBlurEffect(style: .systemMaterial)))
                .cornerRadius(12)
                .dropShadow(isOn: settings.shadows, opacity: settings.darkMode ? 0.25 : 0.06, radius: 12)
                .transition(AnyTransition.move(edge: .bottom))
            }
            
            HStack {
                // Deleting Button
                if detailState != .image {
                    Button(action: {
                        if detailState == .editing {
                            // discard
                            if editingState == .discarding {
                                // discard edit
                                detailState = .none
                                editingState = .none
                                updateEditedReceipt()
                            } else {
                                editingState = .discarding
                            }
                        } else {
                            if detailState == .deleting {
                                Receipt.delete(receipt: receipt)
                                hapticFeedback(type: .rigid)
                            } else {
                                detailState = .deleting
                                hapticFeedback(type: .rigid)
                            }
                        }
                    }){
                        ZStack {
                            Blur(effect: UIBlurEffect(style: .systemMaterial))
                                .background(editingState == .discarding || detailState == .deleting ? Color("red") : Color.clear)
                                .cornerRadius(12)
                                .dropShadow(isOn: settings.shadows, opacity: settings.darkMode ? 0.25 : 0.06, radius: 12)
                                .animation(.easeInOut)
                            
                            if detailState == .editing {
                                Image(systemName: "xmark").scaleEffect(editingState == .discarding ? 1.25 : 1)
                            } else {
                                Image(systemName: "trash").scaleEffect(detailState == .deleting ? 1.25 : 1)
                            }
                        }
                        .frame(height: buttonSize)
                    }.buttonStyle(ShrinkingButtonSpring())
                    .transition(.offset(x: -150))
                    .onChange(of: detailState, perform: { _ in
                        withAnimation(.spring()){
                            if detailState == .deleting {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                                    if detailState == .deleting {
                                        detailState = .none // turns off delete button after 3 secs
                                    }
                                }
                            }
                        }
                    }).onChange(of: editingState, perform: { state in
                        withAnimation(.spring()){
                            if state == .discarding {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                                    if state == .discarding { // if still discarding (user may have selected another option)
                                        editingState = .none // turns off delete button after 3 secs
                                    }
                                }
                            }
                        }
                    })
                }
                
                // Image Button
                Button(action: {
                    detailState = detailState == .image ? .none : .image
                    hapticFeedback(type: .rigid)
                }){
                    ZStack {
                        Blur(effect: UIBlurEffect(style: .systemMaterial))
                            .cornerRadius(12)
                            .dropShadow(isOn: settings.shadows, opacity: settings.darkMode ? 0.25 : 0.06, radius: 12)
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
                    }
                    .frame(height: detailState == .image ? UIScreen.screenHeight * 0.6 : buttonSize)
                }.buttonStyle(ShrinkingButtonSpring())
                
                // Editing Button
                if detailState != .image {
                    Button(action: {
                        if detailState == .editing {
                            // confirming
                            if editingState == .confirming {
                                // save edit
                                detailState = .none
                                editingState = .none
                                Receipt.updateReceipt(receipt: receipt, editedReceipt: editedReceipt)
                            } else {
                                editingState = .confirming
                            }
                        } else {
                            detailState = detailState == .editing ? .none : .editing
                        }
                        hapticFeedback(type: .rigid)
                    }){
                        ZStack {
                            Blur(effect: UIBlurEffect(style: .systemMaterial))
                                .background(editingState == .confirming ? Color("UI2") : Color.clear)
                                .cornerRadius(12)
                                .dropShadow(isOn: settings.shadows, opacity: settings.darkMode ? 0.25 : 0.06, radius: 10)
                            if detailState == .editing {
                                Image(systemName: "checkmark").scaleEffect(editingState == .confirming ? 1.25 : 1)
                            } else {
                                Image(systemName: "pencil").padding()
                            }
                        }.frame(height: buttonSize)
                    }.buttonStyle(ShrinkingButtonSpring())
                    .transition(.offset(x: 150))
                    .onChange(of: editingState, perform: { state in
                        withAnimation(.spring()){
                            if state == .confirming {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                                    if state == .confirming {
                                        editingState = .none // turns off delete button after 3 secs
                                    }
                                }
                            }
                        }
                    })
                }
                /*
                // temporary dismiss button, replace with functioning edit button
                if detailState != .image {
                    Button(action: {
                        detailState = .none
                        hapticFeedback(type: .rigid)
                        presentationMode.wrappedValue.dismiss()
                    }){
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color(settings.darkMode ? "shadowObject" : "background"))
                                .dropShadow(isOn: settings.shadows, opacity: settings.darkMode ? 0.25 : 0.1, radius: 12)
                            Image(systemName: "chevron.down").padding()
                        }.padding(.vertical)
                        .frame(height: UIScreen.screenHeight * 0.1)
                    }.buttonStyle(ShrinkingButtonSpring())
                    .transition(.offset(x: 150))
                }*/
            }
        }.padding(.horizontal).padding(.bottom)
        .onAppear(perform: updateEditedReceipt)
    }
    
    func updateEditedReceipt(){
        editedReceipt.title = receipt.title ?? ""
        editedReceipt.folder = receipt.folder ?? ""
        editedReceipt.body = receipt.body ?? ""
        editedReceipt.date = receipt.date ?? Date()
    }
    
    func saveReceipt(){
        receipt.title = editedReceipt.title
        receipt.folder = editedReceipt.folder
        receipt.body = editedReceipt.body
        receipt.date = editedReceipt.date
        Receipt.save()
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
        newReceipt.image = imageToData(image: image)
        // image cant be compared to nil, but it can be compared to an empty UIImage
        newReceipt.date = Date()
        newReceipt.folder = Prediction.pointPrediction(text: (title + (newReceipt.body ?? "")))
        Folder.verifyFolder(title: newReceipt.folder ?? "Default")
        save()
        print("Receipt saved!")
    }
    
    static func updateReceipt(receipt: Receipt, editedReceipt: (title: String, folder: String, body: String, date: Date)) {
        let receiptFinal = Receipt.getReceipt(title: receipt.title ?? "")
        
        receiptFinal.title = editedReceipt.title
        receiptFinal.body = editedReceipt.body
        receiptFinal.folder = editedReceipt.folder
        receiptFinal.date = editedReceipt.date
        
        Receipt.save()
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
        let scans = ["Countdown\nLettuce - $2.00,\nDoritos - $2.99,\nMilk - $3", // groceries
                     
                     "JB Hifi\nKeyboard - $120.00,\nTablet - $2300.99,\nEar buds - $119.99", // tech
                     
                     "Mitre 10\nAxe - $110.00,\nTimber - $2009.10,\nGlue - $10.00", //hardware
                     
                     "Kitchen Things\nWashing Machine - $2560.10", //appliance
                     
                     "Animates\nDog Food - $30.00,\nBowl - $20.00", //pets
                     
                     "Dunedin Pharmacy\nVitamins - $65.00,\nLip Balm - $4.50", // Health/Beauty
                     
                     "Big Save Furniture\nCouch - $1450.00,\nBed Frame - $1000.00", // home
                     
                     "Paper Plus\nPaper - $10.00,\nToner - $39.50,\nCalendar - $25.00",
                     
                     "Cotton on\n2x Tee - $30.00,\nPants - $45.00", // apparel
                     
                     "Paper Plus\nPaint - $25.00,\nClay - $5.99,\nEraser - $3.00", // arts
                     
                     "JetBrains\nJava IDE - $250.00", // software
                     
                     "JB Hifi\nPS5 - $500.00,\nPlaystation Game - $120.00", // games
                     
                     "Nike\nSoccer Shoes - $150.00,\n Mouthguard - $15.00", // sports
                     
                     "SuperCheap Auto\nSteering Wheel - $320.00,\n Battery - $450.00,\nRims - $75.00" // vehicles
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

struct EditableReceiptText: View {
    @State var placeholder: String
    @Binding var editedItem: String
    var editing: Bool
    var font: Font = .body
    
    var body: some View {
        TextField(placeholder, text: $editedItem)
            .disabled(editing ? false : true)
            .placeholder(when: editedItem == placeholder){
                Text(placeholder)
                    .foregroundColor(Color("text"))
            }.font(font)
    }
}


