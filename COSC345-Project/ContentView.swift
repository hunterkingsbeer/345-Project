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

/// **TabPage** is an enum of type Int. It is used to control the ContentView's tabview's active page.
/// ## Parameters
///     case home: //When this is active it will change the TabView to index 0, resulting in HomeView being active.
///     case scan: //When this is active it will change the TabView to index 1, resulting in ScanView being active.
///     case home: //When this is active it will change the TabView to index 2, resulting in SettingsView being active.
///
enum TabPage: Int {
    case home = 0
    case scan = 1
    case settings = 2
}

class TabSelection: ObservableObject {
    @Published var page: TabPage
    @Published var selection: Int
    
    init(page: TabPage, selection: Int) {
        self.page = page
        self.selection = selection
    }
    
    func changeTab(tabPage: TabPage) {
        self.selection = tabPage.rawValue
    }
}

/// **ContentView** is a View struct that is first called in the application. It is the highest parent of all other called structs It holds a TabView that forms the basis of the apps UI.
///  The applications accent color and light/dark mode is controlled here as this is the highest parent, resulting in it affecting all child views.
///
/// - TabView contains
///     - HomeView: is the home screen of the app, displaying the receipts, folders, and search bar/title.
///     - ScanView: displays and provides the option of scanning receipts via gallery or camera.
///     - SettingsView: holds the controls for the various settings of the application.
/// - Parameters
///     - tabSelection: Controls the tabview's active tab to view. Uses a TabPage enum type, and is an @State to update the UI.
///     - settings: Imports the UserSettings environment object allowing unified usage and updating of the users settings across all classes.
///     - colors: Imports an array of tuples containing various colors that are used to style the UI. This is based on the UserSettings 'style' setting, and is an @State to update the UI.
///
struct ContentView: View {
    @State var tabSelection: TabPage = .home
    @State var selectedTab: Int = 0
    @EnvironmentObject var settings: UserSettings
    @State var colors = Color.colors
    var body: some View {
        TabView(selection: $selectedTab){
            HomeView(tabSelection: $tabSelection)
                .tabItem { Label("Home", systemImage: "magnifyingglass") }
                .tag(0)
            ScanView()
                .tabItem { Label("Scan", systemImage: "plus") }
                .tag(1)
            SettingsView()
                .tabItem { Label("Settings", systemImage: "hammer.fill").foregroundColor(Color("text")) }
                .tag(2)
        }
        .accentColor(colors[settings.style].text)
        .colorScheme(settings.darkMode ? .dark : .light)
        .onChange(of: tabSelection){ _ in
            selectedTab = tabSelection.rawValue
        }.onChange(of: selectedTab){ _ in
            tabSelection = TabPage(rawValue: selectedTab) ?? .home
        }
    }
}

