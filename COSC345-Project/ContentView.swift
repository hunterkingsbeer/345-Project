//
//  ContentView.swift
//  COSC345-Project
//
//  Created by Hunter Kingsbeer on 7/05/21.
//

import SwiftUI
import CoreData


// -------------------------------------------------------------------------- PREVIEW
/// ContentView_Previews is what xCode uses to preview the app in the IDE.
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(UserSettings())
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

// -------------------------------------------------------------------------- VIEWS

/// AddPanelType holds the various states for the Add panel.
enum AddPanelType {
    /// Displays the standard homepage view for the add panel. Two option, add from gallery or camera.
    case homepage
    /// Displays the panel's add from camera view
    case camera
    /// Displays the panel's add from gallery view
    case gallery
}

/// DashPanelType holds the various states for the dashboard panel.
enum DashPanelType {
    /// Displays the standard homepage view for the Dashpanel. Showing the Receipts, folders, settings and notifcations.
    case homepage
    /// Displays the Receipts Collection View
    case receipts
    /// Displays the Folders Collection View
    case folders
    /// Displays the settings view
    case settings
    /// Displays the notifications view
    case notifications
}


/// ContentView is the main content view that is called when starting the app.
struct ContentView: View {
    /// AddPanelType maintains and updates the add panels view state.
    @State var addPanelState : AddPanelType = .homepage // need to make these global vars
    /// DashPanelState maintains and updates the dashboards view state.
    @State var dashPanelState : DashPanelType = .homepage
    /// Settings imports the UserSettings
    @EnvironmentObject var settings : UserSettings

    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                // BACKGROUND BLOBS ------------------
                BackgroundView(addPanelState: addPanelState,
                               dashPanelState: dashPanelState)
                
                // COMPANY TITLE ------------------
                VStack{
                    Spacer()
                    Text("Receipted.")
                        .foregroundColor(Color("text"))
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
                    Spacer()
                }.ignoresSafeArea(.keyboard)
                .padding(.horizontal, addPanelState == .homepage ? 15 : 0)
            }.navigationBarTitle("").navigationBarHidden(true)
            .colorScheme(settings.darkMode ? .dark : .light)
        }
    }
}

/// AddPanel handles the visibility of the various add panel views.
/// - Main Parent: ContentView
struct AddPanel: View {
    /// AddPanelType maintains and updates the add panels view state.
    @Binding var addPanelState : AddPanelType
    
    var body: some View {
        RoundedRectangle(cornerRadius: 25)
            .shadow(color: (Color(.black)).opacity(0.15), radius: 5, x: 0, y: 0)
            .foregroundColor(Color("object"))
            .overlay(
                VStack{
                    if addPanelState == .homepage {
                        AddPanelHomepageView(addPanelState: $addPanelState)
                            .transition(AnyTransition.move(edge: .bottom).combined(with: .opacity)).animation(.spring())
                            .foregroundColor(Color("text"))
                    } else {
                        AddPanelDetailView(addPanelState: $addPanelState)
                            .transition(AnyTransition.move(edge: .bottom).combined(with: .opacity)).animation(.spring())
                            .foregroundColor(Color("text"))
                    }
                }
            ).foregroundColor(.black).animation(.easeInOut)
    }
}

