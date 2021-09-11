//
//  Settings.swift
//  COSC345-Project
//
//  Created by Hunter Kingsbeer on 7/09/21.
//

import CoreData
import SwiftUI

/// ``SettingsView``
/// is a View struct that imports the UserSettings and displays a range of toggles/buttons/pickers that alter the UserSettings upon user action.
/// The view is made up of a ZStack allowing the BackgroundView to be placed behind a VStack containing the title view (which says "Settings" with a hammer icon) and various settings to change.
/// - Called by ContentView.
struct SettingsView: View  {
    ///``settings``: Imports the UserSettings environment object allowing unified usage and updating of the users settings across all classes.
    @EnvironmentObject var settings: UserSettings
    ///``shadowProperties``: Used to uniformly control shadows applied to all the settings buttons/selectors.
    let shadowProperties = (opactiy: 0.08, radius: CGFloat(4))
   
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
                            DarkModeButton(shadowProperties: shadowProperties)
                            
                            // shadows
                            ShadowModeButton(shadowProperties: shadowProperties)
                        }
                        
                        // scan selector
                        ScanDefaultSelector(shadowProperties: shadowProperties)
                        
                        // color
                        AccentColorSelector(shadowProperties: shadowProperties)
                    }.frame(height: UIScreen.screenHeight * 0.6).padding(.horizontal)
                    
                    if settings.devMode {
                        DeveloperSettings(shadowProperties: shadowProperties)
                    }
                }.animation(.easeInOut)
            }
        }
    }
}

struct DarkModeButton: View {
    ///``settings``: Imports the UserSettings environment object allowing unified usage and updating of the users settings across all classes.
    @EnvironmentObject var settings: UserSettings
    ///``shadowProperties``: Used to uniformly control shadows applied to all the settings buttons/selectors.
    let shadowProperties : (opactiy: Double, radius: CGFloat)
    
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut){
                settings.darkMode.toggle()
            }
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }){
            Color(settings.shadows ? "shadowObject" : "object")
                .cornerRadius(12)
                .dropShadow(isOn: settings.shadows,
                             opacity: settings.darkMode ? 0.45 : shadowProperties.opactiy,
                             radius: shadowProperties.radius)
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
                )
        }.buttonStyle(ShrinkingButton()).padding(.vertical).padding(.trailing, 5)
    }
}

struct ShadowModeButton: View {
    ///``settings``: Imports the UserSettings environment object allowing unified usage and updating of the users settings across all classes.
    @EnvironmentObject var settings: UserSettings
    ///``shadowProperties``: Used to uniformly control shadows applied to all the settings buttons/selectors.
    let shadowProperties : (opactiy: Double, radius: CGFloat)
    
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut){
                settings.shadows.toggle()
            }
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
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
}

struct ScanDefaultSelector: View {
    ///``settings``: Imports the UserSettings environment object allowing unified usage and updating of the users settings across all classes.
    @EnvironmentObject var settings: UserSettings
    ///``shadowProperties``: Used to uniformly control shadows applied to all the settings buttons/selectors.
    let shadowProperties : (opactiy: Double, radius: CGFloat)
    
    var body: some View {
        Color(settings.shadows ? "shadowObject" : "object")
            .cornerRadius(12)
            .dropShadow(isOn: settings.shadows,
                         opacity: settings.darkMode ? 0.45 : shadowProperties.opactiy,
                         radius: shadowProperties.radius)
            .overlay(
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            withAnimation(.easeInOut){
                                settings.scanDefault = ScanDefault.camera.rawValue
                            }
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
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
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
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
    }
}

struct AccentColorSelector: View {
    ///``colors`` Imports an array of tuples containing various colors that are used to style the UI. This is based on the UserSettings 'style' setting, and is an @State to update the UI.
    @State var colors = Color.colors
    ///``settings``: Imports the UserSettings environment object allowing unified usage and updating of the users settings across all classes.
    @EnvironmentObject var settings: UserSettings
    ///``shadowProperties``: Used to uniformly control shadows applied to all the settings buttons/selectors.
    let shadowProperties : (opactiy: Double, radius: CGFloat)
    
    var body: some View {
        Color(settings.shadows ? "shadowObject" : "object")
            .cornerRadius(12)
            .dropShadow(isOn: settings.shadows,
                         opacity: settings.darkMode ? 0.45 : shadowProperties.opactiy,
                         radius: shadowProperties.radius)
            .overlay(
                VStack {
                    Spacer()
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(0..<colors.count){ color in
                                Button(action: {
                                    withAnimation(.easeInOut){
                                        settings.accentColor = colors[color]
                                    }
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
                                                .overlay(
                                                    VStack{
                                                        if settings.accentColor == colors[color]{
                                                            Image(systemName: "checkmark")
                                                                .font(.system(size: 12, weight: .bold))
                                                                .foregroundColor(Color("background"))
                                                                .transition(AnyTransition.scale(scale: 0.75).combined(with: .opacity))
                                                        }
                                                    }
                                                ).frame(width: UIScreen.screenWidth*0.1, height: UIScreen.screenWidth*0.1)
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
            ).padding(.bottom)
    }
}

struct DeveloperSettings: View {
    ///``FetchRequest``: Creates a FetchRequest for the 'Receipt' CoreData entities. Contains a NSSortDescriptor that sorts and orders the receipts as specified by Date.
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Receipt.date, ascending: false)], animation: .spring())
    ///``receipts``: Takes and stores the requested Receipt entities in a FetchedResults variable of type Receipt. This variable is essentially an array of Receipt objects that the user has scanned.
    var receipts: FetchedResults<Receipt>
    ///``settings``: Imports the UserSettings environment object allowing unified usage and updating of the users settings across all classes.
    @EnvironmentObject var settings: UserSettings
    ///``shadowProperties``: Used to uniformly control shadows applied to all the settings buttons/selectors.
    let shadowProperties : (opactiy: Double, radius: CGFloat)
    
    var body: some View {
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
                        .dropShadow(isOn: settings.shadows,
                                     opacity: settings.darkMode ? 0.45 : shadowProperties.opactiy,
                                     radius: shadowProperties.radius)
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
                        )
                }.buttonStyle(ShrinkingButton())
                .padding(.trailing, 5)
                
                Button(action: {
                    Receipt.deleteAll(receipts: receipts)
                    Folder.deleteAll()
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }){
                    Color(settings.shadows ? "shadowObject" : "object")
                        .cornerRadius(12)
                        .dropShadow(isOn: settings.shadows,
                                     opacity: settings.darkMode ? 0.45 : shadowProperties.opactiy,
                                     radius: shadowProperties.radius)
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
                        )
                }.buttonStyle(ShrinkingButton())
                .padding(.leading, 5)
            }.frame(height: UIScreen.screenHeight * 0.15)
        }.animation(.spring()).transition(AnyTransition.move(edge: .bottom))
        .padding(.horizontal).padding(.bottom, 20)
    }
}
