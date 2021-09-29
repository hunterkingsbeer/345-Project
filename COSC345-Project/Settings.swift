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
    let shadowProperties = (lightOpacity: 0.06, darkOpacity: 0.3, radius: CGFloat(5))
   
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
                                .frame(height: UIScreen.screenHeight * 0.2)
                            
                            // shadows
                            ShadowModeButton(shadowProperties: shadowProperties)
                                .frame(height: UIScreen.screenHeight * 0.2)
                        }
                        
                        // scan selector
                        ScanDefaultSelector(shadowProperties: shadowProperties)
                            .frame(height: UIScreen.screenHeight * 0.2)
                        
                        // passcode selector
                        PasscodeSelector(shadowProperties: shadowProperties)
                            .frame(height: UIScreen.screenHeight * 0.2)
                        
                        // color
                        AccentColorSelector(shadowProperties: shadowProperties)
                            .frame(height: UIScreen.screenHeight * 0.2)
                    }.padding(.horizontal).padding(.bottom)
                    
                    if settings.devMode {
                        DeveloperSettings(shadowProperties: shadowProperties)
                    }
                }.animation(.easeInOut)
            }
        }
    }
}

enum PassSuccess {
    case none
    case success
    case failure
}

struct PasscodeSelector: View {
    ///``settings``: Imports the UserSettings environment object allowing unified usage and updating of the users settings across all classes.
    @EnvironmentObject var settings: UserSettings
    let shadowProperties : (lightOpacity: Double, darkOpacity: Double, radius: CGFloat)
    @State var passState : PassEditingState = .none
    @State var passEditScreen = (editing: false, expectedCode: "0000")
    @State var passcodeSuccess = (success: false, code: "")
    
    var body: some View {
        Color(settings.shadows ? "shadowObject" : "object")
            .cornerRadius(12)
            .dropShadow(isOn: settings.shadows,
                         opacity: settings.darkMode ? shadowProperties.darkOpacity : shadowProperties.lightOpacity,
                         radius: shadowProperties.radius)
            .overlay(
                VStack {
                    HStack {
                        if settings.passcodeProtection { Spacer() }
                        
                        Button(action: {
                            if settings.passcodeProtection { // remove protection
                                passcodeSuccess.code = ""
                                passcodeSuccess.success = false
                                
                                passState = .removing
                                passEditScreen.expectedCode = settings.passcode
                                passEditScreen.editing = true
                            } else { // enable protection
                                passcodeSuccess.code = ""
                                passcodeSuccess.success = false
                                
                                passState = .creating
                                passEditScreen.expectedCode = passState.rawValue
                                passEditScreen.editing = true
                            }
                        }){
                            Image(systemName: settings.passcodeProtection ? "lock.fill" : "lock.slash")
                                .foregroundColor(Color(settings.passcodeProtection ? settings.accentColor : "text"))
                                .font(.system(size: 45))
                                .animation(.easeInOut)
                        }.buttonStyle(ShrinkingButton())
                        
                        if settings.passcodeProtection {
                            Spacer()
                            Button(action: { // update passcode
                                passcodeSuccess.code = ""
                                passcodeSuccess.success = false
                                
                                passState = .updating
                                passEditScreen.expectedCode = passState.rawValue
                                passEditScreen.editing = true
                            }){
                                Image(systemName: "lock.rotation")
                                    .font(.system(size: 45))
                                    .animation(.easeInOut)
                            }.buttonStyle(ShrinkingButton())
                            .transition(AnyTransition.offset(x: -35).combined(with: .opacity))
                            Spacer()
                        }
                    }.padding(.bottom).animation(.spring())
                    Text("PASSCODE \(settings.passcodeProtection ? "ENABLED" : "DISABLED") \(settings.devMode ? "[\(settings.passcode)]" : "")")
                        .bold()
                        .font(.system(.body, design: .rounded))
                }.padding()
            ).padding(.bottom)
            .onChange(of: passcodeSuccess.success){ _ in
                if passcodeSuccess.success {
                    if passState == .updating || passState == .creating { // new code
                        settings.passcodeProtection = true
                        settings.passcode = passcodeSuccess.code
                    } else if passState == .removing { // remove code
                        settings.passcodeProtection = false
                        settings.passcode = ""
                    }
                    passState = .none
                    passEditScreen.editing = false
                }
            }
            .fullScreenCover(isPresented: $passEditScreen.editing, content: {
                PasscodeEdit(result: $passcodeSuccess, expectedCode: passEditScreen.expectedCode)
                    .environmentObject(UserSettings())
                    .preferredColorScheme(settings.darkMode ? .dark : .light)
                    .onDisappear(perform: {
                        passState = .none
                    })
            })
    }
}

struct DarkModeButton: View {
    ///``settings``: Imports the UserSettings environment object allowing unified usage and updating of the users settings across all classes.
    @EnvironmentObject var settings: UserSettings
    ///``shadowProperties``: Used to uniformly control shadows applied to all the settings buttons/selectors.
    let shadowProperties : (lightOpacity: Double, darkOpacity: Double, radius: CGFloat)
    
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut){
                settings.darkMode.toggle()
            }
            hapticFeedback(type: .rigid)
        }){
            Color(settings.shadows ? "shadowObject" : "object")
                .cornerRadius(12)
                .dropShadow(isOn: settings.shadows,
                            opacity: settings.darkMode ? shadowProperties.darkOpacity : shadowProperties.lightOpacity,
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
    let shadowProperties : (lightOpacity: Double, darkOpacity: Double, radius: CGFloat)
    
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut){
                settings.shadows.toggle()
            }
            hapticFeedback(type: .rigid)
        }){
            Color(settings.shadows ? "shadowObject" : "object")
                .cornerRadius(12)
                .dropShadow(isOn: settings.shadows,
                             opacity: settings.darkMode ? shadowProperties.darkOpacity : shadowProperties.lightOpacity,
                             radius: shadowProperties.radius)
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
                )
        }.buttonStyle(ShrinkingButton()).padding(.vertical).padding(.leading, 5)
    }
}

