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
                            Toggle("", isOn: $settings.darkMode)
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
                if !settings.minimal {
                    RoundedRectangle(cornerRadius: 0)
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
