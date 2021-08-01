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

enum TabPage: Int {
    case home = 0
    case scan = 1
    case settings = 2
}

/// ContentView is the main content view that is called when starting the app.
struct ContentView: View {
    /// TODO: THIS TAB SELECTION ISNT WORKING
    @State var tabSelection: TabPage = .home
    @State var recognizedText: String = ""
    /// Settings imports the UserSettings
    @EnvironmentObject var settings: UserSettings
    
    var body: some View {
        TabView (selection: $tabSelection){
            HomeView()
                .tabItem { Label("Home", systemImage: "text.justify") }
                .tag(0)
            ScanView(recognizedText: $recognizedText, tabSelection: $tabSelection)
                .tabItem { Label("Scan", systemImage: "camera.viewfinder") }
                .tag(1)
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
                .tag(2)
        }
        .animation(.spring()).transition(.slide)
        .colorScheme(settings.darkMode ? .dark : .light)
    }
}



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
struct HomeView: View {
    /// AddPanelType maintains and updates the add panels view state.
    @State var addPanelState: AddPanelType = .homepage // need to make these global vars
    /// DashPanelState maintains and updates the dashboards view state.
    @State var dashPanelState: DashPanelType = .homepage
    /// Settings imports the UserSettings
    @EnvironmentObject var settings: UserSettings
    
    /// Fetches Receipt entities in CoreData sorting by the NSSortDescriptor.
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Receipt.date, ascending: false)], animation: .spring())
    /// Stores the fetched results as an array of Receipt objects.
    var receipts: FetchedResults<Receipt>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Folder.receiptCount, ascending: false),
                          NSSortDescriptor(keyPath: \Folder.title, ascending: true)],
        animation: .spring())
    /// Stores the fetched results as an array of Folder objects.
    var folders: FetchedResults<Folder>
    
    @State var userSearch: String = ""

    var body: some View {
        ZStack {
            BackgroundView()
            
            VStack {
                TitleText(title: "receipted")
                    .padding(.horizontal)
                
                // search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                    CustomTextField(placeholder: Text("Search"), text: $userSearch)
                    if userSearch != "" {
                        Button(action: {
                            userSearch = ""
                            UIApplication.shared.endEditing()
                        }){
                            Image(systemName: "xmark")
                                .font(.system(size: 19, weight: .bold, design: .rounded))
                                .foregroundColor(Color("text"))
                        }
                    }
                    Spacer()
                }.padding(.leading, 12)
                .frame(height: UIScreen.screenHeight*0.05)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color("accent"))
                ).padding(.horizontal)
                .ignoresSafeArea(.keyboard)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(folders) { folder in
                            Button(action: {
                            }){
                                TagView(folder: folder)
                            }.buttonStyle(ShrinkingButton())
                        }
                    }.padding(.horizontal)
                }
                
                // receipts
                ScrollView(showsIndicators: false) {
                    ForEach(receipts.filter({ userSearch.count > 0 ?
                                                $0.body!.localizedCaseInsensitiveContains(userSearch) ||
                                                $0.folder!.localizedCaseInsensitiveContains(userSearch)  ||
                                                $0.store!.localizedCaseInsensitiveContains(userSearch) :
                                                $0.body!.count > 0 })){ receipt in
                        ReceiptView(receipt: receipt).transition(.opacity)
                    }
                }
                .cornerRadius(15).padding(.horizontal)
                .toolbar {
                    
                    ToolbarItem(placement: .bottomBar) {
                        Image(systemName: "gearshape.fill")
                    }
                    ToolbarItem(placement: .bottomBar) {
                        Image(systemName: "house")
                    }
                    
                    ToolbarItem(placement: .bottomBar) {
                        Image(systemName: "plus")
                    }
                }.navigationBarTitle("Receipted.")
            }.navigationViewStyle(DoubleColumnNavigationViewStyle())
        }//.colorScheme(settings.darkMode ? .dark : .light)
    }
}

enum ScanSelection {
    case none
    case camera
    case gallery
}
/// ValidScanType holds the different cases for handling the input of a scan.
enum ValidScanType {
    case noScan /// no scan has been input.
    case validScan /// A valid scan has been input.
    case invalidScan /// An invalid scan has been input.
}

