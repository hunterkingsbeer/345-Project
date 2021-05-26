//
//  ContentView.swift
//  COSC345-Project
//
//  Created by Hunter Kingsbeer on 7/05/21.
//

import SwiftUI
import CoreData


// -------------------------------------------------------------------------- PREVIEW

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

// -------------------------------------------------------------------------- VIEWS

/// AddPanelType - Holds the various states for the add receipt panel
enum AddPanelType {
    case homepage
    case camera
    case gallery
}

/// DashPanelType - Holds the various states for the dashboard panel
enum DashPanelType {
    case homepage
    case receipts
    case folders
    case settings
    case notifications
}
/**
 Content View stuff
 */
struct ContentView: View {
    @State var addPanelState : AddPanelType = .homepage // need to make these global vars
    @State var dashPanelState : DashPanelType = .homepage

    var body: some View {
        NavigationView {
            
            ZStack(alignment: .top) {
                // BACKGROUND BLOBS ------------------
                BackgroundView(addPanelState: addPanelState, dashPanelState: dashPanelState)
                
                // COMPANY TITLE ------------------
                VStack{
                    Text("Receipted.")
                        .foregroundColor(.white)
                        .font(.system(.title, design: .rounded)).bold()
                    
                    // DASHBOARD (UPPER) ------------------
                    if addPanelState == .homepage {
                        DashboardPanel(size: UIScreen.screenHeight * 0.55, dashPanelState: $dashPanelState)
                            .padding(.bottom, dashPanelState == .homepage ? 15 : 0)
                            .transition(AnyTransition.opacity.combined(with: .scale(scale: 0.75)))
                    }
                    
                    // ADD RECEIPT (LOWER) ------------------
                    if dashPanelState == .homepage {
                        AddPanel(addPanelState: $addPanelState)
                            .transition(AnyTransition.opacity.combined(with: .scale(scale: 0.75)))
                    }
                }.padding(.horizontal, addPanelState == .homepage ? 15 : 0)
            }.navigationBarTitle("").navigationBarHidden(true)
        }
    }
}

/// Add panel Parent Struct - Handles the various view states for the add receipt panel
struct AddPanel: View {
    @Binding var addPanelState : AddPanelType
    
    var body: some View {
        RoundedRectangle(cornerRadius: 25)
            .foregroundColor(.white)
            .overlay(
                VStack{
                    if addPanelState == .homepage {
                        AddPanelHomepageView(addPanelState: $addPanelState)
                            .transition(AnyTransition.move(edge: .bottom).combined(with: .opacity)).animation(.spring())
                    } else {
                        AddPanelDetailView(addPanelState: $addPanelState)
                            .transition(AnyTransition.move(edge: .bottom).combined(with: .opacity)).animation(.spring())
                    }
                }
            ).foregroundColor(.black)
    }
}

/// Add panel Homepage View - Displays the option to either add a receipt via gallery or camera
struct AddPanelHomepageView: View {
    @Binding var addPanelState : AddPanelType
    var body: some View {
        HStack {
            HStack{
                Spacer()
                Button(action: {
                    withAnimation(.spring()){
                        addPanelState = .gallery
                    }
                }){
                    VStack{
                        Image(systemName: "doc")
                            .font(.largeTitle)
                        Text("Add from")
                            .font(.system(.title, design: .rounded))
                        Text("Gallery")
                            .font(.system(.title, design: .rounded)).bold()
                    }.frame(minWidth: 0, maxWidth: .infinity)
                    .frame(minHeight: 0, maxHeight: .infinity)
                    .contentShape(Rectangle())
                }.buttonStyle(ShrinkingButton())
                Spacer()
                
                Divider().padding(.vertical, 75)
                
                Spacer()
                Button(action: {
                    withAnimation(.spring()){
                        addPanelState = .camera
                    }
                }){
                    VStack{
                        Image(systemName: "camera")
                            .font(.largeTitle)
                        Text("Add from")
                            .font(.system(.title, design: .rounded))
                        Text("Camera")
                            .font(.system(.title, design: .rounded)).bold()
                    }.frame(minWidth: 0, maxWidth: .infinity)
                    .frame(minHeight: 0, maxHeight: .infinity)
                    .contentShape(Rectangle())
                }.buttonStyle(ShrinkingButton())
                Spacer()
            }
        }
    }
}

enum ValidScanType {
    case noScan
    case validScan
    case invalidScan
}