/// AddPanelHomepageView displays the homepage view for the Add Panel.
///  Displays the add a receipt via gallery or camera buttons
/// - Main Parent: AddPanel
struct AddPanelHomepageView: View {
    /// AddPanelType maintains and updates the add panels view state.
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

/// ValidScanType holds the different cases for handling the input of a scan.
enum ValidScanType {
    /// no scan has been input.
    case noScan
    /// A valid scan has been input.
    case validScan
    /// An invalid scan has been input.
    case invalidScan
}

/// AddPanelDetailView shows the expanded Add Panel with respect to the AddPanelState
/// - Main Parent: AddPanel
struct AddPanelDetailView: View {
    /// Fetches receipts entities in CoreData sorting by the NSSortDescriptor.
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Receipt.date, ascending: false)],
        animation: .spring())
    /// Stores the fetched results as an array of Receipt objects.
    var receipts: FetchedResults<Receipt>
    
    /// AddPanelType maintains and updates the add panels view state.
    @Binding var addPanelState : AddPanelType
    /// The recognized text from scanning an image
    @State var recognizedText : String = ""
    /// Whether the scan is valid or not, initially there is .noScan
    @State var validScan : ValidScanType = .noScan
    /// If a scan is not valid, this bool when set to true will trigger an alert
    @State var validScanAlert : Bool = false
    
    var body: some View {
        VStack{
            if addPanelState == .camera {
                Text("Scan using Camera")
                    .font(.system(.title, design: .rounded))
                    .padding(.bottom, 5)
                ScanDocumentView(recognizedText: self.$recognizedText, validScan: $validScan)
                    .cornerRadius(18)
                    .animation(.spring())
            } else if addPanelState == .gallery {
                Text("Scan using Gallery")
                    .font(.system(.title, design: .rounded))
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
            // if validScanType == invalid then alert the user
            
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

/// Dashboard Panel handles the various view states for the dashboard panel
/// - Main Parent: ContentView
struct DashboardPanel: View{
    /// The fixed size of the Dashboard panel
    let size : CGFloat
    /// DashPanelState maintains and updates the dashboards view state.
    @Binding var dashPanelState : DashPanelType
    /// Settings imports the UserSettings
    @EnvironmentObject var settings : UserSettings
    
    var body: some View{
        RoundedRectangle(cornerRadius: 25)
            .shadow(color: Color(.black).opacity(0.15), radius: 5, x: 0, y: 0)
            .foregroundColor(Color("object"))
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
            .animation(.easeInOut)
    }
}

/// ToolbarFocusType holds the different cases for the dashboard's toolbar views
enum ToolbarFocusType {
    /// This is the default view, showing neither of the toolbar views
    case homepage
    /// Displays the settings view
    case settings
    /// Displays the notification view
    case notifications
}

// THIS DEFINITELY could be stream lined. Look into this!!!!
// Work settings/notifications into DashboardToolbar view
/// DashboardHomePageView holds the Dashboard's toolbar, and the receipts/folders section.
/// - Main Parent: DashboardPanel
struct DashboardHomePageView: View {
    /// Fetches Receipt entities in CoreData sorting by the NSSortDescriptor.
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Receipt.date, ascending: false)],
        animation: .spring())
    /// Stores the fetched results as an array of Receipt objects.
    var receipts: FetchedResults<Receipt>
    /// Fetches Folder entities in CoreData sorting by the NSSortDescriptor.
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Folder.receiptCount, ascending: false)],
        animation: .spring())
    /// Stores the fetched results as an array of Folder objects.
    var folders: FetchedResults<Folder>
    /// Fixed size for the dashboard panel
    let size : CGFloat
    /// DashPanelState maintains and updates the dashboards view state.
    @Binding var dashPanelState : DashPanelType
    /// ToolbarFocus maintains and updates the ToolBar view state.
    @State var toolbarFocus : ToolbarFocusType = .homepage // 0 = none, 1 = settings, 2 = notifications
    
    var body: some View {
        VStack(alignment: .center){
            DashboardToolbar(size: size, toolbarFocus: $toolbarFocus).frame(height: size/3.5)
                .foregroundColor(Color("text"))
            
            Divider()
            
            if toolbarFocus == .homepage {
                if receipts.count > 0 {
                    ReceiptsFoldersButtons(dashPanelState: $dashPanelState)
                        .transition(AnyTransition.scale(scale: 0.8).combined(with: .opacity))
                } else {
                    Spacer()
                    Text("Add a receipt from\none of the buttons below.")
                        .font(.system(.title, design: .rounded))
                        .foregroundColor(Color("text"))
                    Spacer()
                }
            } else if toolbarFocus == .settings {
                SettingsView()
                    .transition(AnyTransition.move(edge: .leading).combined(with: .opacity))
                    .foregroundColor(Color("text"))
            } else if toolbarFocus == .notifications {
                NotificationsView()
                    .transition(AnyTransition.move(edge: .trailing).combined(with: .opacity))
                    .foregroundColor(Color("text"))
            }
        }.foregroundColor(.black).padding(.horizontal)
    }
}

