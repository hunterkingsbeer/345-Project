//
//  HomeView.swift
//  COSC345-Project
//
//  Created by Hunter Kingsbeer on 4/08/21.
//

import SwiftUI
import CoreData

/// ContentView is the main content view that is called when starting the app.
struct HomeView: View {
    /// Fetches Receipt entities in CoreData sorting by the NSSortDescriptor.
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Receipt.date, ascending: false)], animation: .spring())
    /// Stores the fetched results as an array of Receipt objects.
    var receipts: FetchedResults<Receipt>
    /// Fetches Folder entities in CoreData sorting by the NSSortDescriptor.
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Folder.receiptCount, ascending: false),
                          NSSortDescriptor(keyPath: \Folder.title, ascending: true)], animation: .spring())
    /// Stores the fetched results as an array of Folder objects.
    var folders: FetchedResults<Folder>
    
    /// Settings imports the UserSettings
    @EnvironmentObject var settings: UserSettings
    @State var userSearch: String = ""
    @State var selectedFolder: String = ""
    @State var colors = Color.colors

    var body: some View {
        ZStack {
            BackgroundView()
            
            VStack {
                HStack {
                    HStack {
                        if selectedFolder.isEmpty {
                            ZStack(alignment: .leading) {
                                if userSearch.isEmpty {
                                    Text("Receipted.")
                                        .font(.system(size: 40, weight: .semibold))
                                        .transition(AnyTransition.opacity.combined(with: .move(edge: .bottom)))
                                }
                                TextField("", text: $userSearch)
                                    .animation(.easeInOut(duration: 0.3))
                            }
                            .transition(AnyTransition.opacity.combined(with: .move(edge: .bottom)))
                            .foregroundColor(Color(selectedFolder.isEmpty || settings.minimal ? "text" : "background"))
                            .font(.system(size: 40, weight: .regular))
                        } else {
                            HStack {
                                Image(systemName: Folder.getIcon(title: selectedFolder))
                                    .font(.system(size: 30, weight: .semibold))
                                Text("\(selectedFolder).")
                                    .font(.system(size: 40, weight: .semibold))
                            }
                            .foregroundColor(Color(selectedFolder.isEmpty || settings.minimal ? "text" : "background"))
                            .transition(AnyTransition.opacity.combined(with: .offset(y: -100)))
                        }
                        
                        Spacer()
                    }.padding(.bottom, 10).padding(.top, 20)
                    .background(
                        ZStack{
                            if !settings.minimal {
                                VStack {
                                    if selectedFolder.isEmpty {
                                        Rectangle()
                                            .fill(Color.clear)
                                    } else {
                                        Rectangle()
                                            .fill(Color(Folder.getColor(title: selectedFolder)))
                                            .transition(AnyTransition.offset(y: -150).combined(with: .opacity))
                                    }
                                }
                                .scaleEffect(x: 1.5)
                                .animation(.easeOut(duration: 0.3))
                                .ignoresSafeArea(edges: .top)
                            }
                            if selectedFolder.isEmpty {
                                VStack {
                                    Spacer()
                                    Rectangle()
                                        .frame(height: 2)
                                        .foregroundColor(Color("object"))
                                }.padding(.bottom, 14)
                                .transition(AnyTransition.opacity.combined(with: .move(edge: .bottom)))
                            }
                        }
                    )
                    
                    ZStack{
                        if userSearch.isEmpty && selectedFolder.isEmpty {
                            Image(systemName: "magnifyingglass")
                        } else {
                            // make a down arrow
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)){
                                    userSearch = ""
                                    selectedFolder = ""
                                }
                                UIApplication.shared.endEditing()
                            }){
                                if !selectedFolder.isEmpty { // if selecting a folder
                                    Image(systemName: "chevron.down")
                                        .transition(AnyTransition.opacity.combined(with: .offset(y: -100)))
                                } else if !userSearch.isEmpty { // if typing text
                                    Image(systemName: "xmark")
                                }
                            }
                        }
                    }
                    .font(.system(size: 19, weight: .bold, design: .rounded))
                    .foregroundColor(Color(selectedFolder.isEmpty || settings.minimal ? "text" : "background"))
                    .padding(.horizontal)
                    .transition(AnyTransition.opacity.combined(with: .scale(scale: 0.9)))//.animation(.spring())
                }.padding(.horizontal)
                
                // FOLDERS
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(folders) { folder in
                            if selectedFolder != folder.title {
                                TagView(folder: folder, selectedFolder: $selectedFolder)
                                        .transition(AnyTransition.opacity.combined(with: .scale(scale: 0.9))).animation(.spring())
                                
                            }
                        }
                    }.padding(.horizontal)
                }
                
                // RECEIPTS
                ScrollView(showsIndicators: false) {
                    if receipts.count > 0 {
                        VStack {
                            // If selectedFolder contains something, use it to show receipts in the folder.
                            // Else If userSearch contains something, use it to check for receipts.
                                // Else show receipts that have any body text (all receipts).
                            ForEach(receipts.filter({ !selectedFolder.isEmpty ?
                                                        $0.folder!.localizedCaseInsensitiveContains("\(selectedFolder)") :
                                                      !userSearch.isEmpty ?
                                                        $0.body!.localizedCaseInsensitiveContains("\(userSearch)") ||
                                                        $0.folder!.localizedCaseInsensitiveContains("\(userSearch)")  ||
                                                        $0.store!.localizedCaseInsensitiveContains("\(userSearch)") :
                                                        $0.body!.count > 0 })){ receipt in
                                ReceiptView(receipt: receipt).transition(.opacity)
                            }
                        }.padding(.bottom)
                    } else {
                        noReceiptsView()
                    }
                }
                .cornerRadius(12)
                .padding(.horizontal)
            }
        }
    }
    
    func getColorBlock() -> LinearGradient {
        if selectedFolder.isEmpty {
            return LinearGradient(gradient: Gradient(colors:[Color.clear]),
                                  startPoint: .topLeading, endPoint: .bottomTrailing)
        } else if !selectedFolder.isEmpty {
            let color = Color(Folder.getColor(title: selectedFolder))
            return LinearGradient(gradient: Gradient(colors:[(color)]),
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                
                
        } else {
            return LinearGradient(gradient: Gradient(colors:[(colors[settings.style].leading),
                                                            (colors[settings.style].trailing)]),
                                  startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
}

struct noReceiptsView: View {
    var body: some View{
        RoundedRectangle(cornerRadius: 18)
            .fill(Color("accent"))
            .overlay(
                // the title and body
                HStack (alignment: .center){
                    Image(systemName: "doc.plaintext")
                    VStack(alignment: .leading) {
                        Text("Add a receipt!")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                        Text("Tap the 'Scan' button at the bottom.")
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                    }
                    Spacer()
                }.padding(10)
            ).frame(height: UIScreen.screenHeight * 0.08)
    }
}

struct SearchBar: View {
    @Binding var userSearch: String
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
            CustomTextField(placeholder: Text("Search"), text: $userSearch)
            Spacer()
        }.padding(.leading, 12)
        .frame(height: UIScreen.screenHeight*0.05)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color("accent"))
        )
        .ignoresSafeArea(.keyboard)
    }
}
