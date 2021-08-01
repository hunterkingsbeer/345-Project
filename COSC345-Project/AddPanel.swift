//
//  AddPanel.swift
//  COSC345-Project
//
//  Created by Hunter Kingsbeer on 29/07/21.
//

import Foundation
import CoreData
import SwiftUI

/// AddPanel handles the visibility of the various add panel views.
/// - Main Parent: ContentView
struct AddPanelParent: View {
    /// AddPanelType maintains and updates the add panels view state.
    @Binding var addPanelState: AddPanelType
    @State var showAddButtons: Bool = false

    var body: some View {
        RoundedRectangle(cornerRadius: 25)
            .shadow(color: (Color(.black)).opacity(0.15), radius: 5, x: 0, y: 0)
            .foregroundColor(Color("object"))
            .overlay(
                VStack{
                    if addPanelState == .homepage {
                        AddPanelHomepageView(addPanelState: $addPanelState, showAddButtons: $showAddButtons)
                            .transition(AnyTransition.move(edge: .bottom).combined(with: .opacity))
                            .animation(.spring())
                            .foregroundColor(Color("text"))
                    } else {
                        AddPanelDetailView(addPanelState: $addPanelState)
                            .transition(AnyTransition.move(edge: .bottom).combined(with: .opacity))
                            .animation(.spring())
                            .foregroundColor(Color("text"))
                    }
                }
            ).foregroundColor(.black).animation(.easeInOut)
            .frame(height: UIScreen.screenHeight * (addPanelState == .homepage ? (showAddButtons ? 0.12 : 0.1) : 0.9))
            .animation(.spring())
    }
}

/// AddPanelHomepageView displays the homepage view for the Add Panel.
///  Displays the add a receipt via gallery or camera buttons
/// - Main Parent: AddPanel
struct AddPanelHomepageView: View {
    /// AddPanelType maintains and updates the add panels view state.
    @Binding var addPanelState: AddPanelType
    @Binding var showAddButtons: Bool
    var body: some View {
        HStack {
            if showAddButtons {
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation(.spring()){
                            addPanelState = .gallery
                        }
                    }){
                        VStack {
                            Image(systemName: "doc.text")
                                .font(.largeTitle)
                            Text("Gallery")
                                .font(.system(.title, design: .rounded))//.bold()
                        }.frame(minWidth: 0, maxWidth: .infinity)
                        .frame(minHeight: 0, maxHeight: .infinity)
                        .contentShape(Rectangle())
                    }.buttonStyle(ShrinkingButton())
                    .transition(.move(edge: .leading))
                    Spacer()
                    
                    Divider()
                        .foregroundColor(Color("text"))
                        .padding(.vertical, 25)
                    
                    Spacer()
                    Button(action: {
                        withAnimation(.spring()){
                            addPanelState = .camera
                        }
                    }){
                        VStack {
                            Image(systemName: "camera")
                                .font(.largeTitle)
                            Text("Camera")
                                .font(.system(.title, design: .rounded))//.bold()
                        }.frame(minWidth: 0, maxWidth: .infinity)
                        .frame(minHeight: 0, maxHeight: .infinity)
                        .contentShape(Rectangle())
                    }.buttonStyle(ShrinkingButton())
                    .transition(.move(edge: .trailing))
                    Spacer()
                }
            } else {
                Button(action: { 
                    showAddButtons = true
                    
                }){
                    Image(systemName: "plus")
                        .font(.largeTitle)
                }
            }
        }.onChange(of: showAddButtons, perform: { _ in
            if showAddButtons {
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    showAddButtons = false // turns off adding button after 4 secs
                }
            }
        })
    }
}



/// AddPanelDetailView shows the expanded Add Panel with respect to the AddPanelState
/// - Main Parent: AddPanel
struct AddPanelDetailView: View {
    
    /// AddPanelType maintains and updates the add panels view state.
    @Binding var addPanelState: AddPanelType
    /// The recognized text from scanning an image
    @State var recognizedText: String = ""
    /// Whether the scan is valid or not, initially there is .noScan
    @State var validScan: ValidScanType = .noScan
    /// If a scan is not valid, this bool when set to true will trigger an alert
    @State var validScanAlert: Bool = false
    
    var body: some View {
        VStack{
            if addPanelState == .camera { 
                Text("Scan using Camera")
                    .font(.system(.title, design: .rounded))
                    .padding(.bottom, 5)
                if !UIDevice.current.isSimulator {
                    ScanDocumentView(recognizedText: self.$recognizedText, validScan: $validScan)
                    .cornerRadius(18)
                    .animation(.spring())
                } else {
                    Text("Camera not supported in the simulator!")
                    Spacer()
                }
            } else if addPanelState == .gallery {
                Text("Scan using Gallery")
                    .font(.system(.title, design: .rounded))
                    .padding(.bottom, 5)
                
                ImagePicker(recognizedText: self.$recognizedText, validScan: $validScan)
                    .cornerRadius(18)
                    .animation(.spring())
            }
            Button(action: {
                withAnimation(.spring()){
                    addPanelState = .homepage
                }
            }){
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.red)
                    .overlay(
                        Image(systemName: "xmark")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundColor(Color("object"))
                    ).frame(height: UIScreen.screenHeight*0.1)
            }.buttonStyle(ShrinkingButton())
            Spacer()
        }.padding()
        .onChange(of: recognizedText, perform: { _ in
            validScanAlert = validScan == .invalidScan ? true : false
            // if validScanType == invalid then alert the user
            if validScan == .validScan { // IMPROVE THIS! Go to a "is this correct?" screen
                Receipt.saveScan(recognizedText: recognizedText)
                withAnimation(.spring()) {
                    addPanelState = .homepage
                }
            }
        }).alert(isPresented: $validScanAlert) {
            Alert(
                title: Text("Receipt Not Saved!"),
                message: Text("This image is not valid. Try something else."),
                dismissButton: .default(Text("Okay"))
            )
        }
    }
}