/// DashboardToolBar holds the two buttons at the top that lead to settings/notifications screens
/// - Main Parent: DashboardHomePageView
struct DashboardToolbar: View {
    /// The fixed size of the dashboard
    let size : CGFloat
    /// toolbarFocus
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
                        .font(.system(size: 40)).foregroundColor(Color("text"))
                        .scaleEffect((toolbarFocus == .settings ? 1.4 : 1))
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(minHeight: 0, maxHeight: .infinity)
                        .transition(AnyTransition.move(edge: .leading).combined(with: .opacity))
                        .animation(.spring())
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

/// ReceiptsFoldersButtons is the view that holds the buttons that change the dashPanelState to display receipts/folders
/// - Main Parent: DashboardHomePageView
struct ReceiptsFoldersButtons: View {
    /// Fetches Receipt entities in CoreData sorting by the NSSortDescriptor.
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Receipt.date, ascending: false)],
        animation: .spring())
    /// Stores the fetched results as an array of Receipt objects.
    var receipts: FetchedResults<Receipt>
    /// Fetches Folder entities in CoreData sorting by the NSSortDescriptor.
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Folder.receiptCount, ascending: false)],
        animation: .spring())
    /// Stores the fetched results as an array of Folder objects.
    var folders: FetchedResults<Folder>
    /// DashPanelState maintains and updates the dashboards view state.
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
                    Text("Receipt\(receipts.count>1 ? "s" : "")").font(.system(.largeTitle, design: .rounded)).bold()
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
                    Text("Folder\(folders.count>1 ? "s" : "")").font(.system(.largeTitle, design: .rounded)).bold()
                    Spacer()
                }.frame(minWidth: 0, maxWidth: .infinity)
                .contentShape(Rectangle())
            }.buttonStyle(ShrinkingButton())
        }.foregroundColor(Color("text"))
    }
}

/// SettingsView displays the settings menu
/// - Main Parent: DashboardHomePageView
struct SettingsView: View {
    /// Settings imports the UserSettings
    @EnvironmentObject var settings : UserSettings
    /// Fetches Receipt entities in CoreData sorting by the NSSortDescriptor.
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Receipt.date, ascending: false)],
        animation: .spring())
    /// Stores the fetched results as an array of Receipt objects.
    var receipts: FetchedResults<Receipt>
    
    var body: some View {
        ScrollView(showsIndicators: false){
            VStack (alignment: .leading){
                VStack{
                    Toggle("Dark Mode", isOn: $settings.darkMode)
                    .contentShape(Rectangle())
                    Divider()
                    
                    Toggle("Minimal Mode", isOn: $settings.minimal)
                    .contentShape(Rectangle())
                    Divider()
                    
                    Toggle("Contrast Mode", isOn: $settings.contrast)
                    .contentShape(Rectangle())
                    Divider()
                    
                    Picker("Background Color", selection: $settings.style) {
                        ForEach(0..<Color.getColors().count){ color in
                            Text("Style \(color+1)").tag(color)
                        }
                    }.pickerStyle(SegmentedPickerStyle())
                    Divider()
                }
                
                Button(action: {
                    Receipt.generateRandomReceipts()
                }){
                    Text("Generate Receipts")
                        .padding(.vertical, 10)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .background(Color("accent"))
                        .cornerRadius(10)
                }
                Divider()
                
                Button(action: {
                    Receipt.deleteAll(receipts: receipts)
                }){
                    Text("Delete All")
                        .padding(.vertical, 10)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .background(Color("accent"))
                        .cornerRadius(10)
                }
                Divider()
                
                Spacer()
            }.frame(minWidth: 0, maxWidth: .infinity).padding(5)
        }
    }
}

