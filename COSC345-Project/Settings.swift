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
   
    var body: some View {
        ZStack {
            BackgroundView()
            
            VStack {
                TitleText(title: "settings", icon: "hammer.fill")
                    .padding(.horizontal)
                
                ScrollView(showsIndicators: false){
                    VStack {
                        Group {
                            //dark mode
                            DarkModeButton()
                                
                            // passcode selector
                            PasscodeSelector()
                            
                            // color selector
                            AccentColorSelector()
                            
                            // scan selector
                            ScanDefaultSelector()

                        }.frame(height: UIScreen.screenHeight * 0.2)
                    }.padding(.horizontal).padding(.bottom)
                }.animation(.easeInOut)
            }
        }
    }
}

/// ``PasscodeSelector``
/// is a View struct that allows a user to manage their passcodes. This includes the option to enable, disable, and update passcodes.
/// - Called by SettingsView.
struct PasscodeSelector: View {
    ///``settings``: Imports the UserSettings environment object allowing unified usage and updating of the users settings across all classes.
    @EnvironmentObject var settings: UserSettings
    
    ///``passState``: is used to control the passcode editing state (cereating, updating, removing)
    @State var passState : PassEditingState = .none
    
    ///``passEditScreen``: is used to control the fullscreen passcodeEdit view. Editing managed the fullscreen presentation, and expected code controls the edit type to be passed through (cereating, updating, removing)
    @State var passEditScreen = (editing: false, expectedCode: "0000")
    
    ///``passcodeSuccess``: is used to hold the result of a passcode edit result.
    @State var passcodeSuccess = (success: false, code: "")
    
    var body: some View {
        
        Blur(effect: UIBlurEffect(style: .systemThinMaterial))
            .opacity(0.9)
            .cornerRadius(12)
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
                            ZStack {
                                if settings.passcodeProtection {
                                    Image(systemName: "shield.fill")
                                        .foregroundColor(Color(settings.accentColor == "UIContrast" ? "accentAlt" : settings.accentColor))
                                        .font(.system(size: 55))
                                }
                                Image(systemName: settings.passcodeProtection ? "lock.fill" : "shield.slash.fill")
                                    .foregroundColor(Color(settings.passcodeProtection ? "text" : "accentAlt"))
                                    .font(.system(size: settings.passcodeProtection ? 30 : 45))
                                .animation(.easeInOut)
                            }
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
                    Text("PASSCODE \(settings.passcodeProtection ? "ENABLED" : "DISABLED")")
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
                PasscodeEdit(result: $passcodeSuccess, editType: passEditScreen.expectedCode)
                    .environmentObject(UserSettings())
                    .preferredColorScheme(settings.darkMode ? .dark : .light)
                    .onDisappear(perform: {
                        passState = .none
                    })
            })
    }
}

/// ``DarkModeButton``
/// is a View struct that updates the UI color scheme. Either dark or light.
/// - Called by SettingsView.
struct DarkModeButton: View {
    ///``settings``: Imports the UserSettings environment object allowing unified usage and updating of the users settings across all classes.
    @EnvironmentObject var settings: UserSettings
    
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut){
                settings.darkMode.toggle()
            }
            hapticFeedback(type: .rigid)
        }){
            Blur(effect: UIBlurEffect(style: .systemThinMaterial))
                .opacity(0.9)
                .cornerRadius(12)
                .overlay(
                    VStack {
                        Spacer()
                        if settings.darkMode {
                            Image(systemName: "moon.fill")
                                .font(.largeTitle)
                                .foregroundColor(Color(settings.accentColor))
                                .transition(AnyTransition.scale(scale: 0.5).combined(with: .opacity))
                        } else {
                            Image(systemName: "sun.max.fill")
                                .font(.largeTitle)
                                .transition(AnyTransition.scale(scale: 0.5).combined(with: .opacity))
                                
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

/// ``ScanDefaultSelector``
/// is a View struct that controls the default scanner option. This is either the camera, gallery or the option of both.
/// - Called by SettingsView.
struct ScanDefaultSelector: View {
    ///``settings``: Imports the UserSettings environment object allowing unified usage and updating of the users settings across all classes.
    @EnvironmentObject var settings: UserSettings
    
    var body: some View {
        Blur(effect: UIBlurEffect(style: .systemThinMaterial))
            .opacity(0.9)
            .cornerRadius(12)
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
                                hapticFeedback(type: .rigid)
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
                                hapticFeedback(type: .rigid)
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
                                hapticFeedback(type: .rigid)
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
                    Text("DEFAULT SCANNER: \(settings.scanDefault == ScanDefault.camera.rawValue ? "CAMERA" : settings.scanDefault == ScanDefault.gallery.rawValue ? "GALLERY" : "EITHER")")
                        .bold()
                        .font(.system(.body, design: .rounded))
                    Spacer()
                }.padding()
            ).padding(.bottom)
    }
}

/// ``AccentColorSelector``
/// is a View struct that controls the accent color of the app. This is takes the UI colors and presents them for selection.
/// - Called by SettingsView.
struct AccentColorSelector: View {
    ///``colors`` Imports an array of tuples containing various colors that are used to style the UI. This is based on the UserSettings 'style' setting, and is an @State to update the UI.
    @State var colors = Color.colors
    ///``settings``: Imports the UserSettings environment object allowing unified usage and updating of the users settings across all classes.
    @EnvironmentObject var settings: UserSettings
    
    var body: some View {
        Blur(effect: UIBlurEffect(style: .systemThinMaterial))
            .opacity(0.9)
            .cornerRadius(12)
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
                                                                .foregroundColor(Color("accent"))
                                                                .transition(AnyTransition.scale(scale: 0.25).combined(with: .opacity))
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
                                                                .foregroundColor(Color("accent"))
                                                                .transition(AnyTransition.scale(scale: 0.25).combined(with: .opacity))
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