/// **SettingsView** is a View struct that is called by ContentView. It imports the UserSettings and displays a range of toggles/buttons/pickers that alter the UserSettings upon user action.
///  The view is made up of a ZStack allowing the BackgroundView to be placed behind a VStack containing the title view (which says "Settings" with a hammer icon) and various settings to change.
/// - Parameters
///     - **FetchRequest**: Creates a FetchRequest for the 'Receipt' CoreData entities. Contains a NSSortDescriptor that sorts and orders the receipts as specified by Date.
///     - **receipts**: Takes and stores the requested Receipt entities in a FetchedResults variable of type Receipt. This variable is essentially an array of Receipt objects that the user has scanned.
///     - **settings**: Imports the UserSettings environment object allowing unified usage and updating of the users settings across all classes.
///
struct SettingsView: View  {
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Receipt.date, ascending: false)], animation: .spring())
    var receipts: FetchedResults<Receipt>
    @EnvironmentObject var settings: UserSettings
   
    var body: some View {
        ZStack {
            BackgroundView()
            
            VStack {
                TitleText(title: "settings", icon: "hammer.fill")
                
                ScrollView(showsIndicators: false){
                    VStack (alignment: .leading){
                        VStack{
                            Toggle("", isOn: $settings.darkMode)
                                .accessibility(identifier: "DarkModeToggle: \(settings.darkMode)")
                                .contentShape(Rectangle())
                                .overlay( // Testing taps text instead of toggle, text is put in usual toggle text field. Therefore overlay of text is required for testing.
                                    HStack{
                                        Text("Dark Mode")
                                        Spacer()
                                    }
                                ).onChange(of: settings.darkMode, perform: { _ in
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                })
                            Divider()
                            
                            Toggle("", isOn: $settings.thinFolders)
                                .contentShape(Rectangle())
                                .overlay(
                                    HStack {
                                        Text("Thin Folders")
                                        Spacer()
                                    }
                                ).onChange(of: settings.thinFolders, perform: { _ in
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                })
                            Divider()
                            
                            Toggle("", isOn: $settings.shadows)
                                .contentShape(Rectangle())
                                .overlay(
                                    HStack {
                                        Text("Shadows")
                                        Spacer()
                                    }
                                ).onChange(of: settings.shadows, perform: { _ in
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                })
                            Divider()
                            
                            Picker("Accent Color", selection: $settings.style) {
                                ForEach(0..<Color.colors.count){ color in
                                    Text("Style \(color+1)").tag(color)
                                }
                            }.pickerStyle(SegmentedPickerStyle())
                            .onChange(of: settings.style, perform: { _ in
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            })
                            Divider()
                            
                        }.padding(.horizontal, 2)
                        #if DEBUG
                            Button(action: {
                                Receipt.generateKnownReceipts()
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
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
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            }){
                                Text("Delete All")
                                    .padding(.vertical, 10)
                                    .frame(minWidth: 0, maxWidth: .infinity)
                                    .background(Color("accent"))
                                    .cornerRadius(10)
                            }.buttonStyle(ShrinkingButton())
                        #endif
                        Spacer()
                    }.frame(minWidth: 0, maxWidth: .infinity).animation(.spring())
                }.accessibility(identifier: "ReceiptHomeView")
            }.padding(.horizontal)
        }
    }
}

/// **BackgroundView** is a View struct that is called by HomeView, ScanView, and SettingsView. It holds the background that we see in all the tabs of the app. Usually this is placed in a ZStack behind the specific pages objects.
///  Consists of a Color with value "background", which automatically updates to be white when in light mode, and almost black in dark mode.
/// - Parameters
///     - **settings**: Imports the UserSettings environment object allowing unified usage and updating of the users settings across all classes.
///     - colors: Imports an array of tuples containing various colors that are used to style the UI. This is based on the UserSettings 'style' setting, and is an @State to update the UI.
///
struct BackgroundView: View {
    @EnvironmentObject var settings: UserSettings
    @State var colors = Color.colors
    
    var body: some View {
        Color("background").ignoresSafeArea(.all)
    }
}

/// **BackgroundView** is a View struct that is called by HomeView, ScanView, and SettingsView. It holds the background that we see in all the tabs of the app. Usually this is placed in a ZStack behind the specific pages objects.
///  Consists
/// - Parameters
///     - **settings**: Imports the UserSettings environment object allowing unified usage and updating of the users settings across all classes.
///     - **colors**: Imports an array of tuples containing various colors that are used to style the UI. This is based on the UserSettings 'style' setting, and is an @State to update the UI.
///
struct TitleText: View {
    @EnvironmentObject var settings: UserSettings
    @State var colors = Color.colors
    
    let title: String
    let icon: String
    var body: some View {
        
        HStack {
            HStack {
                Text("\(title.capitalized).")
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundColor(Color("text"))
                    .transition(AnyTransition.opacity.combined(with: .move(edge: .bottom)))
                    .padding(.bottom, 10).padding(.top, 21)
                Spacer()
            }.background(
                ZStack {
                    Rectangle()
                        .fill(Color.clear)
                        .scaleEffect(x: 1.5)
                        .animation(.easeOut(duration: 0.3))
                        .ignoresSafeArea(edges: .top)
                    VStack {
                        Spacer()
                        Rectangle()
                            .frame(height: 2)
                            .foregroundColor(Color("object"))
                    }.padding(.bottom, 14)
                    .transition(AnyTransition.opacity.combined(with: .move(edge: .bottom)))
                })
            Image(systemName: icon)
                .font(.system(size: 19, weight: .bold, design: .rounded))
                .foregroundColor(Color("text"))
                .padding(.horizontal)
                .transition(AnyTransition.opacity.combined(with: .scale(scale: 0.9)))
        }
    }
}
