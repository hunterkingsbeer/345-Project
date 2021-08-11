//
//  Receipt.swift
//  COSC345-Project
//
//  Created by Hunter Kingsbeer on 27/07/21.
//

import Foundation
import CoreData
import SwiftUI

enum DetailState {
    case none
    case image
    case deleting
    case editing
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
                    Text("\(receipt.store ?? "").")
                        .font(.system(.title))
                    Text("\(receipt.date ?? Date())")
                        .font(.caption)
                    Divider()
                    Text(receipt.body ?? "")
                    Spacer()
                }.padding(.horizontal).padding(.bottom, 50).padding(.top, 20)
            }
            
            VStack {
                Spacer()
                
                HStack {
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
                                    if detailState == .image && !UIDevice.current.isSimulator {
                                        Image(data: receipt.image)! // find some way to not use !, causes crashes by forcing a view with an optional variable (which is nil)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                    } else {
                                        Image(systemName: "trash")
                                    }
                                }
                            }.padding(.vertical)
                            .frame(height: UIScreen.screenHeight * 0.1)
                        }.buttonStyle(ShrinkingButton())
                        .transition(.offset(x: -150))
                    }
                    
                    Button(action: {
                        detailState = detailState == .image ? .none : .image
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }){
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color("object"))
                            VStack {
                                if detailState == .image && !UIDevice.current.isSimulator {
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
                    
                    if detailState != .image {
                        Button(action: {
                            detailState = detailState == .editing ? .none : .editing
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }){
                            ZStack {
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color(detailState == .editing ? "green" : "object"))
                                VStack {
                                    if detailState == .image && !UIDevice.current.isSimulator {
                                        (Image(data: receipt.image) ?? Image(""))
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                    } else {
                                        Image(systemName: "pencil")
                                    }
                                }.padding()
                            }.padding(.vertical)
                            .frame(height: UIScreen.screenHeight * 0.1)
                        }.buttonStyle(ShrinkingButton())
                        .transition(.offset(x: 150))
                    }
                }.padding(.horizontal)
            }
        }.padding(.bottom)
        .background(Color("background"))
        .ignoresSafeArea(edges: /*@START_MENU_TOKEN@*/.bottom/*@END_MENU_TOKEN@*/)
    }
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
            .fill(Color("accent"))
            .overlay(
                // the title and body
                HStack (alignment: .center){
                    Image(systemName: Folder.getIcon(title: receipt.folder ?? "doc.plaintext"))
                    VStack(alignment: .leading) {
                        Text(receipt.store ?? "")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                        Text("\(getDate())")
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                    }
                    Spacer()
                    if pendingDelete == true {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.red)
                            .overlay(Image(systemName: "xmark")
                                        .foregroundColor(Color("background"))
                                        .font(.system(size: 15, weight: .bold, design: .rounded)))
                            .frame(width: UIScreen.screenHeight*0.05).padding(.vertical, 2)
                            .onTapGesture {
                                Receipt.delete(receipt: receipt)
                            }.transition(.scale(scale: 0.0).combined(with: .opacity))
                    }
                }.padding(10)
            ).animation(.spring())
            .frame(height: UIScreen.screenHeight * 0.08)
            .sheet(isPresented: $selected) { ReceiptDetailView(receipt: receipt) }
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
    
    func getDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMM yyyy."
        return formatter.string(from: receipt.date ?? Date())
    }
}

/// Extension of the Receipt object.
extension Receipt {
    /// Converts scanned text into a new Receipt object.
    static func saveScan(recognizedText: String, image: UIImage = UIImage()){
        let viewContext = PersistenceController.shared.getContext()
        
        let newReceipt = Receipt(context: viewContext)
        let title = String(recognizedText.components(separatedBy: CharacterSet.newlines).first!).capitalized
    
        newReceipt.id = UUID()
        newReceipt.store = title
        newReceipt.body = String(recognizedText.dropFirst((newReceipt.store ?? "").count)).capitalized
        newReceipt.image = image == nil ? UIImage().jpegData(compressionQuality: 0.5) : image.jpegData(compressionQuality: 0.5) // warning is incorrect, this is only true when a default value is applied. Valid images are passed.
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
