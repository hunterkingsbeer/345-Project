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
    @State var tabSelection: TabPage = .home
    /// Settings imports the UserSettings
    @EnvironmentObject var settings: UserSettings
    @State var colors = Color.colors
    
    var body: some View {
        ZStack {
            TabView (){
                HomeView()
                    .tabItem { Label("Home", systemImage: "text.justify") }
                    .tag(0)
                ScanView()
                    .tabItem { Label("Scan", systemImage: "camera.viewfinder") }
                    .tag(1)
                SettingsView()
                    .tabItem { Label("Settings", systemImage: "gearshape.fill").foregroundColor(Color("text")) }
                    .tag(2)
            }.accentColor(settings.minimal ? Color("text") : Color.colors[settings.style].text)
            .transition(.slide)
            .colorScheme(settings.darkMode ? .dark : .light)
            
        }
    }
}

/// ContentView is the main content view that is called when starting the app.
struct HomeView: View {
    /// Fetches Receipt entities in CoreData sorting by the NSSortDescriptor.
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Receipt.date, ascending: false)], animation: .spring())
    /// Stores the fetched results as an array of Receipt objects.
    var receipts: FetchedResults<Receipt>
    /// Fetches Folder entities in CoreData sorting by the NSSortDescriptor.
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Folder.receiptCount, ascending: false),
                          NSSortDescriptor(keyPath: \Folder.title, ascending: true)], animation: .spring())
    /// Stores the fetched results as an array of Folder objects.
    var folders: FetchedResults<Folder>
    
    /// Settings imports the UserSettings
    @EnvironmentObject var settings: UserSettings
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
                
                // FOLDERS
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(folders) { folder in
                            Button(action: {
                                // action for tapping the folder
                            }){
                                TagView(folder: folder)
                            }.buttonStyle(ShrinkingButton())
                        }
                    }.padding(.horizontal)
                }
                
                // RECEIPTS
                ScrollView(showsIndicators: false) {
                    ForEach(receipts.filter({ userSearch.count > 0 ?
                                                $0.body!.localizedCaseInsensitiveContains(userSearch) ||
                                                $0.folder!.localizedCaseInsensitiveContains(userSearch)  ||
                                                $0.store!.localizedCaseInsensitiveContains(userSearch) :
                                                $0.body!.count > 0 })){ receipt in
                        ReceiptView(receipt: receipt).transition(.opacity)
                    }.padding(.bottom)
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

// TODO: THE DOC SCANNER doesnt work. I think the recognizedcontent isnt wiping itself. Each receipt is re-added.
// TODO: image scanner needs to be updated to the doc scanner processes
struct ScanView: View {
    @EnvironmentObject var settings: UserSettings
    let inSimulator: Bool = UIDevice.current.isSimulator
    
    @State var scanSelection: ScanSelection = .none
    @State var isRecognizing: Bool = false
    @ObservedObject var recognizedContent = RecognizedContent()
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            VStack{
                TitleText(title: "scan")
                    .padding(.horizontal)
                Spacer()
                
                if !isRecognizing {
                    // default "gallery or camera" screen
                    if scanSelection == .none {
                        
                        Button(action: {
                            scanSelection = scanSelection == .gallery ? .none : .gallery
                        }){
                            VStack {
                                if scanSelection == .none {
                                    Image(systemName: "photo.fill")
                                        .font(.system(.largeTitle, design: .rounded))
                                        .padding()
                                    Text("Add from Gallery")
                                        .font(.system(.title, design: .rounded))
                                }
                            }.contentShape(Rectangle())
                        }.buttonStyle(ShrinkingButton())
                        
                        Spacer()
                        Divider()
                        Spacer()
                        
                        Button(action:{
                            scanSelection = scanSelection == .camera ? .none : .camera
                        }){
                            VStack {
                                if scanSelection == .none {
                                    Text("Add from Camera")
                                        .font(.system(.title, design: .rounded))
                                    Image(systemName: "camera.fill")
                                        .font(.system(.largeTitle, design: .rounded))
                                        .padding()
                                        .transition(.opacity)
                                }
                            }.contentShape(Rectangle())
                        }.buttonStyle(ShrinkingButton())
                        
                        Spacer()
                    }
                    
                    if scanSelection == .gallery { // scan via gallery
                        GalleryScannerView(scanSelection: $scanSelection,
                                           isRecognizing: $isRecognizing,
                                           recognizedContent: recognizedContent)
                        
                    } else if scanSelection == .camera { // scan via camera
                        DocumentScannerView(scanSelection: $scanSelection,
                                            isRecognizing: $isRecognizing,
                                            recognizedContent: recognizedContent)
                    }
                } else {
                    Text("Saving...")
                        .font(.system(.title, design: .rounded))
                    ProgressView()
                        .font(.largeTitle)
                        .progressViewStyle(CircularProgressViewStyle(tint: Color("text")))
                        .padding(.bottom, 20)
                    Spacer()
                }
            }.animation(.spring())
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
                            
                            Toggle("Minimal Color Mode", isOn: $settings.minimal)
                                .contentShape(Rectangle())
                            Divider()
                            
                            if !settings.minimal {
                                Picker("Background Color", selection: $settings.style) {
                                    ForEach(0..<Color.colors.count){ color in
                                        Text("Style \(color+1)").tag(color)
                                    }
                                }.pickerStyle(SegmentedPickerStyle())
                                Divider()
                            }
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
                        Spacer()
                    }.frame(minWidth: 0, maxWidth: .infinity).animation(.spring())
                }
            }.padding(.horizontal)
        }
    }
}

/// Background view is the background of the application
/// - Main Parent: ContentView
struct BackgroundView: View {
    /// Settings imports the UserSettings
    @EnvironmentObject var settings: UserSettings
    @State var colors = Color.colors
    
    var body: some View {
        ZStack {
            Color("background").ignoresSafeArea(.all)
            
            VStack{
                if !settings.minimal {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(LinearGradient(gradient: Gradient(colors: [colors[settings.style].leading, colors[settings.style].trailing]), startPoint: .leading, endPoint: .trailing))
                        //.fill(LinearGradient(gradient: Gradient(colors: [Color("green"), Color("grass")]), startPoint: .leading, endPoint: .trailing))
                        .frame(height: UIScreen.screenHeight * 0.14)
                    
                    Spacer()
                }
            }.ignoresSafeArea()
        }
    }
}

struct TitleText: View {
    @EnvironmentObject var settings: UserSettings
    
    let title: String
    var body: some View {
        HStack {
            Text("\(title.capitalized).")
                .font(.system(.largeTitle)).bold()
                .foregroundColor(Color(settings.style == 4 || settings.minimal ? "text" : "background"))
            Spacer()
        }.padding(.bottom, 10).padding(.top, 20)
    }
}