/// Add panel detail view - Handles the respective input of receipts
struct AddPanelDetailView: View {
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Receipt.date, ascending: false)],
        animation: .spring())
    var receipts: FetchedResults<Receipt>
    
    @Binding var addPanelState : AddPanelType
    @State var recognizedText : String = ""
    @State var validScan : ValidScanType = .noScan
    @State var validScanAlert : Bool = false
    
    var body: some View {
        VStack{
            if addPanelState == .camera {
                Text("Scan using Camera")
                    .font(.largeTitle)
                    .padding(.bottom, 5)
                ScanDocumentView(recognizedText: self.$recognizedText, validScan: $validScan)
                    .cornerRadius(18)
                    .animation(.spring())
            } else if addPanelState == .gallery {
                Text("Scan using Gallery")
                    .font(.largeTitle)
                    .padding(.bottom, 5)
                
                ImagePicker(recognizedText: self.$recognizedText, validScan: $validScan)
                    .cornerRadius(18)
                    .animation(.spring())
            }
            Button(action: {
                withAnimation(.spring()){
                    addPanelState = .homepage
                }
            }){
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.red)
                    .overlay(
                        Image(systemName: "xmark")
                            .font(.system(.largeTitle, design: .rounded))
                            .foregroundColor(.white)
                    ).frame(height: UIScreen.screenHeight*0.1)
            }.buttonStyle(ShrinkingButton())
            Spacer()
        }.padding()
        .onChange(of: recognizedText, perform: { _ in
            validScanAlert = validScan == .invalidScan ? true : false
            debugPrint("VALID SCAN ALERT BOOL \(validScanAlert)")
            if validScan == .validScan { // IMPROVE THIS! Go to a "is this correct?" screen
                saveScan()
                withAnimation(.spring()) {
                    addPanelState = .homepage
                }
            }
        }).alert(isPresented: $validScanAlert){
            Alert(
                title: Text("Receipt Not Saved!"),
                message: Text("This scan is not valid. Try scanning again."),
                dismissButton: .default(Text("Okay"))
            )
        }
    }
    
    // takes the recognized text and transforms it into a receipt object
    func saveScan(){
        let newReceipt = Receipt(context: viewContext)
        
        newReceipt.id = UUID()
        newReceipt.store = String(recognizedText.components(separatedBy: CharacterSet.newlines).first!)
        newReceipt.body = String(recognizedText.dropFirst((newReceipt.store ?? "").count))
        newReceipt.date = Date()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7){
            do {
                try self.viewContext.save()
            } catch {
                print("Failed to save the receipt's context: \(error.localizedDescription)")
            }
        }
    }
}

/// Dashboard Panel - Handles the various view states for the dashboard panel
struct DashboardPanel: View{
    let size : CGFloat
    @Binding var dashPanelState : DashPanelType
    
    var body: some View{
        RoundedRectangle(cornerRadius: 25)
            .overlay(
                VStack {
                    if dashPanelState == .homepage {
                        DashboardHomePageView(size: size, dashPanelState: $dashPanelState)
                            .transition(AnyTransition.move(edge: .bottom).combined(with: .opacity)).animation(.spring())
                    } else {
                        if dashPanelState == .receipts { // receipts
                            ReceiptCollectionView(dashPanelState: $dashPanelState)
                                .transition(AnyTransition.move(edge: .top).combined(with: .opacity)).animation(.spring()) // usually bottom
                                .frame(width: UIScreen.screenWidth*0.9)
                        } else if dashPanelState == .folders { // folders
                            FolderCollectionView(dashPanelState: $dashPanelState)
                                .transition(AnyTransition.move(edge: .top).combined(with: .opacity)).animation(.spring())
                        }
                    }
                }
            ).frame(height: dashPanelState == .homepage ? size : UIScreen.screenHeight*0.84)
    }
}

enum ToolbarFocusType {
    case homepage
    case settings
    case notifications
}

