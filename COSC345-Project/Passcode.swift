//
//  Passcode.swift
//  COSC345-Project
//
//  Created by Hunter Kingsbeer on 27/09/21.
//

import SwiftUI
import CoreData

/// used to handle the initial lockscreen
struct PasscodeScreen: View {
    @Environment(\.presentationMode) var presentationMode
    ///``FetchRequest``: Creates a FetchRequest for the 'Receipt' CoreData entities. Contains a NSSortDescriptor that sorts and orders the receipts as specified by Date.
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Receipt.date, ascending: false)], animation: .spring())
    ///``receipts``: Takes and stores the requested Receipt entities in a FetchedResults variable of type Receipt. This variable is essentially an array of Receipt objects that the user has scanned.
    var receipts: FetchedResults<Receipt>
    ///``settings`` Alters the view based on the user's settings. Imports the UserSettings EnvironmentObject allowing unified usage and updating of the users settings across all classes.
    @EnvironmentObject var settings: UserSettings
    @Binding var locked: Bool
    @State var userInput = ""
    @State var backgroundColor = "background"
    @State var resetting = false
    @State var unusedBool = false
    
    var body: some View {
        ZStack {
            Color(backgroundColor)
                .animation(.spring())
                .ignoresSafeArea(.all)
            VStack(alignment: .center) {
                TitleText(buttonBool: $unusedBool, title: "Receipted", icon: backgroundColor == "UI2" ? "lock.open" : "lock")
                
                if !resetting {
                    VStack {
                        Text("Enter your current passcode.")
                            .font(.system(.title, design: .rounded)).bold()
                            .foregroundColor(Color(settings.accentColor))
                            .animation(.spring())
                            .multilineTextAlignment(.center).lineLimit(1)
                            .minimumScaleFactor(0.8)
                        HStack {
                            Circle()
                                .padding(userInput.count >= 1 ? 5 : 15)
                            Circle()
                                .padding(userInput.count >= 2 ? 5 : 15)
                            Circle()
                                .padding(userInput.count >= 3 ? 5 : 15)
                            Circle()
                                .padding(userInput.count >= 4 ? 5 : 15)
                        }.padding(.horizontal, 80).animation(.spring())
                        
                        HStack {
                            PasscodeButton(number: 1, passcodeIn: $userInput)
                            PasscodeButton(number: 2, passcodeIn: $userInput)
                            PasscodeButton(number: 3, passcodeIn: $userInput)
                        }
                        
                        HStack {
                            PasscodeButton(number: 4, passcodeIn: $userInput)
                            PasscodeButton(number: 5, passcodeIn: $userInput)
                            PasscodeButton(number: 6, passcodeIn: $userInput)
                        }
                        
                        HStack {
                            PasscodeButton(number: 7, passcodeIn: $userInput)
                            PasscodeButton(number: 8, passcodeIn: $userInput)
                            PasscodeButton(number: 9, passcodeIn: $userInput)
                        }
                        
                        HStack {
                            Spacer()
                            Button(action: { // clear
                                userInput = settings.devMode ? settings.passcode : ""
                                hapticFeedback(type: .rigid)
                            }){
                                Blur(effect: UIBlurEffect(style: .systemUltraThinMaterial))
                                    .frame(width: UIScreen.screenWidth * 0.2,
                                            height: UIScreen.screenWidth * 0.2)
                                    .cornerRadius(100)
                                    .overlay(
                                        Text("CLEAR")
                                            .foregroundColor(Color("text"))
                                            .font(.system(size: 16, weight: .bold, design: .rounded))
                                    )
                            }.buttonStyle(ShrinkingOpacityButton())
                            
                            Spacer()
                            PasscodeButton(number: 0, passcodeIn: $userInput)
                            Spacer()
                            
                            Button(action: { // delete
                                if userInput.count > 0 {
                                    userInput.removeLast()
                                    hapticFeedback(type: .rigid)
                                }
                            }){
                                Blur(effect: UIBlurEffect(style: .systemUltraThinMaterial))
                                    .frame(width: UIScreen.screenWidth * 0.2,
                                            height: UIScreen.screenWidth * 0.2)
                                    .cornerRadius(100)
                                    .overlay(
                                        Image(systemName: "delete.left")
                                            .foregroundColor(Color("text"))
                                            .font(.system(size: 16, weight: .bold, design: .rounded))
                                    )
                            }.buttonStyle(ShrinkingOpacityButton())
                            Spacer()
                        }.padding(.horizontal, 12).padding(.bottom, 5)
                        
                        Button(action: {
                            resetting = true
                            hapticFeedback(type: .rigid)
                        }){
                            Blur(effect: UIBlurEffect(style: .systemUltraThinMaterial))
                                .cornerRadius(18)
                                .frame(width: UIScreen.screenWidth * 0.25, height: UIScreen.screenWidth * 0.16)
                                .overlay(
                                    Text("FORGOT")
                                        .foregroundColor(Color("text"))
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                )
                        }.buttonStyle(ShrinkingOpacityButton())
                    }.transition(AnyTransition.opacity.combined(with: .scale(scale: 0.5))).animation(.spring())
                } else {
                    VStack {
                        Text("Delete current passcode.")
                            .font(.system(.title, design: .rounded)).bold()
                            .foregroundColor(Color(settings.accentColor))
                            .animation(.spring())
                            .multilineTextAlignment(.center).lineLimit(1)
                            .minimumScaleFactor(0.8)
                        
                        Text("Please confirm your choice.")
                            .font(.system(.body, design: .rounded))
                            .animation(.spring())
                            .multilineTextAlignment(.center).lineLimit(1)
                            .minimumScaleFactor(0.8)
                        Spacer()
                        Button(action: {
                            Receipt.deleteAll(receipts: receipts)
                            // unlock
                            backgroundColor = "yellow"
                            hapticFeedback(type: .light)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { hapticFeedback(type: .light) }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                locked = false
                                settings.passcode = ""
                                settings.passcodeProtection = false
                            }
                                
                        }){
                            Blur(effect: UIBlurEffect(style: .systemThinMaterial))
                                .opacity(0.9)
                                .cornerRadius(12)
                                .overlay(
                                    // the title and body
                                    VStack (alignment: .center){
                                        Spacer()
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .font(.system(size: 50))
                                        VStack(alignment: .center) {
                                            Text("Confirm deletion")
                                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                                .padding(.bottom, 5)
                                            Text("This will delete all stored data, and remove the current passcode.")
                                                .font(.system(size: 14, weight: .regular, design: .rounded))
                                                .frame(width: UIScreen.screenWidth * 0.45)
                                                .multilineTextAlignment(.center)
                                        }
                                        Spacer()
                                    }.padding()
                                ).frame(width: UIScreen.screenWidth * 0.65, height: UIScreen.screenHeight * 0.25)
                                .padding(.bottom)
                        }.buttonStyle(ShrinkingOpacityButton())
                        
                        Button(action: {
                            resetting = false
                            hapticFeedback(type: .light)
                        }){
                            Blur(effect: UIBlurEffect(style: .systemThinMaterial))
                                .opacity(0.9)
                                .cornerRadius(12)
                                .overlay(
                                    // the title and body
                                    VStack (alignment: .center){
                                        Spacer()
                                        Image(systemName: "arrow.backward")
                                            .font(.system(size: 50))
                                        VStack(alignment: .center) {
                                            Text("Cancel deletion")
                                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                                .padding(.bottom, 5)
                                            Text("This will return you to the passcode screen to enter your passcode.")
                                                .font(.system(size: 14, weight: .regular, design: .rounded))
                                                .frame(width: UIScreen.screenWidth * 0.4)
                                                .multilineTextAlignment(.center)
                                        }
                                        Spacer()
                                    }.padding()
                                ).frame(width: UIScreen.screenWidth * 0.65, height: UIScreen.screenHeight * 0.25)
                                .padding(.bottom)
                        }.buttonStyle(ShrinkingOpacityButton())
                        Spacer()
                    }.transition(AnyTransition.opacity.combined(with: .move(edge: .bottom))).animation(.spring())
                }
            }.padding(.horizontal).padding(.bottom, 50).animation(.spring())
        }.onChange(of: userInput, perform: { _ in
            if userInput.count == 4 {
                if userInput == settings.passcode {
                    // unlock
                    backgroundColor = "UI2"
                    hapticFeedback(type: .light)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { hapticFeedback(type: .medium) }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        locked = false
                    }
                } else {
                    // incorrect pass
                    backgroundColor = "red"
                    hapticFeedback(type: .heavy)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        backgroundColor = "background"
                        userInput = ""
                        hapticFeedback(type: .medium)
                    }
                }
                
            }
        })
    }
}

