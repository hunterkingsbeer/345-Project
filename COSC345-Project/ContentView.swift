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
    /// Displays the
    case expanded
    /// Displays the settings view
    case settings
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
                    // DASHBOARD (UPPER) ------------------
                    if addPanelState == .homepage {
                        DashboardPanelParent(size: UIScreen.screenHeight * 0.7, dashPanelState: $dashPanelState)
                            .padding(.bottom, dashPanelState != .expanded ? 12 : 0)
                            .transition(AnyTransition.opacity
                                            .combined(with: .scale(scale: 0.75)))
                            .animation(.spring())
                    }
                    
                    // ADD RECEIPT (LOWER) ------------------
                    if dashPanelState != .expanded {
                        AddPanel(addPanelState: $addPanelState)
                            .transition(AnyTransition.opacity.combined(with: .scale(scale: 0.75)))
                            .animation(.spring())
                        Spacer()
                    }
                }.ignoresSafeArea(.keyboard)
                .padding(.horizontal, addPanelState == .homepage ? 15 : 0)
            }.navigationBarTitle("").navigationBarHidden(true)
            .colorScheme(settings.darkMode ? .dark : .light)
        }
    }
}

/// DashboardPanelParent handles the view states for the dashboard panel
/// - Main Parent: ContentView
struct DashboardPanelParent: View{
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
                    if dashPanelState != .settings {
                        DashboardHomepage(dashPanelState: $dashPanelState)
                            .transition(AnyTransition.move(edge: .leading).combined(with: .opacity))
                            .animation(.spring())
                    } else if dashPanelState == .settings {
                        SettingsView()
                            .transition(AnyTransition.move(edge: .trailing).combined(with: .opacity))
                            .animation(.spring())
                    }
                }
            ).frame(height: dashPanelState != .expanded ? size : UIScreen.screenHeight*0.84)
            .animation(.easeInOut)
    }
}

/// DashboardHomepage holds the homepage view for the app. Displaying receipts, tags and search.
/// - Main Parent: ContentView
struct DashboardHomepage: View {
    /// Fetches Receipt entities in CoreData sorting by the NSSortDescriptor.
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Receipt.date, ascending: false)], animation: .spring())
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
    /// String holding the users current search input
    @State var userSearch : String = ""
    /// Placeholder for a filtered search setting
    @State var warrenty = false
    /// Placeholder for a filtered search setting
    @State var favorites = false
    
    var body: some View {
        VStack {
            TitleBar(dashPanelState: $dashPanelState).padding()
            
            // search bar
            SearchBar(userSearch: $userSearch, warrenty: $warrenty, favorites: $favorites).padding(.horizontal)
            // category and tags bar
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(folders) { folder in
                        Button(action:{
                            let title = folder.title
                            userSearch = title == userSearch ? "" : title ?? ""
                        }){
                            TagView(folder: folder)
                        }.buttonStyle(PlainButtonStyle())
                    }
                }.padding(.horizontal)
            }//.cornerRadius(15)
            
            // receipts including search results
            ScrollView(showsIndicators: false) {
                ForEach(receipts.filter({ userSearch.count > 0 ? $0.body!.localizedCaseInsensitiveContains(userSearch) ||  $0.folder!.localizedCaseInsensitiveContains(userSearch)  || $0.store!.localizedCaseInsensitiveContains(userSearch) : $0.body!.count > 0 })){ receipt in
                    ReceiptView(receipt: receipt).transition(.opacity)
                }
            }.cornerRadius(18)
            .padding(.horizontal)
            Spacer()
        }.padding(.bottom, 10)
        .onChange(of: userSearch, perform: { search in
            withAnimation(.spring()){
                dashPanelState = search != "" ? .expanded : .homepage
            }
        })
    }
}

struct TitleBar: View {
    @Binding var dashPanelState: DashPanelType
    
    var body: some View {
        HStack {
            let onSettings = dashPanelState == .settings
            if onSettings {
                Spacer()
            }
            
            Button(action: {
                withAnimation(.spring()){
                    dashPanelState = dashPanelState == .settings ? .homepage : .settings
                }
            }){
                Image(systemName: "gearshape.fill")
                    .font(.title).foregroundColor(Color("text"))
                    .scaleEffect(onSettings ? 1.3 : 1)
                    .animation(.spring())
            }
            
            Spacer()
            if !onSettings {
                HStack {
                    Spacer()
                    Text("Receipted.")
                        .foregroundColor(Color("text"))
                        .font(.system(.title, design: .rounded)).bold()
                    Spacer()
                    Image(systemName: "gearshape.fill")
                        .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/).foregroundColor(.clear)
                }.transition(AnyTransition.move(edge: .trailing).combined(with: .opacity))
                .animation(.spring())
            }
        }
    }
}

struct TagView: View {
    let folder : Folder
    var body: some View {
        RoundedRectangle(cornerRadius: 15)
            .fill(Color(folder.color ?? "accent"))
            .overlay(
                HStack {
                    Image(systemName: folder.icon ?? "folder")
                    Text("\(folder.receiptCount) \(folder.title ?? " Default")")
                    Spacer()
                }.font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(Color("background"))
                .padding(.horizontal, 10)
            )
            .frame(minWidth: UIScreen.screenWidth * 0.4)
            .frame(height: UIScreen.screenHeight*0.05)
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
                
                Divider()
                    .foregroundColor(Color("text"))
                    .padding(.vertical, 25)
                
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
                if !UIDevice.current.isSimulator {
                    ScanDocumentView(recognizedText: self.$recognizedText,
                                     validScan: $validScan)
                    .cornerRadius(18)
                    .animation(.spring())
                } else {
                    Text("Camera not supported in the simulator!")
                    Spacer()
                }
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
                }.buttonStyle(PlainButtonStyle())
                Divider()
                
                Button(action: {
                    Receipt.deleteAll(receipts: receipts)
                }){
                    Text("Delete All")
                        .padding(.vertical, 10)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .background(Color("accent"))
                        .cornerRadius(10)
                }.buttonStyle(PlainButtonStyle())
                Divider()
                
                Spacer()
            }.frame(minWidth: 0, maxWidth: .infinity).padding(5)
        }
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
                        .padding(.top, -UIScreen.screenHeight * 0.55)
                        //.padding(.top, -UIScreen.screenHeight * (dashPanelState != .expanded ? 0.5 : 0.38))
                        .animation(.spring())
                    Spacer()
                    Circle()
                        .fill(LinearGradient(gradient: Gradient(colors: [colors[settings.style].bottom1, colors[settings.style].bottom2]), startPoint: .top, endPoint: .bottom))
                        .scaleEffect(x: 1.5)
                        .padding(.bottom, -UIScreen.screenHeight * (addPanelState == .homepage ? 0.6 : 0.38))
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