/// DashboardHomePageView - Holds the Toolbar (and its settings/notifations views), Receipts/Folders button.
// THIS DEFINITELY could be stream lined. Look into this!!!!
// Work settings/notifications into DashboardToolbar view
struct DashboardHomePageView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Receipt.date, ascending: false)],
        animation: .spring())
    var receipts: FetchedResults<Receipt>
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Folder.title, ascending: false)],
        animation: .spring())
    var folders: FetchedResults<Folder>
 
    let size : CGFloat
    @Binding var dashPanelState : DashPanelType
    @State var toolbarFocus : ToolbarFocusType = .homepage //0 = none, 1 = settings, 2 = notifications
    
    var body: some View {
        VStack(alignment: .center){
            DashboardToolbar(size: size, toolbarFocus: $toolbarFocus).frame(height: size/3.5)
            
            Divider()
            
            if toolbarFocus == .homepage {
                if receipts.count != 0 || folders.count != 0 {
                    ReceiptsFoldersButtons(dashPanelState: $dashPanelState)
                        .transition(AnyTransition.scale(scale: 0.8).combined(with: .opacity))
                } else {
                    Spacer()
                    Text("Add a receipt from\none of the button below.").font(.system(.title, design: .rounded))
                    Spacer()
                }
            } else if toolbarFocus == .settings {
                SettingsView()
                    .transition(AnyTransition.move(edge: .leading).combined(with: .opacity))
            } else if toolbarFocus == .notifications {
                NotificationsView()
                    .transition(AnyTransition.move(edge: .trailing).combined(with: .opacity))
            }
        }.foregroundColor(.black).padding(.horizontal)
    }
}

/// DashboardToolBar view - The two buttons at the top that lead to settings/notifications screens
struct DashboardToolbar: View {
    let size : CGFloat
    @Binding var toolbarFocus: ToolbarFocusType
    
    var body: some View {
        HStack {
            Spacer()
            if toolbarFocus != .notifications {
                Button(action: {
                    withAnimation(.spring()) {
                        toolbarFocus = toolbarFocus != .settings ? .settings : .homepage
                    }
                }){
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 40))
                        .scaleEffect((toolbarFocus == .settings ? 1.4 : 1))
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(minHeight: 0, maxHeight: .infinity)
                        .transition(AnyTransition.move(edge: .leading).combined(with: .opacity))
                }.buttonStyle(ShrinkingButton()).contentShape(Rectangle())
            }
            
            Spacer()
            if toolbarFocus == .homepage {
                Divider().padding(.vertical, 35)
                    .transition(AnyTransition.scale(scale: 0.6).combined(with: .opacity))
                Spacer()
            }
            
            if toolbarFocus != .settings {
                Button(action: {
                    withAnimation(.spring()) {
                        toolbarFocus = toolbarFocus != .notifications ? .notifications : .homepage
                    }
                }){
                    Image(systemName: "bell.fill")
                        .font(.system(size: 40))
                        .scaleEffect((toolbarFocus == .notifications ? 1.4 : 1))
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(minHeight: 0, maxHeight: .infinity)
                        .transition(AnyTransition.move(edge: .trailing).combined(with: .opacity))
                }.buttonStyle(ShrinkingButton()).contentShape(Rectangle())
            }
            Spacer()
        }.frame(height: size/3.5)
        .frame(minWidth: 0, maxWidth: .infinity)
    }
}

/// ReceiptsFoldersButtons - The view that holds the buttons that change the dashPanelState to display receipts/folders
struct ReceiptsFoldersButtons: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Receipt.date, ascending: false)],
        animation: .spring())
    var receipts: FetchedResults<Receipt>
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Folder.title, ascending: false)],
        animation: .spring())
    var folders: FetchedResults<Folder>
    
    @Binding var dashPanelState : DashPanelType
    
    var body: some View {
        VStack {
            Button(action: {
                withAnimation(.spring() ) {
                    dashPanelState = dashPanelState != .homepage ? .homepage : .receipts
                }
            }){
                VStack{
                    Spacer()
                    Text("\(receipts.count)").font(.system(.title, design: .rounded))
                    Text("Receipts").font(.system(.largeTitle, design: .rounded)).bold()
                    Spacer()
                }.frame(minWidth: 0, maxWidth: .infinity)
                .contentShape(Rectangle())
            }.buttonStyle(ShrinkingButton())
            
            Divider()
            
            Button(action: {
                withAnimation(.spring()) {
                    dashPanelState = dashPanelState != .homepage ? .homepage : .folders
                }
            }){
                VStack{
                    Spacer()
                    //Text("\(folders.count)").font(.system(.title, design: .rounded))
                    Text("\(folders.count)").font(.system(.title, design: .rounded))
                    Text("Folders").font(.system(.largeTitle, design: .rounded)).bold()
                    Spacer()
                }.frame(minWidth: 0, maxWidth: .infinity)
                .contentShape(Rectangle())
            }.buttonStyle(ShrinkingButton())
        }
    }
}