enum PassEditingState: String {
    case none = "none"
    case updating = "updating"
    case creating = "creating"
    case removing = "removing"
}


/// Used in adding/editing/removing the passcode
struct PasscodeEdit: View {
    @Environment(\.presentationMode) var presentationMode
    ///``settings`` Alters the view based on the user's settings. Imports the UserSettings EnvironmentObject allowing unified usage and updating of the users settings across all classes.
    @EnvironmentObject var settings: UserSettings
    @State var backgroundColor = "background"
    @Binding var result: (success: Bool, code: String)
    @State var expectedCode: String
    @State var repeatPass: String = ""
    @State var confirmedPass: Bool = false
    
    var body: some View {
        ZStack {
            Color(backgroundColor)
                .animation(.spring())
                .ignoresSafeArea(.all)
            VStack(alignment: .center) {
                Image(systemName: getIcon())
                    .font(.title)
                    .animation(.spring())
                Text(getTitle())
                    .font(.system(.title, design: .rounded)).bold()
                    .foregroundColor(Color(settings.accentColor))
                    .multilineTextAlignment(.center).lineLimit(1)
                    .minimumScaleFactor(0.8)
                Text(getSubtext())
                    .font(.system(.body, design: .rounded))
                    .animation(.spring())
                    .multilineTextAlignment(.center).lineLimit(1)
                    .minimumScaleFactor(0.8)
                HStack {
                    Circle()
                        .padding(result.code.count >= 1 ? 5 : 15)
                    Circle()
                        .padding(result.code.count >= 2 ? 5 : 15)
                    Circle()
                        .padding(result.code.count >= 3 ? 5 : 15)
                    Circle()
                        .padding(result.code.count >= 4 ? 5 : 15)
                }.padding(.horizontal, 80).animation(.spring())
                
                HStack {
                    PasscodeButton(number: 1, passcodeIn: $result.code)
                    PasscodeButton(number: 2, passcodeIn: $result.code)
                    PasscodeButton(number: 3, passcodeIn: $result.code)
                }
                
                HStack {
                    PasscodeButton(number: 4, passcodeIn: $result.code)
                    PasscodeButton(number: 5, passcodeIn: $result.code)
                    PasscodeButton(number: 6, passcodeIn: $result.code)
                }
                
                HStack {
                    PasscodeButton(number: 7, passcodeIn: $result.code)
                    PasscodeButton(number: 8, passcodeIn: $result.code)
                    PasscodeButton(number: 9, passcodeIn: $result.code)
                }
                
                HStack {
                    Spacer()
                    Button(action: { // clear
                        result.code = settings.devMode ? expectedCode : ""
                    }){
                        Blur(effect: UIBlurEffect(style: .systemUltraThinMaterial))
                            .frame(width: UIScreen.screenWidth * 0.2,
                                    height: UIScreen.screenWidth * 0.2)
                            .cornerRadius(100)
                            .overlay(
                                Text("CLEAR")
                                    .foregroundColor(Color("text"))
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                            )
                    }.buttonStyle(ShrinkingOpacityButton())
                    
                    Spacer()
                    PasscodeButton(number: 0, passcodeIn: $result.code)
                    Spacer()
                    
                    Button(action: { // delete
                        if result.code.count > 0 {
                            result.code.removeLast()
                        }
                    }){
                        Blur(effect: UIBlurEffect(style: .systemUltraThinMaterial))
                            .frame(width: UIScreen.screenWidth * 0.2,
                                    height: UIScreen.screenWidth * 0.2)
                            .cornerRadius(100)
                            .overlay(
                                Image(systemName: "delete.left")
                                    .foregroundColor(Color("text"))
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                            )
                    }.buttonStyle(ShrinkingOpacityButton())
                    Spacer()
                }.padding(.horizontal, 12).padding(.bottom)
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }){
                    Blur(effect: UIBlurEffect(style: .systemUltraThinMaterial))
                        .cornerRadius(18)
                        .frame(width: UIScreen.screenWidth * 0.25, height: UIScreen.screenWidth * 0.16)
                        .overlay(
                            Text("CANCEL")
                                .foregroundColor(Color("text"))
                                .font(.system(.body, design: .rounded)).bold()
                        )
                }.buttonStyle(ShrinkingOpacityButton())
            }.padding()
            .padding(.bottom, 30)
        }.onChange(of: result.code, perform: { _ in
            if result.code.count == 4 {
                if expectedCode == "creating" { // new pass
                    if repeatPass.isEmpty { // saves first code so the user can repeat it
                        repeatPass = result.code
                        hapticFeedback(type: .light)
                        result.code = ""
                    } else if result.code == repeatPass { // if users second code matches, successfully set new pin
                        success()
                    } else if result.code != repeatPass{ // otherwise fail, user will redo input
                        incorrect()
                    }
                } else if expectedCode == "updating" { // updating pass
                    if confirmedPass == false && result.code == settings.passcode { // entered current pass
                        confirmedPass = true
                        hapticFeedback(type: .light)
                        result.code = ""
                    } else if confirmedPass == false && result.code != settings.passcode {
                        incorrect()
                    } else if confirmedPass == true {
                        if repeatPass.isEmpty { // first entering a code, sets it so the user can confirm it
                            repeatPass = result.code
                            result.code = ""
                        } else if result.code == repeatPass { // if users second code matches, successfully set new pin
                            success()
                        } else { // otherwise fail, user will redo input
                            incorrect()
                        }
                    }
                } else { // removing pass
                    if result.code == expectedCode {
                        // unlock
                        success()
                    } else {
                        // incorrect pass
                        incorrect()
                    }
                }
            }
        })
    }
    
    func getTitle() -> String {
        if expectedCode == "creating" {
            return "Create a new passcode."
        } else if expectedCode == "updating" {
            return "Update your passcode."
        } else {
            return "Disable Passcode Protection."
        }
    }
    
    func getSubtext() -> String {
        if expectedCode == "creating" {
            return repeatPass.isEmpty ? "If you forget your passcode, your data will be lost." : "Confirm your passcode."
        } else if expectedCode == "updating" {
            return confirmedPass == false ? "Enter your current passcode." :
                repeatPass.isEmpty ? "Set a new passcode." : "Confirm your new passcode."
        }
        return "Enter your current passcode."
    }
    
    func getIcon() -> String {
        let update = backgroundColor == "UI2"
        if expectedCode == "creating" { // new pass
            return update ? "lock" : "lock.open"
        } else if expectedCode == "updating" { // update pass
            return update ? "checkmark" : "lock.rotation"
        } else if expectedCode == settings.passcode { // remove pass
            return update ? "lock.slash.fill" : "lock.slash"
        }
        return "lock"
    }
    
    func success(dismiss: Bool = true){
        backgroundColor = "UI2"
        hapticFeedback(type: .light)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { hapticFeedback(type: .light) }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            result.success = true
            if dismiss {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    func incorrect(dismiss: Bool = false){
        backgroundColor = "red"
        hapticFeedback(type: .heavy)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            result.code = ""
            repeatPass = ""
            confirmedPass = false
            result.success = false
            backgroundColor = "background"
            hapticFeedback(type: .medium)
            if dismiss {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

struct PasscodeButton: View {
    ///``settings`` Alters the view based on the user's settings. Imports the UserSettings EnvironmentObject allowing unified usage and updating of the users settings across all classes.
    @EnvironmentObject var settings: UserSettings
    let number: Int
    @Binding var passcodeIn: String
    
    var body: some View {
        Button(action: { // 1
            addNumber(numIn: number)
            hapticFeedback(type: .light)
        }){
            Blur(effect: UIBlurEffect(style: .systemUltraThinMaterial))
                    .cornerRadius(100)
                    .frame(width: UIScreen.screenWidth * 0.25, height: UIScreen.screenWidth * 0.25)
                    .overlay(
                        Text("\(number)")
                            .foregroundColor(Color("text"))
                            .font(.system(.title, design: .rounded)).bold()
                    )
        }.buttonStyle(ShrinkingOpacityButton())
    }
    
    func addNumber(numIn: Int){
        if passcodeIn.count < 4 {
            passcodeIn += String(numIn)
        }
    }
}
