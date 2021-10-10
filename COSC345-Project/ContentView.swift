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
    ///``locked`` locks the screen if the user has passcode protection enabled
    @State var locked = false
    
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
        }//.onAppear(perform: { locked = settings.passcodeProtection }) // passcode protection if settings enabled
        .fullScreenCover(isPresented: $locked, content: {
            PasscodeScreen(locked: $locked)
                .environmentObject(UserSettings())
                .preferredColorScheme(settings.darkMode ? .dark : .light) // weirdly needs this
        })
        .accentColor(Color(settings.accentColor))
        .preferredColorScheme(settings.darkMode ? .dark : .light)
    }
}

/// ``BackgroundView``
/// is a View struct that holds the background that we see in all the tabs of the app. Usually this is placed in a ZStack behind the specific pages objects.
/// Consists of a Color with value "background", which automatically updates to be white when in light mode, and almost black in dark mode.
/// - Called by HomeView, ScanView, and SettingsView.
struct BackgroundView: View {
    var body: some View {
        Color("background")
            .ignoresSafeArea(.all)
            .animation(.easeInOut)
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
                    .padding(.bottom, 10).padding(.top, 20)
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
                            .opacity(settings.accentColor == "UIContrast" ? 0.08 : 0.6)
                    }.padding(.bottom, 14)
                    .transition(AnyTransition.opacity.combined(with: .move(edge: .bottom)))
                })
            Spacer()
            Button(action: {
                withAnimation(.spring()){
                    buttonBool.toggle()
                }
            }){
                Image(systemName: icon)
                    .font(.system(size: 19, weight: .bold, design: .rounded))
                    .foregroundColor(Color(settings.accentColor))
                    .padding(.horizontal)
            }.buttonStyle(ShrinkingButton())
            .frame(width: UIScreen.screenWidth * 0.16)
        }
    }
}