/// SettingsView - The settings menu
struct SettingsView: View {
    var body: some View {
        VStack {
            ForEach(0..<7){ index in // could probably be a list, goes darkmode though bit weird
                HStack {
                    Text("Setting \(index)")
                        .font(.system(.body, design: .rounded))
                        .padding(.leading)
                    Spacer()
                }
                Divider()
            }.frame(minWidth: 0, maxWidth: .infinity)
            .contentShape(Rectangle())
            Spacer()
        }
    }
}

/// NotifcationsView - The notifications menu
struct NotificationsView: View {
    var body: some View {
        VStack{
            ForEach(0..<7){ index in // could probably be a list, goes darkmode though bit weird
                HStack {
                    Text("Notification \(index)")
                        .font(.system(.body, design: .rounded))
                        .padding(.leading)
                    Spacer()
                }
                Divider()
            }.frame(minWidth: 0, maxWidth: .infinity)
            .contentShape(Rectangle())
            Spacer()
        }
    }
}

/// Receipt Collection View - View that displays all the receipts (interactive), along with a search/filter bar
struct ReceiptCollectionView: View {
    @Environment(\.colorScheme) var colorScheme
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Receipt.date, ascending: false)],
        animation: .spring())
    var receipts: FetchedResults<Receipt>
    
    @Binding var dashPanelState : DashPanelType
    @State var showingFilters : Bool = false
    @State var input : String = ""
    
    //settings
    @State var warrenty = false
    @State var favorites = false
    @State var category = ""
    var categories = ["Groceries", "Technology", "Utilities"]
    
    var body: some View {
        VStack {
            // title
            Text("Receipts")
                .font(.system(.largeTitle, design: .rounded)).bold()
                .foregroundColor(.black)

            // search bar
            HStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color("grey"))
                    //.strokeBorder(Color("grey"), lineWidth: 1)
                    .frame(height: UIScreen.screenHeight*0.05).frame(minWidth: 0, maxWidth: .infinity)
                    .overlay(
                        HStack {
                            Image(systemName: "magnifyingglass")
                            CustomTextField(placeholder: Text("Search...").foregroundColor(.black),text: $input)
                            //TextField("Search...", text: $input)
                            Spacer()
                        }.foregroundColor(.black).padding(.horizontal, 10)
                )
                Button(action:{
                    showingFilters = showingFilters ? false : true
                }){
                    Image(systemName: "slider.horizontal.3")
                        .font(.title)
                        .foregroundColor(.black)
                }.buttonStyle(ShrinkingButton())
            }.padding(.bottom, 1)
            
            // search/display filters
            if showingFilters {
                VStack {
                    Group {
                        HStack {
                            Text("Category")
                            Spacer()
                            Text("something")
                        }
                        Toggle("Warrenty", isOn: $warrenty)
                        Toggle("Favorites", isOn: $favorites)
                    }.foregroundColor(.black).font(.system(.body, design: .rounded))
                }.padding(.horizontal)
            }
            
            // receipts
            ScrollView(showsIndicators: false) {
                ForEach(receipts){ receipt in
                    ReceiptView(receipt: receipt)
                }
            }.cornerRadius(18)
            
            // close button
            Button(action: {
                withAnimation(.spring()){
                    dashPanelState = .homepage
                }
            }){
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.red)
                    .overlay(
                        Image(systemName: "xmark")
                            .font(.system(.largeTitle, design: .rounded))
                            .foregroundColor(.white)
                    ).frame(height: UIScreen.screenHeight*0.1)
            }.buttonStyle(ShrinkingButton())
            Spacer()
        }.padding()
    }
}

/// Receipt view - The receipt that is displayed, starts minimized then after interaction expands to full size
struct ReceiptView: View {
    @Environment(\.managedObjectContext) var viewContext
    
    @State var receipt : Receipt
    @State var selected : Bool = false
    @State var pendingDelete = false
    
