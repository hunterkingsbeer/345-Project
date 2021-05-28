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
        }.ignoresSafeArea(.keyboard)
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
            validScanAlert = validScan == .invalidScan ? true : false // if validScanType == invalid then alert the user
            
            if validScan == .validScan { // IMPROVE THIS! Go to a "is this correct?" screen
                Receipt.saveScan(recognizedText: recognizedText)
                withAnimation(.spring()) {
                    addPanelState = .homepage
                }
            }
        }).alert(isPresented: $validScanAlert){
            Alert(
                title: Text("Receipt Not Saved!"),
                message: Text("This image is not valid. Try something else."),
                dismissButton: .default(Text("Okay"))
            )
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
        sortDescriptors: [NSSortDescriptor(keyPath: \Folder.receiptCount, ascending: false)],
        animation: .spring())
    var folders: FetchedResults<Folder>
 
    let size : CGFloat
    @Binding var dashPanelState : DashPanelType
    @State var toolbarFocus : ToolbarFocusType = .homepage // 0 = none, 1 = settings, 2 = notifications
    
    var body: some View {
        VStack(alignment: .center){
            DashboardToolbar(size: size, toolbarFocus: $toolbarFocus).frame(height: size/3.5)
            
            Divider()
            
            if toolbarFocus == .homepage {
                if receipts.count > 0 {
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
        sortDescriptors: [NSSortDescriptor(keyPath: \Folder.receiptCount, ascending: false)],
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
            ForEach(0..<7){ index in // could probably be a list, however the list goes darkmode though which is a bit weird
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
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Receipt.date, ascending: false)], animation: .spring())
    var receipts: FetchedResults<Receipt>
    
    @Binding var dashPanelState : DashPanelType
    @State var userSearch : String = ""
    
    //settings
    @State var warrenty = false
    @State var favorites = false
    
    var body: some View {
        VStack {
            // title
            Text("Receipts")
                .font(.system(.largeTitle, design: .rounded)).bold()
                .foregroundColor(.black)

            // search bar
            SearchBar(userSearch: $userSearch, warrenty: $warrenty, favorites: $favorites)
            
            // receipts including search results
            ScrollView(showsIndicators: false) {
                ForEach(receipts.filter({ userSearch.count > 0 ? $0.body!.localizedCaseInsensitiveContains(userSearch) ||  $0.folder!.localizedCaseInsensitiveContains(userSearch)  || $0.store!.localizedCaseInsensitiveContains(userSearch) : $0.body!.count > 0 })){ receipt in
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
        }.padding().ignoresSafeArea(.keyboard)
    }
}

/// Receipt view - The receipt that is displayed, starts minimized then after interaction expands to full size
struct ReceiptView: View {
    @State var receipt : Receipt
    @State var selected : Bool = false
    @State var pendingDelete = false
    
    var body: some View {
        RoundedRectangle(cornerRadius: 18)
            .fill(Color("grey"))
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
                            Text("Total")
                                .font(.system(.subheadline, design: .rounded))
                                .padding(.bottom, -5)
                            Divider()//.padding(.leading, 20)
                            Text(receipt.total > 0 ? "$\(receipt.total , specifier: "%.2f")" : "Unknown")
                                .font(.system(.body, design: .rounded))
                        }
                    }
                }.padding().foregroundColor(.black)
                
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
            VStack{
                if pendingDelete == true {
                    HStack{
                        Spacer()
                        Circle().fill(Color.red)
                            .frame(width: UIScreen.screenHeight*0.05,
                                   height: UIScreen.screenHeight*0.05)
                            .overlay(Image(systemName: "xmark").foregroundColor(.white))
                            .onTapGesture{
                                Receipt.delete(receipt: receipt)
                            }
                    }
                    Spacer()
                }
            }
        )
    }
}

