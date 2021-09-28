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
    ///``settings`` Alters the view based on the user's settings. Imports the UserSettings EnvironmentObject allowing unified usage and updating of the users settings across all classes.
    @EnvironmentObject var settings: UserSettings
    @Binding var locked: Bool
    @State var userInput = ""
    @State var backgroundColor = "background"
    
    var body: some View {
        ZStack {
            Color(backgroundColor)
                .animation(.spring())
                .ignoresSafeArea(.all)
            VStack(alignment: .center) {
                TitleText(buttonBool: $settings.devMode, title: "Receipted", icon: backgroundColor == "UI2" ? "lock.open" : "lock")
                Text("Enter your passcode\(settings.devMode ? " [\(settings.passcode)]" : "").")
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
                }.padding(.bottom, 50).padding(.horizontal, 12)
            }.padding(.horizontal)
        }.onChange(of: userInput, perform: { _ in
            if userInput.count == 4 {
                if userInput == settings.passcode {
                    // unlock
                    backgroundColor = "UI2"
                    hapticFeedback(type: .light)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { hapticFeedback(type: .light) }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        locked = false
                    }
                } else {
                    // incorrect pass
                    backgroundColor = "red"
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        hapticFeedback(type: .medium)
                        backgroundColor = "background"
                        userInput = ""
                    }
                }
                
            }
        })
    }
}

/// Used in adding/editing/removing the passcode
struct PasscodeEdit: View {
    @Environment(\.presentationMode) var presentationMode
    ///``settings`` Alters the view based on the user's settings. Imports the UserSettings EnvironmentObject allowing unified usage and updating of the users settings across all classes.
    @EnvironmentObject var settings: UserSettings
    @State var backgroundColor = "background"
    @Binding var result: (success: Bool, code: String)
    @State var expectedCode: String
    @State var confirmPass: String = ""
    
    var body: some View {
        ZStack {
            Color(backgroundColor)
                .animation(.spring())
                .ignoresSafeArea(.all)
            VStack(alignment: .center) {
                Image(systemName: getIcon())
                    .font(.title)
                    .animation(.spring())
                Text(expectedCode == "creating" ? "Create a new passcode." :
                    expectedCode == "updating" ? "Update your passcode." : "Remove passcode protection.")
                    .font(.system(.title, design: .rounded)).bold()
                    .foregroundColor(Color(settings.accentColor))
                    .multilineTextAlignment(.center).lineLimit(1)
                    .minimumScaleFactor(0.8)
                Text((expectedCode == "creating" || expectedCode == "updating") && !confirmPass.isEmpty ? "Confirm your passcode." :
                        expectedCode == "creating" && confirmPass.isEmpty ? "If you forget your password, your data will be lost." :
                        expectedCode == "updating" ? "Enter a new passcode." : "Enter your current passcode.")
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
                if expectedCode == "creating" || expectedCode == "updating" {
                    if confirmPass.isEmpty { // first entering a code, sets it so the user can confirm it
                        confirmPass = result.code
                        result.code = ""
                    } else if result.code == confirmPass { // if users second code matches, successfully set new pin
                        success()
                    } else { // otherwise fail, user will redo input
                        incorrect(dismiss: false)
                    }
                } else {
                    if result.code == expectedCode {
                        // unlock
                        success()
                    } else {
                        // incorrect pass
                        incorrect(dismiss: false)
                    }
                }
            }
        })
    }
    
    func getIcon() -> String {
        let update = backgroundColor == "UI2"
        if expectedCode == "creating" { // new code
            return update ? "lock" : "lock.open"
        } else if expectedCode == "updating" { // update code
            return update ? "checkmark" : "lock.rotation"
        } else if expectedCode == settings.passcode { // remove code
            return update ? "xmark" : "lock.slash"
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
    
    func incorrect(dismiss: Bool = true){
        backgroundColor = "red"
        hapticFeedback(type: .heavy)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            result.code = ""
            confirmPass = ""
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
            //hapticFeedback(type: .light)
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