struct ScanView: View {
    @Binding var recognizedText: String
    @Binding var tabSelection: TabPage
    @State var scanSelection: ScanSelection = .none
    @State var validImage: ValidScanType = .noScan
    @State var validAlert: Bool = false
    let inSimulator: Bool = UIDevice.current.isSimulator
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            VStack{
                if scanSelection != .camera {
                    Spacer()
                    Button(action: {
                        scanSelection = scanSelection == .gallery ? .none : .gallery
                    }){
                        VStack {
                            Text("Add from Gallery")
                                .font(.system(.title, design: .rounded))
                            if scanSelection == .none {
                                Image(systemName: "photo.fill")
                                    .font(.system(.largeTitle, design: .rounded))
                                    .padding()
                            }
                        }
                    }.buttonStyle(ShrinkingButton())
                    
                    if scanSelection == .gallery {
                        ImagePicker(recognizedText: self.$recognizedText, validScan: $validImage)
                    }
                    Spacer()
                }
                Divider()
                if scanSelection != .gallery {
                    Spacer()
                    Button(action:{
                        scanSelection = scanSelection == .camera ? .none : .camera
                    }){
                        VStack {
                            Text("Add from Camera")
                                .font(.system(.title, design: .rounded))
                            if scanSelection == .none {
                                Image(systemName: "camera.fill")
                                    .font(.system(.largeTitle, design: .rounded))
                                    .padding()
                                    .transition(.opacity)
                            }
                        }
                    }.buttonStyle(ShrinkingButton())
                    
                    if scanSelection == .camera {
                        if !UIDevice.current.isSimulator {
                            ScanDocumentView(recognizedText: self.$recognizedText, validScan: $validImage)
                        } else {
                            Text("Not supported in the simulator!\n\nPlease use a physical device.")
                                .font(.system(.title, design: .rounded))
                                .padding()
                        }
                    }
                    Spacer()
                }
            }.animation(.spring())
        }.onChange(of: recognizedText, perform: { _ in
            validAlert = validImage == .invalidScan ? true : false
            if validImage == .validScan { // IMPROVE THIS! Go to a "is this correct?" screen
                Receipt.saveScan(recognizedText: recognizedText)
                tabSelection = .home // NOT UPDATING I DONT KNOW WHY
                scanSelection = .none
            }
        }).onChange(of: tabSelection, perform: { selectedTab in
            if selectedTab == .home {
                scanSelection = .none
            }
        }).alert(isPresented: $validAlert) {
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
struct SettingsView: View  {
    /// Fetches Receipt entities in CoreData sorting by the NSSortDescriptor.
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Receipt.date, ascending: false)], animation: .spring())
    /// Stores the fetched results as an array of Receipt objects.
    var receipts: FetchedResults<Receipt>
    /// Settings imports the UserSettings
    @EnvironmentObject var settings: UserSettings
   
    var body: some View {
        ZStack {
            BackgroundView()
            
            VStack {
                TitleText(title: "settings")
                
                ScrollView(showsIndicators: false){
                    VStack (alignment: .leading){
                        VStack{
                            Toggle("Dark Mode", isOn: $settings.darkMode)
                            .contentShape(Rectangle())
                            Divider()
                            
                            Picker("Background Color", selection: $settings.style) {
                                ForEach(0..<Color.colors.count){ color in
                                    Text("Style \(color+1)").tag(color)
                                }
                            }.pickerStyle(SegmentedPickerStyle())
                            Divider()
                        }.padding(.horizontal, 2)
                        
                        Button(action: {
                            Receipt.generateRandomReceipts()
                        }){
                            Text("Generate Receipts")
                                .padding(.vertical, 10)
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .background(Color("accent"))
                                .cornerRadius(10)
                        }.buttonStyle(ShrinkingButton())
                        Divider()
                        
                        Button(action: {
                            Receipt.deleteAll(receipts: receipts)
                        }){
                            Text("Delete All")
                                .padding(.vertical, 10)
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .background(Color("accent"))
                                .cornerRadius(10)
                        }.buttonStyle(ShrinkingButton())
                        Divider()
                        
                        Spacer()
                    }.frame(minWidth: 0, maxWidth: .infinity)
                }
            }.padding(.horizontal)
        }
    }
}


/*
// COMPANY TITLE ------------------
VStack {
    // DASHBOARD (UPPER) ------------------
    if addPanelState == .homepage {
        DashboardPanelParent(dashPanelState: $dashPanelState)
            .padding(.bottom, dashPanelState != .expanded ? 12 : 0)
            .transition(AnyTransition.opacity
                            .combined(with: .scale(scale: 0.75)))
            
    }
    
    // ADD RECEIPT (LOWER) ------------------
    if dashPanelState != .expanded {
        AddPanelParent(addPanelState: $addPanelState)
            .transition(AnyTransition.opacity.combined(with: .scale(scale: 0.75)))
            .animation(.spring())
        Spacer()
    }
}.ignoresSafeArea(.keyboard) // broken code, find fix
.padding(.horizontal, addPanelState == .homepage ? 15 : 0)
}
}*/


/// Background view is the background of the application
/// - Main Parent: ContentView
struct BackgroundView: View {
    /// Settings imports the UserSettings
    @EnvironmentObject var settings: UserSettings
    @State var colors = Color.colors
    
    var body: some View {
        ZStack {
            Color("background").ignoresSafeArea(.all)
            /*VStack {
                RoundedRectangle(cornerRadius: 25)
                    .fill(LinearGradient(gradient: Gradient(colors: [colors[settings.style].bottom1, colors[settings.style].bottom2]), startPoint: .leading, endPoint: .trailing))
                    .frame(height: UIScreen.screenHeight * 0.1)
                    .padding(.top, -75)
                Spacer()
            }*/
            
            /*
            VStack{
                Circle()
                    .fill(LinearGradient(gradient: Gradient(colors: [colors[settings.style].bottom1, colors[settings.style].bottom2]), startPoint: .leading, endPoint: .trailing))
                    .scaleEffect(x: 1.5) // gives it that clean stretched out look
                    .padding(.top, -UIScreen.screenHeight)
                    //.padding(.top, -UIScreen.screenHeight * (dashPanelState != .expanded ? 0.5 : 0.38))
                    .animation(.spring())
                Spacer()
            }.ignoresSafeArea()
            RoundedRectangle(cornerRadius: 25)
                .fill(Color("background"))*/
        }
    }
}

struct TitleText: View {
    let title: String
    var body: some View {
        HStack {
            Text("\(title.capitalized).")
                .font(.system(.largeTitle)).bold()
            Spacer()
        }.padding(.bottom, 1).padding(.top, 20)
    }
}