/// NotifcationsView  displays the notifications menu
/// - Main Parent: DashboardPanel
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
/// - Main Parent: DashboardPanel
struct ReceiptCollectionView: View {
    /// Fetches Receipt entities in CoreData sorting by the NSSortDescriptor.
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Receipt.date, ascending: false)], animation: .spring())
    /// Stores the fetched results as an array of Receipt objects.
    var receipts: FetchedResults<Receipt>
    /// DashPanelState maintains and updates the dashboards view state.
    @Binding var dashPanelState : DashPanelType
    /// String holding the users current search input
    @State var userSearch : String = ""
    /// Placeholder for a filtered search setting
    @State var warrenty = false
    /// Placeholder for a filtered search setting
    @State var favorites = false
    
    var body: some View {
        VStack {
            // title
            Text("Receipts")
                .font(.system(.largeTitle, design: .rounded)).bold()

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
        .foregroundColor(Color("text"))
    }
}

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
                            Text("Total")
                                .font(.system(.subheadline, design: .rounded))
                                .padding(.bottom, -5)
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
}

/// FolderCollectionView displays all the folders
/// - Main Parent: DashboardPanel
struct FolderCollectionView: View {
    /// Fetches Folder entities in CoreData sorting by the NSSortDescriptor.
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Folder.favorite, ascending: false),
                          NSSortDescriptor(keyPath: \Folder.receiptCount, ascending: false),
                          NSSortDescriptor(keyPath: \Folder.title, ascending: false)],
        animation: .spring())
    /// Stores the fetched results as an array of Folder objects.
    var folders: FetchedResults<Folder>
    /// Fetches Receipt entities in CoreData sorting by the NSSortDescriptor.
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Receipt.date, ascending: false)],
        animation: .spring())
    /// Stores the fetched results as an array of Receipt objects.
    var receipts: FetchedResults<Receipt>
    
    /// Placeholder for a filtered search setting
    @State var warrenty = false
    /// Placeholder for a filtered search setting
    @State var favorites = false
    /// If a folder is selected, this will be its title
    @State var currentFolder : String = ""
    /// String holding the users current search input
    @State var userSearch : String = ""
    /// DashPanelState maintains and updates the dashboards view state.
    @Binding var dashPanelState : DashPanelType
    /// Used for determining the LazyZStacks 2 column layout
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
                    }
                }
                Spacer()
                Text(viewingFolder()  ? "\(currentFolder)" : "All Folders")
                    .font(.system(.largeTitle, design: .rounded)).bold()
                Spacer()
                if viewingFolder() {
                    Button(action:{
                        withAnimation(.spring()){
                            getFolder().favorite.toggle()
                        }
                        Folder.save()
                    }){
                        if getFolder().favorite {
                            Image(systemName: "bookmark.fill")
                                .foregroundColor(Color(getFolder().color ?? "text"))
                        } else {
                            Image(systemName: "bookmark")
                                .foregroundColor(Color("text"))
                        }
                    }.padding(.leading, -10).font(.title)
                }
            }.padding(.horizontal)
            
            SearchBar(userSearch: $userSearch, warrenty: $warrenty, favorites: $favorites)
                .padding(.horizontal)
            
            ScrollView(showsIndicators: false) {
                if viewingFolder() && getFolder().receiptCount > 0 {
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
                            .foregroundColor(Color("white"))
                        
                    ).frame(height: UIScreen.screenHeight*0.1)
                    .padding(.vertical)
            }.buttonStyle(ShrinkingButton()).padding(.horizontal)
            Spacer()
        }.padding(.top).foregroundColor(Color("text"))
    }
    
    /// Gets the current folder based on the currentFolder string
    func getFolder() -> Folder {
        return Folder.getFolder(folderTitle: currentFolder)
    }
    
    /// Returns true if the current folder is not empty, false if the folder is empty
    func viewingFolder() -> Bool {
        return currentFolder.count > 0 ? true : false
    }
}

/// Folder view - Extremely basic folder
/// - Main Parent: FolderCollectionView
struct FolderView: View{
    /// An induvidual folder entity that the view will be based on
    @State var folder : Folder
    /// The current folder string from the parent FolderCollection, used to determine if this folder is in focus
    @Binding var currentFolder : String
    /// Whether the user has held down the folder (performed the delete action), and is pending delete
    @State var pendingDelete = false
    
