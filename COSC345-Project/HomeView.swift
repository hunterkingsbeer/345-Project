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

    var body: some View {
        ZStack {
            BackgroundView()
            
            VStack {
                TitleText(title: "receipted")
                    .padding(.horizontal)
                
                ZStack {
                    // search bar
                    if selectedFolder == "" {
                        SearchBar(userSearch: $userSearch)
                            .transition(AnyTransition.opacity.combined(with: .scale(scale: 0.9))).animation(.spring())
                    } else {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(Folder.getColor(title: selectedFolder)))
                            HStack {
                                Image(systemName: Folder.getIcon(title: selectedFolder))
                                Text("\(Folder.getCount(title: selectedFolder)) \(selectedFolder)")
                                Spacer()
                            }.font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(Color("background"))
                            .padding(10)
                        }.frame(height: UIScreen.screenHeight*0.05)
                        .transition(AnyTransition.opacity.combined(with: .scale(scale: 0.9))).animation(.spring())
                    }
                    HStack {
                        Spacer()
                        if userSearch != "" {
                            Button(action: {
                                withAnimation(.spring()){
                                    userSearch = ""
                                    selectedFolder = ""
                                }
                                UIApplication.shared.endEditing()
                            }){
                                Image(systemName: "xmark")
                                    .font(.system(size: 19, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(selectedFolder != "" ? "background" : "text"))
                            }.padding(.trailing)
                            .transition(AnyTransition.opacity.combined(with: .scale(scale: 0.9))).animation(.spring())
                        }
                    }
                }.transition(.slide).animation(.spring()).padding(.horizontal)
                
                // FOLDERS
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(folders) { folder in
                            if selectedFolder != folder.title {
                                Button(action: {
                                    withAnimation(.spring()){
                                        selectedFolder = folder.title ?? "Default"
                                    }
                                }){
                                    TagView(folder: folder)
                                }.buttonStyle(ShrinkingButton())
                                .onChange(of: selectedFolder){ _ in
                                    userSearch = selectedFolder
                                }
                                .transition(AnyTransition.opacity.combined(with: .scale(scale: 0.9))).animation(.spring())
                                
                            }
                        }
                    }.padding(.horizontal)
                }
                
                // RECEIPTS
                ScrollView(showsIndicators: false) {
                    if receipts.count > 0 {
                        VStack {
                            ForEach(receipts.filter({ userSearch.count > 0 ?
                                                        $0.body!.localizedCaseInsensitiveContains(userSearch) ||
                                                        $0.folder!.localizedCaseInsensitiveContains(userSearch)  ||
                                                        $0.store!.localizedCaseInsensitiveContains(userSearch) :
                                                        $0.body!.count > 0 })){ receipt in
                                ReceiptView(receipt: receipt).transition(.opacity)
                            }
                        }.padding(.bottom)
                    } else {
                        noReceiptsView()
                    }
                }
                .cornerRadius(false ? 0 : 12)
                .padding(.horizontal)
                .toolbar {
                    ToolbarItem(placement: .bottomBar) {
                        Image(systemName: "gearshape.fill")
                    }
                    ToolbarItem(placement: .bottomBar) {
                        Image(systemName: "house")
                    }
                    
                    ToolbarItem(placement: .bottomBar) {
                        Image(systemName: "plus")
                    }
                }.navigationBarTitle("Receipted.")
            }.navigationViewStyle(DoubleColumnNavigationViewStyle())
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