/// Folder Collection View - View that displays all the folders
struct FolderCollectionView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Folder.favorite, ascending: false),
                          NSSortDescriptor(keyPath: \Folder.receiptCount, ascending: false),
                          NSSortDescriptor(keyPath: \Folder.title, ascending: false)],
        animation: .spring())
    var folders: FetchedResults<Folder>
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Receipt.date, ascending: false)],
        animation: .spring())
    var receipts: FetchedResults<Receipt>
    
    //settings
    @State var warrenty = false
    @State var favorites = false
    @State var currentFolder : String = ""
    @State var userSearch : String = ""
    @Binding var dashPanelState : DashPanelType
    let columns = [
            GridItem(.flexible()),
            GridItem(.flexible())
    ]
    
    var body: some View {
        VStack {
            HStack {
                if viewingFolder() {
                    Button(action: {
                        currentFolder = ""
                    }){
                        Image(systemName: "chevron.left")
                            .font(.title)
                            .foregroundColor(.black)
                    }
                }
                Spacer()
                Text(viewingFolder()  ? "\(currentFolder)" : "All Folders")
                    .font(.system(.largeTitle, design: .rounded)).bold()
                    .foregroundColor(.black)
                Spacer()
                if viewingFolder() {
                    Button(action:{
                        Folder.getFolder(folderTitle: currentFolder).favorite.toggle()
                        Folder.save()
                    }){
                        Image(systemName: Folder.getFolder(folderTitle: currentFolder).favorite ? "bookmark.fill" : "bookmark") // just to make sure its the exact size
                            .font(.title)
                            .foregroundColor(Color(Folder.getFolder(folderTitle: currentFolder).favorite ? Folder.getFolder(folderTitle: currentFolder).color ?? "black" : "black")) // make it clear so we dont see it
                            .padding(.leading, -10)
                    }
                }
            }.padding(.horizontal)
            
            SearchBar(userSearch: $userSearch, warrenty: $warrenty, favorites: $favorites)
                .padding(.horizontal)
            
            ScrollView(showsIndicators: false) {
                if viewingFolder() && Folder.getFolder(folderTitle: currentFolder).receiptCount > 0 {
                    ForEach(receipts.filter({ userSearch.count > 0 ? $0.body!.localizedCaseInsensitiveContains(userSearch) ||  $0.folder!.localizedCaseInsensitiveContains(userSearch)  ||   $0.store!.localizedCaseInsensitiveContains(userSearch) : $0.folder! == currentFolder })){ receipt in
                        ReceiptView(receipt: receipt)
                    }.transition(AnyTransition.move(edge: .trailing)).animation(.spring())
                    .padding(.horizontal)
                } else {
                    LazyVGrid(columns: columns) {
                        ForEach(folders.filter({ userSearch.count > 0 ? $0.title!.localizedCaseInsensitiveContains(userSearch) : $0.title!.count > 0 })){ folder in
                            FolderView(folder: folder, currentFolder: $currentFolder)
                        }
                    }//.transition(AnyTransition.move(edge: .leading)).animation(.spring())
                    .padding(.horizontal)
                }
                
            }.cornerRadius(18)
            
            Button(action: {
                withAnimation(.spring()){
                    dashPanelState = .homepage
                    currentFolder = ""
                }
            }){
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.red)
                    .overlay(
                        Image(systemName: "xmark")
                            .font(.system(.largeTitle, design: .rounded))
                            .foregroundColor(.white)
                    ).frame(height: UIScreen.screenHeight*0.1)
                    .padding(.vertical)
            }.buttonStyle(ShrinkingButton()).padding(.horizontal)
            Spacer()
        }.padding(.top)
    }
    
    func viewingFolder() -> Bool {
        return currentFolder.count > 0 ? true : false
    }
}

/// Folder view - Extremely basic folder
struct FolderView: View{
    @State var folder : Folder
    @Binding var currentFolder : String
    @State var pendingDelete = false
    
    var body: some View {
        RoundedRectangle(cornerRadius: 18)
            .fill(Color("grey"))
            .overlay(
                VStack {
                    Image(systemName: folder.icon ?? "folder")
                        .font(.system(size: 50))
                        .foregroundColor(Color.black)
                    Text(folder.title ?? "Folder")
                        .font(.system(.title, design: .rounded))
                        .padding(.bottom, 10)
                    
                    //Spacer()
                    Text("\(folder.receiptCount)")
                        .font(.system(.largeTitle, design: .rounded)).bold()
                        .foregroundColor(.black)
                }.padding().padding(.top, 10).foregroundColor(.black)
            ).frame(height: UIScreen.screenHeight*0.25)
            .onTapGesture {
                currentFolder = currentFolder == folder.title! ? "" : folder.title!
                pendingDelete = false
            }.onLongPressGesture(minimumDuration: 0.25, maximumDistance: 2, perform: {
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
            .overlay(
                // the delete button
                VStack{
                    HStack{
                        Spacer()
                        if pendingDelete == true {
                            Circle().fill(Color.red)
                                .frame(width: UIScreen.screenHeight*0.05,
                                       height: UIScreen.screenHeight*0.05)
                                .overlay(Image(systemName: "xmark").foregroundColor(.white))
                                .onTapGesture{
                                    Folder.delete(folder: folder)
                                }
                        } else if folder.favorite {
                            Image(systemName: "bookmark.fill")
                                .font(.title)
                                .foregroundColor(Color(folder.color ?? "black"))
                                .frame(width: UIScreen.screenHeight*0.05,
                                       height: UIScreen.screenHeight*0.05)
                                .padding(5)
                        }
                    }
                    Spacer()
                    
                }
            )
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

/// search bar along with filters
struct SearchBar: View {
    @Binding var userSearch: String
    @State var showingFilters : Bool = false
    @Binding var warrenty : Bool
    @Binding var favorites : Bool
    
    var body: some View {
        VStack {
            HStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color("grey"))
                    //.strokeBorder(Color("grey"), lineWidth: 1)
                    .frame(height: UIScreen.screenHeight*0.05).frame(minWidth: 0, maxWidth: .infinity)
                    .overlay(
                        HStack {
                            Image(systemName: "magnifyingglass")
                            CustomTextField(placeholder: Text("Search...").foregroundColor(.black),text: $userSearch)
                                .ignoresSafeArea(.keyboard)
                            Spacer()
                            if userSearch.count > 0{
                                Button(action: {
                                    userSearch = ""
                                }){
                                    Image(systemName: "xmark")
                                }
                            }
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
            
            if showingFilters {
                VStack {
                    Group {
                        //Toggle("Warrenty", isOn: $warrenty)  not working yet
                        Toggle("Favorites", isOn: $favorites)
                    }.foregroundColor(.black).font(.system(.body, design: .rounded))
                }.padding(.horizontal, 5)
            }
        }
    }
}