    var body: some View {
        RoundedRectangle(cornerRadius: 18)
            .fill(Color("accent"))
            .overlay(
                VStack {
                    Image(systemName: folder.icon ?? "folder")
                        .font(.system(size: 50))
                    Text(folder.title ?? "Folder")
                        .font(.system(.title, design: .rounded))
                        .padding(.bottom, 10)
                    
                    //Spacer()
                    Text("\(folder.receiptCount)")
                        .font(.system(.largeTitle, design: .rounded)).bold()
                }.padding().padding(.top, 10)
                .foregroundColor(Color("text"))
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
            }).overlay(
                // the delete button
                VStack{
                    HStack{
                        Spacer()
                        if pendingDelete == true {
                            Circle().fill(Color.red)
                                .overlay(Image(systemName: "xmark").foregroundColor(Color("white")))
                                .frame(width: UIScreen.screenHeight*0.04,
                                       height: UIScreen.screenHeight*0.04)
                                .padding(8)
                                .onTapGesture{
                                    Folder.delete(folder: folder)
                                }
                        } else if folder.favorite {
                            Image(systemName: "bookmark.fill")
                                .font(.title)
                                .foregroundColor(Color(folder.color ?? "text"))
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

/// Background view is the background of the application
/// - Main Parent: ContentView
struct BackgroundView: View {
    /// AddPanelType maintains and updates the add panels view state.
    var addPanelState : AddPanelType
    /// DashPanelState maintains and updates the dashboards view state.
    var dashPanelState : DashPanelType
    /// Settings imports the UserSettings
    @EnvironmentObject var settings : UserSettings
    @State var colors = Color.getColors()
    
    var body: some View {
        ZStack {
            Color(settings.contrast ? "backgroundContrast" : "background").ignoresSafeArea(.all)
            if !settings.minimal {
                VStack {
                    Circle()
                        .fill(LinearGradient(gradient: Gradient(colors: [colors[settings.style].top1, colors[settings.style].top2]), startPoint: .top, endPoint: .bottom))
                        .scaleEffect(x: 1.5) // gives it that clean stretched out look
                        .padding(.top, -UIScreen.screenHeight * (dashPanelState == .homepage ? 0.5 : 0.38))
                        .animation(.spring())
                    Spacer()
                    Circle()
                        .fill(LinearGradient(gradient: Gradient(colors: [colors[settings.style].bottom1, colors[settings.style].bottom2]), startPoint: .top, endPoint: .bottom))
                        .scaleEffect(x: 1.5)
                        .padding(.bottom, -UIScreen.screenHeight * (addPanelState == .homepage ? 0.5 : 0.38))
                        .animation(.spring())
                }
            }
        }.animation(.easeInOut)
    }
}

/// Generic Search bar that returns the search term and filter booleans
struct SearchBar: View {
    /// String holding the users current search input
    @Binding var userSearch: String
    /// Toggles whether the filters drop down menu is showing
    @State var showingFilters : Bool = false
    /// Placeholder for a filtered search setting
    @Binding var warrenty : Bool
    /// Placeholder for a filtered search setting
    @Binding var favorites : Bool
    
    var body: some View {
        VStack {
            HStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color("accent"))
                    .frame(height: UIScreen.screenHeight*0.05).frame(minWidth: 0, maxWidth: .infinity)
                    .overlay(
                        HStack {
                            Image(systemName: "magnifyingglass")
                            CustomTextField(placeholder: Text("Search..."),text: $userSearch)
                                .ignoresSafeArea(.keyboard)
                            Spacer()
                            if userSearch.count > 0{
                                Button(action: {
                                    userSearch = ""
                                }){
                                    Image(systemName: "xmark")
                                }
                            }
                        }.foregroundColor(Color("text")).padding(.horizontal, 10)
                )
                Button(action:{
                    showingFilters = showingFilters ? false : true
                }){
                    Image(systemName: "slider.horizontal.3")
                        .font(.title)
                        .foregroundColor(Color("text"))
                }.buttonStyle(ShrinkingButton())
            }.padding(.bottom, 1)
            
            if showingFilters {
                VStack {
                    Group {
                        Toggle(" ", isOn: $warrenty)
                        //Toggle("Warrenty", isOn: $warrenty)  not working yet
                        //Toggle("Favorites", isOn: $favorites)
                    }.foregroundColor(.black).font(.system(.body, design: .rounded))
                }.padding(.horizontal, 5)
            }
        }
    }
}
