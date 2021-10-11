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
    ///``text``: When this is active it will present the text of the receipt.
    case text
    ///``deleting``: When this is active it will present the user with a delete confirmation button, allowing them to delete a receipt.
    case deleting
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
        Blur(effect: UIBlurEffect(style: .systemThinMaterial))
            .opacity(0.9)
            .cornerRadius(12)
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
                        }.transition(AnyTransition.scale(scale: 0.0).combined(with: .opacity))
                    }.frame(width: UIScreen.screenWidth * 0.08)
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
    
    @State var showingDismiss = false
    ///``detailState``: allows the view to update based on how the user desired to interact with the receipt. Allows the user to delete, view the image, and view the receipt.
    @State var detailState: DetailState = .none
    ///``settings``: Imports the UserSettings environment object allowing unified usage and updating of the users settings across all classes.
    @EnvironmentObject var settings: UserSettings
    
    var body: some View {
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
                            Spacer()
                            Text("\(getDate(date: receipt.date))")
                                .font(.caption)
                            
                            Text(receipt.title ?? "Title") // title
                                .font(.title)
                            Text(receipt.folder ?? "Folder")// folder
                            Spacer()
                        }
                        Spacer()
                        Image(systemName: Folder.getIcon(title: receipt.folder))
                            .font(.system(size: 30, weight: .semibold))
                            .padding(10)
                            .foregroundColor(getColor())
                            .cornerRadius(12)
                    }.foregroundColor(Color("text"))
                    .padding()
                }.frame(height: UIScreen.screenHeight * 0.12)
                Spacer()
            }.zIndex(1)
            
            ScrollView(showsIndicators: false) {
                HStack {
                    VStack(alignment: .leading) {
                        if Image(data: receipt.image) != nil {
                            HStack {
                                Spacer()
                                ImageView(image: (Image(data: receipt.image) ?? Image("")))
                                Spacer()
                            }
                        }
                        if detailState == .text {
                            HStack {
                                Text(receipt.body ?? "")
                                Spacer()
                            }.transition(AnyTransition.move(edge: .bottom).combined(with: .opacity)).animation(.spring())
                        }
                        Spacer()
                    }
                    Spacer()
                }.padding(.horizontal)
                .padding(.vertical, UIScreen.screenHeight * 0.14)
            }.zIndex(0)

            ReceiptViewButtons(detailState: $detailState, receipt: receipt)
                .zIndex(2)
        }.padding(.bottom)
        .background(Color("object"))
        .ignoresSafeArea(edges: .bottom)
    }
    
    func getColor() -> Color {
        return Color(Folder.getColor(title: receipt.folder))
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
    ///``settings``: Imports the UserSettings environment object allowing unified usage and updating of the users settings across all classes.
    @EnvironmentObject var settings: UserSettings
    
    var body: some View {
        let buttonSize = UIScreen.screenHeight * 0.06
        VStack {
            Spacer()
            
            HStack {
                // Deleting Button
                Button(action: {
                    if detailState == .deleting {
                        Receipt.delete(receipt: receipt)
                        hapticFeedback(type: .rigid)
                    } else {
                        detailState = .deleting
                        hapticFeedback(type: .rigid)
                    }
                }){
                    ZStack {
                        Blur(effect: UIBlurEffect(style: .systemMaterial))
                            .overlay(
                                (detailState == .deleting ? Color("red"): Color.clear)
                                    .blendMode(settings.darkMode ? .color : .plusDarker)
                                    .opacity(settings.darkMode ? 0.4 : 0.3)
                            ).cornerRadius(12)
                            .animation(.spring())
                        
                        Image(systemName: "trash")
                            .scaleEffect(detailState == .deleting ? 1.25 : 1)
                            .foregroundColor(detailState == .deleting ? Color("red") : Color("text"))
                            .animation(.spring())
                        
                    }.frame(height: buttonSize)
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
                })
                
                
                
                // View Text button
                
                Button(action: {
                    detailState = detailState == .text ? .none : .text
                    hapticFeedback(type: .rigid)
                }){
                    ZStack {
                        Blur(effect: UIBlurEffect(style: .systemMaterial))
                            .cornerRadius(12)
                        Image(systemName: "textformat").padding()
                    }.padding(.vertical)
                    .frame(height: UIScreen.screenHeight * 0.1)
                }.buttonStyle(ShrinkingButtonSpring())
                .transition(.offset(x: 150))
                
                
                // Dismiss Button
                Button(action: {
                    detailState = .none
                    hapticFeedback(type: .rigid)
                    presentationMode.wrappedValue.dismiss()
                }){
                    ZStack {
                        Blur(effect: UIBlurEffect(style: .systemMaterial))
                            .cornerRadius(12)
                        Image(systemName: "chevron.down").padding()
                    }.padding(.vertical)
                    .frame(height: UIScreen.screenHeight * 0.1)
                }.buttonStyle(ShrinkingButtonSpring())
                .transition(.offset(x: 150))
                
            }
        }.padding(.horizontal).padding(.bottom)
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
        let newReceipt = getEmptyReceipt()
        let title = getTitle(text: recognizedText)
    
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
    
    ///``returnScan``
    /// takes in an image and recognized text and applies it to a Receipt variable to be returned.
    /// - Parameter recognizedText: The text from the scanned image, to be placed into a receipt variable.
    /// - Parameter image: The image of the receipt that was scanned.
    static func returnScan(recognizedText: String, image: UIImage = UIImage()) -> Receipt {
        print("\n----------------------------")
        let newReceipt = getEmptyReceipt()
        let title = getTitle(text: recognizedText)
        newReceipt.id = UUID()
        newReceipt.title = title
        print("New Receipt Saving: \(title)")
        newReceipt.body = String(recognizedText.dropFirst((newReceipt.title ?? "").count)).capitalized
        newReceipt.image = imageToData(image: image)
        newReceipt.date = Date()
        newReceipt.folder = Prediction.pointPrediction(text: (title + (newReceipt.body ?? "")))
        Folder.verifyFolder(title: newReceipt.folder ?? "Default")
        print("Receipt created!")
        save()
        return newReceipt
    }
    
    static func getEmptyReceipt() -> Receipt {
        return Receipt(context: PersistenceController.shared.getContext())
    }
    
    /*static func updateReceipt(receipt: Receipt, editedReceipt: (title: String, folder: String, body: String, date: Date)) {
        let receiptFinal = Receipt.getReceipt(title: receipt.title ?? "")
        
        receiptFinal.title = editedReceipt.title
        receiptFinal.body = editedReceipt.body
        receiptFinal.folder = editedReceipt.folder
        receiptFinal.date = editedReceipt.date
        
        Receipt.save()
    } NOT IN USE FOR FULL RELEASE */
    
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
    static func getReceipt(title: String) -> Receipt {
        for receipt in getReceipts() where receipt.title == title {
            return receipt
        }
        return Receipt()
    }
    
    ///``generateRandomReceipts``
    /// Uses a pre-determined array of strings to create receipts. This function generates the receipts at random varying ratios.
    /// Each receipt is saved to the database.
    static func generateRandomReceipts(){
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
                     
                     "Nike\nSneakers - $150.00,\nFootball - $25.00", // sports
                     
                     "SuperCheap Auto\nOil - $120.00,\nBattery - $350.00,\nRims - $75.00" // vehicles
        ]
        if !isTesting(){
            for _ in 0..<10 {
                Receipt.saveScan(recognizedText: scans.randomElement() ?? "")
            }
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



struct ImageView: View {
    var image: Image
    @State var viewingImage: Bool = false
    @State var showingDismiss: Bool = false
    var body: some View {
        image
            .resizable()
            .aspectRatio(contentMode: .fit)
            .cornerRadius(12)
            .padding(.top)
            .onTapGesture {
                withAnimation(.spring()){
                    viewingImage = true
                }
            }.fullScreenCover(isPresented: $viewingImage, content: {
                ZStack {
                    ZoomableScrollView {
                        image
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(12)
                            .padding()
                            .onTapGesture {
                                showingDismiss.toggle()
                            }
                        
                    }.ignoresSafeArea()
                    
                    if showingDismiss {
                        VStack {
                            Spacer()
                            
                            Button(action: {
                                viewingImage = false
                            }){
                                ZStack {
                                    Blur(effect: UIBlurEffect(style: .systemMaterial))
                                    Text("Dismiss")
                                }.animation(.spring())
                                .frame(width: UIScreen.screenWidth * 0.3, height: UIScreen.screenHeight * 0.065)
                                .cornerRadius(12)
                            }.buttonStyle(ShrinkingButton())
                                .transition(AnyTransition.move(edge: .bottom).combined(with: .opacity))
                                .animation(.spring())
                        }
                    }
                }.animation(.spring())
            })
    }
}