struct ScanDefaultSelector: View {
    ///``settings``: Imports the UserSettings environment object allowing unified usage and updating of the users settings across all classes.
    @EnvironmentObject var settings: UserSettings
    ///``shadowProperties``: Used to uniformly control shadows applied to all the settings buttons/selectors.
    let shadowProperties : (lightOpacity: Double, darkOpacity: Double, radius: CGFloat)
    
    var body: some View {
        Color(settings.shadows ? "shadowObject" : "object")
            .cornerRadius(12)
            .dropShadow(isOn: settings.shadows,
                         opacity: settings.darkMode ? shadowProperties.darkOpacity : shadowProperties.lightOpacity,
                         radius: shadowProperties.radius)
            .overlay(
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        VStack {
                            Button(action: {
                                withAnimation(.easeInOut){
                                    settings.scanDefault = ScanDefault.camera.rawValue
                                }
                                hapticFeedback(type: .soft)
                            }){
                                Image(systemName: "camera")
                                    .font(.largeTitle)
                                    .foregroundColor(Color(ScanDefault.camera.rawValue == settings.scanDefault ? settings.accentColor : "accentAlt"))
                                    .scaleEffect(ScanDefault.camera.rawValue == settings.scanDefault ? 1.25 : 1)
                                    .transition(AnyTransition.scale(scale: 0.25)
                                                    .combined(with: .opacity))
                                    .padding()
                            }.buttonStyle(ShrinkingButton())
                        }
                        
                        Spacer()
                        VStack {
                            Button(action: {
                                withAnimation(.easeInOut){
                                    settings.scanDefault = ScanDefault.choose.rawValue
                                }
                                hapticFeedback(type: .soft)
                            }){
                                Image(systemName: "plus")
                                    .font(.largeTitle)
                                    .foregroundColor(Color(ScanDefault.choose.rawValue == settings.scanDefault ? settings.accentColor : "accentAlt"))
                                    .scaleEffect(ScanDefault.choose.rawValue == settings.scanDefault ? 1.25 : 1)
                                    .transition(AnyTransition.scale(scale: 0.25)
                                                    .combined(with: .opacity))
                                    .padding()
                            }.buttonStyle(ShrinkingButton())
                        }
                        
                        Spacer()
                        VStack {
                            Button(action: {
                                withAnimation(.easeInOut){
                                    settings.scanDefault = ScanDefault.gallery.rawValue
                                }
                                hapticFeedback(type: .soft)
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
                        }
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
    let shadowProperties : (lightOpacity: Double, darkOpacity: Double, radius: CGFloat)
    
    var body: some View {
        Color(settings.shadows ? "shadowObject" : "object")
            .cornerRadius(12)
            .dropShadow(isOn: settings.shadows,
                         opacity: settings.darkMode ? shadowProperties.darkOpacity : shadowProperties.lightOpacity,
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
                                    hapticFeedback(type: .soft)
                                }){
                                    VStack {
                                        if color == 0 {
                                            Image(systemName: "circle.righthalf.fill")
                                                        .font(.largeTitle).scaleEffect(1.1)
                                                .foregroundColor(Color("text"))
                                                .overlay(
                                                    VStack {
                                                        if settings.accentColor == colors[color]{
                                                            Image(systemName: "circle.fill")
                                                                .font(.system(size: 18, weight: .bold))
                                                                .foregroundColor(Color("object"))
                                                                .transition(AnyTransition.scale(scale: 0)/*.combined(with: .opacity)*/)
                                                        }
                                                    }
                                                )
                                                .padding(.horizontal, 5)
                                                .scaleEffect(settings.accentColor == colors[color] ? 1.25 : 1)
                                                .animation(.spring())
                                        } else {
                                            Circle()
                                                .foregroundColor(Color(colors[color]))
                                                .overlay(
                                                    VStack {
                                                        if settings.accentColor == colors[color]{
                                                            Image(systemName: "circle.fill")
                                                                .font(.system(size: 18, weight: .bold))
                                                                .foregroundColor(Color(settings.shadows ? "shadowObject" : "object"))
                                                                .transition(AnyTransition.scale(scale: 0.9).combined(with: .opacity))
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
                        .padding(.horizontal, 20)
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
    let shadowProperties : (lightOpacity: Double, darkOpacity: Double, radius: CGFloat)
    
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
                    hapticFeedback(type: .rigid)
                }){
                    Color(settings.shadows ? "shadowObject" : "object")
                        .cornerRadius(12)
                        .dropShadow(isOn: settings.shadows,
                                    opacity: settings.darkMode ? shadowProperties.darkOpacity : shadowProperties.lightOpacity,
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
                    hapticFeedback(type: .rigid)
                }){
                    Color(settings.shadows ? "shadowObject" : "object")
                        .cornerRadius(12)
                        .dropShadow(isOn: settings.shadows,
                                    opacity: settings.darkMode ? shadowProperties.darkOpacity : shadowProperties.lightOpacity,
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
