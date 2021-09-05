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
/// is a View struct that is first called in the application. It is the highest parent of all other called structs. It holds a TabView that forms the basis of the apps UI.
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
        .accentColor(Color(settings.accentColor))
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
    ///``colors`` Imports an array of tuples containing various colors that are used to style the UI. This is based on the UserSettings 'style' setting, and is an @State to update the UI.
    @State var colors = Color.colors
    
    var shadowProperties = (opactiy: 0.08, radius: CGFloat(5))
   
    var body: some View {
        ZStack {
            BackgroundView()
            
            VStack {
                TitleText(buttonBool: $settings.devMode, title: "settings", icon: "hammer.fill")
                    .padding(.horizontal)
                
                ScrollView(showsIndicators: false){
                    VStack {
                        HStack {
                            //dark mode
                            Button(action: {
                                settings.darkMode.toggle()
                            }){
                                Color(settings.shadows ? "shadowObject" : "object")
                                    .cornerRadius(12)
                                    .overlay(
                                        VStack {
                                            Spacer()
                                            if settings.darkMode {
                                                Image(systemName: "moon.fill")
                                                    .font(.largeTitle)
                                                    .foregroundColor(Color(settings.accentColor))
                                                    .transition(AnyTransition.scale(scale: 0.25)
                                                                    .combined(with: .opacity))
                                            } else {
                                                Image(systemName: "sun.max.fill")
                                                    .font(.largeTitle)
                                                    .transition(AnyTransition.scale(scale: 0.25)
                                                                    .combined(with: .opacity))
                                            }
                                            Spacer()
                                            Text("\(settings.darkMode ? "DARK" : "LIGHT") MODE")
                                                .bold()
                                                .font(.system(.body, design: .rounded))
                                            Spacer()
                                        }.padding()
                                    ).dropShadow(isOn: settings.shadows,
                                                 opacity: settings.darkMode ? 0.45 : shadowProperties.opactiy,
                                                 radius: shadowProperties.radius)
                            }.buttonStyle(ShrinkingButton()).padding(.vertical).padding(.trailing, 5)
                            
                            // auto conf
                            Button(action: {
                                settings.shadows.toggle()
                            }){
                                Color(settings.shadows ? "shadowObject" : "object")
                                    .cornerRadius(12)
                                    .overlay(
                                        VStack {
                                            Spacer()
                                            if settings.shadows {
                                                Image(systemName: "smoke.fill")
                                                    .font(.largeTitle)
                                                    .foregroundColor(Color(settings.accentColor))
                                                    .transition(AnyTransition.opacity)
                                            } else {
                                                Image(systemName: "smoke")
                                                    .font(.largeTitle)
                                                    .transition(AnyTransition.opacity)
                                            }
                                            Spacer()
                                            Text("SHADOWS \(settings.shadows ? "ON" : "OFF")")
                                                .bold()
                                                .font(.system(.body, design: .rounded))
                                            Spacer()
                                        }.padding()
                                    ).dropShadow(isOn: settings.shadows,
                                                 opacity: settings.darkMode ? 0.45 : shadowProperties.opactiy,
                                                 radius: shadowProperties.radius)
                            }.buttonStyle(ShrinkingButton()).padding(.vertical).padding(.leading, 5)
                        }
                        
                        // scan selector
                        Color(settings.shadows ? "shadowObject" : "object")
                            .cornerRadius(12)
                            .overlay(
                                VStack {
                                    Spacer()
                                    HStack {
                                        Spacer()
                                        Button(action: {
                                            withAnimation(.easeInOut){
                                                settings.scanDefault = ScanDefault.camera.rawValue
                                            }
                                        }){
                                            Image(systemName: "camera")
                                                .font(.largeTitle)
                                                .foregroundColor(Color(ScanDefault.camera.rawValue == settings.scanDefault ? settings.accentColor : "accentAlt"))
                                                .scaleEffect(ScanDefault.camera.rawValue == settings.scanDefault ? 1.25 : 1)
                                                .transition(AnyTransition.scale(scale: 0.25)
                                                                .combined(with: .opacity))
                                                .padding()
                                        }.buttonStyle(ShrinkingButton())
                                        Spacer()
                                        Button(action: {
                                            withAnimation(.easeInOut){
                                                settings.scanDefault = ScanDefault.choose.rawValue
                                            }
                                        }){
                                            Image(systemName: "plus")
                                                .font(.largeTitle)
                                                .foregroundColor(Color(ScanDefault.choose.rawValue == settings.scanDefault ? settings.accentColor : "accentAlt"))
                                                .scaleEffect(ScanDefault.choose.rawValue == settings.scanDefault ? 1.25 : 1)
                                                .transition(AnyTransition.scale(scale: 0.25)
                                                                .combined(with: .opacity))
                                                .padding()
                                        }.buttonStyle(ShrinkingButton())
                                        Spacer()
                                        Button(action: {
                                            withAnimation(.easeInOut){
                                                settings.scanDefault = ScanDefault.gallery.rawValue
                                            }
                                        }){
                                            VStack {
                                                Image(systemName: "photo")
                                                    .font(.largeTitle)
                                                    .foregroundColor(Color(ScanDefault.gallery.rawValue == settings.scanDefault ? settings.accentColor : "accentAlt"))
                                                    .scaleEffect(ScanDefault.gallery.rawValue == settings.scanDefault ? 1.25 : 1)
                                                    .transition(AnyTransition.scale(scale: 0.25)
                                                                    .combined(with: .opacity))
                                                    .padding()
                                            }
                                        }.buttonStyle(ShrinkingButton())
                                        Spacer()
                                    }
                                    Text("SCAN SCREEN OPTION")
                                        .bold()
                                        .font(.system(.body, design: .rounded))
                                    Spacer()
                                }.padding()
                            ).padding(.bottom)
                            .dropShadow(isOn: settings.shadows,
                                         opacity: settings.darkMode ? 0.45 : shadowProperties.opactiy,
                                         radius: shadowProperties.radius)
                        
                        // color
                        Color(settings.shadows ? "shadowObject" : "object")
                            .cornerRadius(12)
                            .overlay(
                                VStack {
                                    Spacer()
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack {
                                            ForEach(0..<colors.count){ color in
                                                Button(action: {
                                                    settings.accentColor = colors[color]
                                                }){
                                                    VStack {
                                                        if color == 0 {
                                                            Circle()
                                                                .foregroundColor(Color.clear)
                                                                .overlay(Image(systemName: "circle.righthalf.fill")
                                                                            .font(.largeTitle).scaleEffect(1.1))
                                                                .frame(width: UIScreen.screenWidth*0.1, height: UIScreen.screenWidth*0.1)
                                                                .padding(.horizontal, 5)
                                                                .scaleEffect(settings.accentColor == colors[color] ? 1.25 : 1)
                                                                .animation(.spring())
                                                        } else {
                                                            Circle()
                                                                .foregroundColor(Color(colors[color]))
                                                                .frame(width: UIScreen.screenWidth*0.1, height: UIScreen.screenWidth*0.1)
                                                                .padding(.horizontal, 5)
                                                                .scaleEffect(settings.accentColor == colors[color] ? 1.25 : 1)
                                                                .animation(.spring())
                                                        }
                                                    }.overlay(Image(""))
                                                }.buttonStyle(ShrinkingButton())
                                            }
                                        }.frame(height: UIScreen.screenWidth*0.2)
                                        .padding(.horizontal)
                                    }
                                    Spacer()
                                    Text("ACCENT COLOR")
                                        .bold()
                                        .font(.system(.body, design: .rounded))
                                    Spacer()
                                }.padding(.vertical)
                            ).dropShadow(isOn: settings.shadows,
                                         opacity: settings.darkMode ? 0.45 : shadowProperties.opactiy,
                                         radius: shadowProperties.radius)
                            .padding(.bottom)
                    }.frame(height: UIScreen.screenHeight * 0.6).padding(.horizontal)
                    
                    if settings.devMode {
                        VStack(alignment: .leading) {
                            HStack {
                                Spacer()
                                Image(systemName: "aqi.medium")
                                Image(systemName: "hammer.fill")
                                //Image(systemName: "gyroscope")
                                Image(systemName: "cloud.moon.bolt")
                                Image(systemName: "lightbulb")
                                //Image(systemName: "move.3d")
                                //Image(systemName: "perspective")
                                Spacer()
                            }.padding()
                            Text("\(receipts.count) receipts.")
                                .font(.body)
                            HStack {
                                Button(action: {
                                    if isTesting(){
                                        Receipt.generateKnownReceipts()
                                    } else {
                                        Receipt.generateRandomReceipts()
                                    }
                                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                }){
                                    Color(settings.shadows ? "shadowObject" : "object")
                                        .cornerRadius(12)
                                        .overlay(
                                            VStack {
                                                Spacer()
                                                Image(systemName: "doc.badge.plus")
                                                    .font(.largeTitle)
                                                    .padding(2)
                                                Text("+10 RECEIPTS")
                                                    .bold()
                                                    .font(.system(.body, design: .rounded))
                                                Spacer()
                                            }.padding()
                                        ).dropShadow(isOn: settings.shadows,
                                                     opacity: settings.darkMode ? 0.45 : shadowProperties.opactiy,
                                                     radius: shadowProperties.radius)
                                }.buttonStyle(ShrinkingButton())
                                .padding(.trailing, 5)
                                
                                Button(action: {
                                    Receipt.deleteAll(receipts: receipts)
                                    Folder.deleteAll()
                                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                }){
                                    Color(settings.shadows ? "shadowObject" : "object")
                                        .cornerRadius(12)
                                        .overlay(
                                            VStack {
                                                Spacer()
                                                Image(systemName: "trash")
                                                    .font(.largeTitle)
                                                    .padding(2)
                                                Text("DELETE ALL")
                                                    .bold()
                                                    .font(.system(.body, design: .rounded))
                                                Spacer()
                                            }.padding()
                                        ).dropShadow(isOn: settings.shadows,
                                                     opacity: settings.darkMode ? 0.45 : shadowProperties.opactiy,
                                                     radius: shadowProperties.radius)
                                }.buttonStyle(ShrinkingButton())
                                .padding(.leading, 5)
                            }.frame(height: UIScreen.screenHeight * 0.15)
                        }.animation(.spring()).transition(AnyTransition.move(edge: .bottom))
                        .padding(.horizontal).padding(.bottom, 20)
                    }
                }
                
                /*ScrollView(showsIndicators: false){
                    VStack (alignment: .leading){
                        VStack {
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
                            Folder.deleteAll()
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
                }.accessibility(identifier: "ReceiptHomeView")*/
            }
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
    @Binding var buttonBool: Bool
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
                            .foregroundColor(Color(settings.accentColor))
                    }.padding(.bottom, 14)
                    .transition(AnyTransition.opacity.combined(with: .move(edge: .bottom)))
                })
            Button(action: {
                withAnimation(.spring()){
                    buttonBool.toggle()
                }
            }){
                Image(systemName: icon)
                    .font(.system(size: 19, weight: .bold, design: .rounded))
                    .foregroundColor(Color(settings.accentColor))
                    .padding(.horizontal)
                    .transition(AnyTransition.opacity.combined(with: .scale(scale: 0.9)))
            }.buttonStyle(ShrinkingButton())
        }
    }
}