    var body: some View {
        RoundedRectangle(cornerRadius: 18)
            .fill(Color("grey"))
            .overlay(
                // the title and body
                VStack {
                    HStack {
                        // title
                        Text(receipt.store ?? "")
                            .font(.system(size: selected ? 30 : 22,
                                          weight: selected ? .bold : .regular,
                                          design: .rounded))
                        Spacer()
                    }
                    if selected {
                        // body
                        Text(receipt.body ?? "")
                            .padding(.vertical, 5)
                    }
                    Spacer()
                    HStack {
                        Spacer()
                        VStack (alignment: .trailing){
                            Text("Total")
                            Text("$\(receipt.total , specifier: "%.2f")").font(.system(.title, design: .rounded)).bold()
                        }
                    }
                }.padding().foregroundColor(.black)
                
            ).frame(height: selected ? UIScreen.screenHeight*0.5 : UIScreen.screenHeight*0.12)
            .onTapGesture {
                selected.toggle()
            }
            .onLongPressGesture(minimumDuration: 0.1, maximumDistance: 2, perform: {
                pendingDelete.toggle()
            })
        .overlay(
            // the delete button
            VStack{
                if pendingDelete == true {
                    HStack{
                        Spacer()
                        Circle().fill(Color.red)
                            .frame(width: UIScreen.screenHeight*0.05,
                                   height: UIScreen.screenHeight*0.05)
                            .overlay(Image(systemName: "xmark").foregroundColor(.white))
                            .onTapGesture{
                                self.delete()
                            }
                    }
                    Spacer()
                }
            }
        )
    }
    
    private func delete() {
        self.viewContext.delete(receipt)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
            do {
                try self.viewContext.save()
            } catch {
                print("Failed to delete and save the context: \(error.localizedDescription)")
            }
        }
    }
}

/// Folder Collection View - View that displays all the folders
struct FolderCollectionView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Folder.title, ascending: false)],
        animation: .spring())
    var folders: FetchedResults<Folder>
    
    @Binding var dashPanelState : DashPanelType
    let columns = [
            GridItem(.flexible()),
            GridItem(.flexible())
    ]
    
    var body: some View {
        VStack {
            Text("Folders")
                .font(.system(.largeTitle, design: .rounded)).bold()
                .foregroundColor(.black)
            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: columns) {
                    ForEach(folders){ folder in
                        FolderView(folder: folder)
                    }
                }
            }.cornerRadius(18).padding(.horizontal)
            
            Button(action: {
                withAnimation(.spring()){
                    dashPanelState = .homepage
                }
            }){
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.red)
                    .overlay(
                        Image(systemName: "xmark")
                            .font(.system(.largeTitle, design: .rounded))
                            .foregroundColor(.white)
                    ).frame(height: UIScreen.screenHeight*0.1)
                    .padding()
            }.buttonStyle(ShrinkingButton())
            Spacer()
        }.padding(.top)
    }
}

/// Folder view - Extremely basic folder
struct FolderView: View{
    @State var folder : Folder
    
    var body: some View {
        RoundedRectangle(cornerRadius: 18)
            .fill(Color("grey"))
            .overlay(
                VStack {
                    Image(systemName: folder.icon ?? "folder")
                        .font(.system(size: 50))
                    Text(folder.title ?? "Folder")
                        .font(.system(.title, design: .rounded))
                        .padding(.bottom, 10)
                    
                    //Spacer()
                    Text("\(folder.numReceipts)")
                        .font(.system(.largeTitle, design: .rounded)).bold()
                        .foregroundColor(.black)
                }.padding().padding(.top, 10).foregroundColor(.black)
            ).frame(height: UIScreen.screenHeight*0.25)
    }
}

// -------------------------------------------------------------------------- UTILITIES

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

/// Background view - Background of the app
struct BackgroundView: View {
    var addPanelState : AddPanelType
    var dashPanelState : DashPanelType
    
    var body: some View {
        VStack {
            Circle()
                .fill(LinearGradient(gradient: Gradient(colors: [Color("orange"), Color("purple")]),
                                     startPoint: .top, endPoint: .bottom))
                .scaleEffect(x: 1.5) // gives it that clean stretched out look
                .padding(.top, -UIScreen.screenHeight * (dashPanelState == .homepage ? 0.5 : 0.38))
                .animation(.spring())
            
            Spacer()
            
            Circle()
                .fill(LinearGradient(gradient: Gradient(colors: [Color("purple"), Color("cyan")]),
                                     startPoint: .top, endPoint: .bottom))
                .scaleEffect(x: 1.5)
                .padding(.bottom, -UIScreen.screenHeight * (addPanelState == .homepage ? 0.5 : 0.38))
                .animation(.spring())
        }
    }
}
