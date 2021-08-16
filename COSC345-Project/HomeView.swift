//
//  HomeView.swift
//  COSC345-Project
//
//  Created by Hunter Kingsbeer on 4/08/21.
//

import SwiftUI
import CoreData

/// ``HomeView``
/// is a View struct that displays the home page of the application. This homepage shows the user its receipts, the folders, the title bar (doubling as a search bar).
/// - Called by ContentView.
struct HomeView: View {
    ///``FetchRequest``: Creates a FetchRequest for the 'Receipt' CoreData entities. Contains a NSSortDescriptor that sorts and orders the receipts as specified by Date.
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Receipt.date, ascending: false)], animation: .spring())
    ///``receipts``: Takes and stores the requested Receipt entities in a FetchedResults variable of type Receipt. This variable is essentially an array of Receipt objects that the user has scanned.
    var receipts: FetchedResults<Receipt>
    ///``FetchRequest``: Creates a FetchRequest for the 'Folder' CoreData entities. Contains 2 NSSortDescriptor's that sorts and orders the folders as specified by title and receipt count.
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Folder.receiptCount, ascending: false),
                          NSSortDescriptor(keyPath: \Folder.title, ascending: true)], animation: .spring())
    ///``folders``: Takes and stores the requested Folder entities in a FetchedResults variable of type Folder. This variable is essentially an array of Folder objects relating to the receipts predicted folders.
    var folders: FetchedResults<Folder>
    ///``userSearch``: Filters the search results based on the users search input into the titlebar/search bar. This applies to every section of a receipt.
    @State var userSearch: String = ""
    ///``selectedFolder``: Filters the search results based on the users selected Folder, so that only receipts within the selected Folder are displayed.
    @State var selectedFolder: String = ""
    ///``colors``: Imports an array of tuples containing various colors that are used to style the UI. This is based on the UserSettings 'style' setting, and is an @State to update the UI.
    @State var colors = Color.colors
    ///``settings``: Imports the UserSettings environment object allowing unified usage and updating of the users settings across all classes.
    @EnvironmentObject var settings: UserSettings

    var body: some View {
        ZStack {
            BackgroundView()
            
            VStack {
                HStack {
                    HomeTitleBar(selectedFolder: $selectedFolder, userSearch: $userSearch)
                    
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
                    .foregroundColor(Color(selectedFolder.isEmpty ? "text" : "background"))
                    .padding(.horizontal)
                    .transition(AnyTransition.opacity.combined(with: .scale(scale: 0.9)))//.animation(.spring())
                }.padding(.horizontal)
                
                // FOLDERS
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(folders) { folder in
                            if selectedFolder != folder.title {
                                FolderView(folder: folder, selectedFolder: $selectedFolder)
                                    .transition(AnyTransition.opacity.combined(with: .scale(scale: 0.9)))
                                    .animation(.spring())
                                
                            }
                        }.padding(.vertical, 8)
                    }.padding(.horizontal)
                }
                
                // RECEIPTS
                ScrollView(showsIndicators: false) {
                    VStack {
                        if receipts.count > 0 {
                        
                            // If selectedFolder contains something, use it to show receipts in the folder.
                            // Else If userSearch contains something, use it to check for receipts.
                                // Else show receipts that have any body text (all receipts).
                            ForEach(receipts.filter({ !selectedFolder.isEmpty ?
                                                        $0.folder!.localizedCaseInsensitiveContains("\(selectedFolder)") :
                                                      !userSearch.isEmpty ?
                                                        $0.body!.localizedCaseInsensitiveContains("\(userSearch)") ||
                                                        $0.folder!.localizedCaseInsensitiveContains("\(userSearch)")  ||
                                                        $0.title!.localizedCaseInsensitiveContains("\(userSearch)") :
                                                        $0.body!.count > 0 })){ receipt in
                                ReceiptView(receipt: receipt)
                                    .transition(.opacity)
                                    .padding(.horizontal)
                                    .padding(.bottom, 5)
                            }
                        } else {
                            NoReceiptsView()
                        }
                    }.padding(.top, 8).padding(.bottom)
                }.cornerRadius(0)
            }
        }
    }
}

/// ``NoReceiptsView``
/// is a View struct that displays when the user has added no receipts. Upon interaction it links the user to the scan tab.
/// - Called by HomeView.
struct NoReceiptsView: View {
    ///``selectedTab`` Controls the TabView's active tab it is viewing. In this case, it is used to switch the user's view to the scanning page.
    @EnvironmentObject var selectedTab: TabSelection
    /// ``settings``: Imports the UserSettings environment object allowing unified usage and updating of the users settings across all classes.
    @EnvironmentObject var settings: UserSettings
    
    var body: some View{
        Button(action: {
            selectedTab.changeTab(tabPage: .scan)
        }){
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(settings.shadows ? "shadowObject" : "accent"))
                .dropShadow(isOn: settings.shadows, opacity: settings.darkMode ? 0.45 : 0.15, radius: 4)
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
                .padding(.horizontal)
        }.buttonStyle(ShrinkingButton())
    }
}

/// ``HomeTitleBar``
/// is a View struct that functions similarily to ``TitleText``, to display the "Receipted." title, however it also doubles as a search bar which hooks into the userSearch variable to filter receipts.
/// - Called by HomeView.
struct HomeTitleBar: View {
    /// ``settings``: Imports the UserSettings environment object allowing unified usage and updating of the users settings across all classes.
    @EnvironmentObject var settings: UserSettings
    ///``selectedFolder``: Filters the search results based on the users selected Folder, so that only receipts within the selected Folder are displayed.
    @Binding var selectedFolder: String
    ///``userSearch``: Filters the search results based on the users search input into the titlebar/search bar. This applies to every section of a receipt.
    @Binding var userSearch: String
    var body: some View {
        HStack {
            if selectedFolder.isEmpty {
                ZStack(alignment: .leading) {
                    if userSearch.isEmpty {
                        Text("Receipted.")
                            .font(.system(size: 40, weight: .semibold))
                            .foregroundColor(Color("text"))
                            .transition(AnyTransition.opacity.combined(with: .move(edge: .bottom)))
                    }
                    TextField("", text: $userSearch)
                        .animation(.easeInOut(duration: 0.3))
                        .accessibility(identifier: "SearchBar")
                }
                .transition(AnyTransition.opacity.combined(with: .move(edge: .bottom)))
                .foregroundColor(Color(selectedFolder.isEmpty ? "text" : "background"))
                .font(.system(size: 40, weight: .regular))
            } else {
                HStack {
                    Image(systemName: Folder.getIcon(title: selectedFolder))
                        .font(.system(size: 30, weight: .semibold))
                    Text("\(selectedFolder).")
                        .font(.system(size: 40, weight: .semibold))
                        .lineLimit(2).minimumScaleFactor(0.85)
                }
                .foregroundColor(Color(selectedFolder.isEmpty ? "text" : "background"))
                .transition(AnyTransition.opacity.combined(with: .offset(y: -100)))
            }
            Spacer()
        }.padding(.bottom, 10).padding(.top, 20)
        .background(
            ZStack{
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
    }
}
