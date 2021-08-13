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
                    .tabItem { Label("Home", systemImage: "magnifyingglass") }
                    .tag(0)
                ScanView()
                    .tabItem { Label("Scan", systemImage: "plus") }
                    .tag(1)
                SettingsView()
                    .tabItem { Label("Settings", systemImage: "hammer.fill").foregroundColor(Color("text")) }
                    .tag(2)
            }
            .accentColor(settings.minimal ? Color("text") : Color.colors[settings.style].text)
            .transition(.slide)
            .colorScheme(settings.darkMode ? .dark : .light)
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
                TitleText(title: "settings", icon: "hammer.fill")
                
                ScrollView(showsIndicators: false){
                    VStack (alignment: .leading){
                        VStack{
                            Toggle("", isOn: $settings.darkMode)
                                .accessibility(identifier: "DarkModeToggle")
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
                            
                            Toggle("", isOn: $settings.minimal)
                                .contentShape(Rectangle())
                                .overlay(
                                    HStack{
                                        Text("Minimal Color Mode")
                                        Spacer()
                                    }
                                ).onChange(of: settings.minimal, perform: { _ in
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
                            
                            if !settings.minimal {
                                Picker("Background Color", selection: $settings.style) {
                                    ForEach(0..<Color.colors.count){ color in
                                        Text("Style \(color+1)").tag(color)
                                    }
                                }.pickerStyle(SegmentedPickerStyle())
                                .onChange(of: settings.style, perform: { _ in
                                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                })
                                Divider()
                            }
                        }.padding(.horizontal, 2)
                        
                        Button(action: {
                            Receipt.generateRandomReceipts()
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
                if !settings.minimal && false {
                    RoundedRectangle(cornerRadius: 0)
                        .fill(LinearGradient(gradient: Gradient(colors: [colors[settings.style].leading, colors[settings.style].trailing]), startPoint: .topLeading, endPoint: .bottomTrailing))
                        //.fill(LinearGradient(gradient: Gradient(colors: [Color("green"), Color("grass")]), startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(height: UIScreen.screenHeight * 0.16)
                        //.accessibility(identifier: self.colors as! String?)
                    Spacer()
                }
            }.ignoresSafeArea()
        }
    }
}

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
                    .foregroundColor(Color(settings.minimal ? "background" : "text"))
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
                .foregroundColor(Color(settings.minimal ? "background" : "text"))
                .padding(.horizontal)
                .transition(AnyTransition.opacity.combined(with: .scale(scale: 0.9)))
        }
    }
}
