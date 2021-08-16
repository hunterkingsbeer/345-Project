//
//  ContentView.swift
//  COSC345-Project
//
//  Created by Hunter Kingsbeer on 7/05/21.
//

import SwiftUI
import CoreData


/// ``ContentView_Previews``
/// is a PreviewProvider that allows the application to be previewed in the Xcode canvas.
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(UserSettings())
            .environmentObject(TabSelection())
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

/// ``ContentView``
/// is a View struct that is first called in the application. It is the highest parent of all other called structs It holds a TabView that forms the basis of the apps UI.
/// The applications accent color and light/dark mode is controlled here as this is the highest parent, resulting in it affecting all child views.
/// - Parameters
///     - EnvironmentObjects for TabSelection and UserSettings are required on parent class.
/// - TabView contains
///     - HomeView: is the home screen of the app, displaying the receipts, folders, and search bar/title.
///     - ScanView: displays and provides the option of scanning receipts via gallery or camera.
///     - SettingsView: holds the controls for the various settings of the application.
struct ContentView: View {
    ///``selectedTab`` Controls the TabView's active tab it is viewing. Imports the TabSelection EnvironmentObject, allowing for application wide changing of the selected tab.
    @EnvironmentObject var selectedTab: TabSelection
    ///``settings`` Alters the view based on the user's settings. Imports the UserSettings EnvironmentObject allowing unified usage and updating of the users settings across all classes.
    @EnvironmentObject var settings: UserSettings
    ///``colors`` Imports an array of tuples containing various colors that are used to style the UI. This is based on the UserSettings 'style' setting, and is an @State to update the UI.
    @State var colors = Color.colors
    var body: some View {
        TabView(selection: $selectedTab.selection){
            HomeView()
                .tabItem { Label("Home", systemImage: "magnifyingglass") }
                .tag(0)
            ScanView()
                .tabItem { Label("Scan", systemImage: "plus") }
                .tag(1)
            SettingsView()
                .tabItem { Label("Settings", systemImage: "hammer.fill").foregroundColor(Color("text")) }
                .tag(2)
        }
        .accentColor(colors[settings.style].leading)
        .colorScheme(settings.darkMode ? .dark : .light)
    }
}

/// ``SettingsView``
/// is a View struct that imports the UserSettings and displays a range of toggles/buttons/pickers that alter the UserSettings upon user action.
/// The view is made up of a ZStack allowing the BackgroundView to be placed behind a VStack containing the title view (which says "Settings" with a hammer icon) and various settings to change.
/// - Called by ContentView.
struct SettingsView: View  {
    ///``FetchRequest``: Creates a FetchRequest for the 'Receipt' CoreData entities. Contains a NSSortDescriptor that sorts and orders the receipts as specified by Date.
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Receipt.date, ascending: false)], animation: .spring())
    ///``receipts``: Takes and stores the requested Receipt entities in a FetchedResults variable of type Receipt. This variable is essentially an array of Receipt objects that the user has scanned.
    var receipts: FetchedResults<Receipt>
    ///``settings``: Imports the UserSettings environment object allowing unified usage and updating of the users settings across all classes.
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
                        
                        Button(action: {
                            if isTesting(){
                                Receipt.generateKnownReceipts()
                            } else {
                                Receipt.generateRandomReceipts()
                            }
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
                        
                        Spacer()
                    }.frame(minWidth: 0, maxWidth: .infinity).animation(.spring())
                }.accessibility(identifier: "ReceiptHomeView")
            }.padding(.horizontal)
        }
    }
}

/// ``BackgroundView``
/// is a View struct that holds the background that we see in all the tabs of the app. Usually this is placed in a ZStack behind the specific pages objects.
/// Consists of a Color with value "background", which automatically updates to be white when in light mode, and almost black in dark mode.
/// - Called by HomeView, ScanView, and SettingsView.
struct BackgroundView: View {
    /// ``settings``: Imports the UserSettings environment object allowing unified usage and updating of the users settings across all classes.
    @EnvironmentObject var settings: UserSettings
    /// ``colors``: Imports an array of tuples containing various colors that are used to style the UI. This is based on the UserSettings 'style' setting, and is an @State to update the UI.
    @State var colors = Color.colors
    
    var body: some View {
        Color("background").ignoresSafeArea(.all)
    }
}

/// ``TitleText``
/// is a View struct that displays the pages respective title text along with the icon. These are specified in the title and icon parameters.
/// - Called by HomeView, ScanView, and SettingsView.
/// - Parameters
///     - ``title``: String
///     - ``icon``: String
struct TitleText: View {
    /// ``settings`` Imports the UserSettings environment object allowing unified usage and updating of the users settings across all classes.
    @EnvironmentObject var settings: UserSettings
    /// ``colors`` Imports an array of tuples containing various colors that are used to style the UI. This is based on the UserSettings 'style' setting, and is an @State to update the UI.
    @State var colors = Color.colors
    /// ``title`` is a String that is used to set the titles text.
    let title: String
    ///``icon`` is a String that is used to set the titles icon.
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
