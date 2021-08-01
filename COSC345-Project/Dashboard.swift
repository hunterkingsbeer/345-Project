//
//  Dashboard.swift
//  COSC345-Project
//
//  Created by Hunter Kingsbeer on 29/07/21.
//

import Foundation
import SwiftUI
import CoreData

/// DashboardPanelParent handles the view states for the dashboard panel
/// - Main Parent: ContentView
struct DashboardPanelParent: View {
    /// DashPanelState maintains and updates the dashboards view state.
    @Binding var dashPanelState: DashPanelType
    
    var body: some View {
        RoundedRectangle(cornerRadius: 25)
            .shadow(color: Color(.black).opacity(0.15), radius: 5, x: 0, y: 0)
            .foregroundColor(Color("object"))
            .overlay(
                VStack {
                    // TITLE BAR AND SETTINGS -------------
                    TitleBar(dashPanelState: $dashPanelState)
                        .padding()
                    
                    if dashPanelState != .settings {
                        DashboardHomepage(dashPanelState: $dashPanelState)
                            .transition(AnyTransition.move(edge: .leading).combined(with: .opacity))
                            .animation(.spring())
                    } else if dashPanelState == .settings {
                        SettingsView()
                            .transition(AnyTransition.move(edge: .trailing).combined(with: .opacity))
                            .animation(.spring())
                    }
                }
            ).animation(.spring())
    }
}

struct TitleBar: View {
    @Binding var dashPanelState: DashPanelType
    
    var body: some View {
        HStack {
            let onSettings = dashPanelState == .settings
            if onSettings {
                Spacer()
            }
            
            Button(action: {
                withAnimation(.spring()){
                    dashPanelState = dashPanelState == .settings ? .homepage : .settings
                }
            }){
                Image(systemName: "gearshape.fill")
                    .font(.title).foregroundColor(Color("text"))
                    .scaleEffect(onSettings ? 1.3 : 1)
                    .animation(.spring())
            }
            
            Spacer()
            if !onSettings {
                HStack {
                    Spacer()
                    Text("Receipted.")
                        .foregroundColor(Color("text"))
                        .font(.system(.title, design: .rounded)).bold()
                    Spacer()
                    Image(systemName: "gearshape.fill")
                        .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/).foregroundColor(.clear)
                }.transition(AnyTransition.move(edge: .trailing).combined(with: .opacity))
                .animation(.spring())
            }
        }
    }
}

/// DashboardHomepage holds the homepage view for the app. Displaying receipts, tags and search.
/// - Main Parent: ContentView
struct DashboardHomepage: View {
    /// Fetches Receipt entities in CoreData sorting by the NSSortDescriptor.
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Receipt.date, ascending: false)], animation: .spring())
    /// Stores the fetched results as an array of Receipt objects.
    var receipts: FetchedResults<Receipt>
    /// Fetches Folder entities in CoreData sorting by the NSSortDescriptor.
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Folder.receiptCount, ascending: false)],
        animation: .spring())
    /// Stores the fetched results as an array of Folder objects.
    var folders: FetchedResults<Folder>
    
    /// DashPanelState maintains and updates the dashboards view state.
    @Binding var dashPanelState: DashPanelType
    /// String holding the users current search input
    @State var userSearch: String = ""
    /// Placeholder for a filtered search setting
    @State var warrenty = false
    /// Placeholder for a filtered search setting
    @State var favorites = false
    
    var body: some View {
        VStack {
            // search bar
            SearchBar(userSearch: $userSearch, warrenty: $warrenty, favorites: $favorites).padding(.horizontal)
            // category and tags bar
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(folders) { folder in
                        Button(action: {
                            let title = folder.title
                            userSearch = title == userSearch ? "" : title ?? ""
                        }){
                            VStack{
                                // Hides the tag if its being searched, tag moves to search bar.
                                if userSearch.lowercased() != (folder.title ?? "default").lowercased(){
                                    TagView(folder: folder)
                                }
                            }
                        }.buttonStyle(ShrinkingButton())
                    }
                }.padding(.horizontal)
            }//.cornerRadius(15)
            
            // receipts including search results
            ScrollView(showsIndicators: false) {
                ForEach(receipts.filter({ userSearch.count > 0 ?
                                            $0.body!.localizedCaseInsensitiveContains(userSearch) ||
                                            $0.folder!.localizedCaseInsensitiveContains(userSearch)  ||
                                            $0.store!.localizedCaseInsensitiveContains(userSearch) :
                                            $0.body!.count > 0 })){ receipt in
                    ReceiptView(receipt: receipt).transition(.opacity)
                }
            }.cornerRadius(18).padding(.horizontal)
            Spacer()
        }.padding(.bottom, 10)
        .onChange(of: userSearch, perform: { search in
            withAnimation(.spring()){
                dashPanelState = search != "" ? .expanded : .homepage
            }
        })
    }
}

/// Generic Search bar that returns the search term and filter booleans
struct SearchBar: View {
    /// String holding the users current search input
    @Binding var userSearch: String
    /// Toggles whether the filters drop down menu is showing
    @State var showingFilters: Bool = false
    /// Placeholder for a filtered search setting
    @Binding var warrenty: Bool
    /// Placeholder for a filtered search setting
    @Binding var favorites: Bool
    
    var body: some View {
        let folderExists = folderDoesExist()
        VStack {
            HStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(getColor(title: userSearch)))
                    .frame(height: UIScreen.screenHeight*0.05).frame(minWidth: 0, maxWidth: .infinity)
                    .overlay(
                        HStack {
                            Image(systemName: folderExists ? Folder.getIcon(title: userSearch) : "magnifyingglass")
                            CustomTextField(placeholder: Text("Search..."), text: $userSearch)
                                .ignoresSafeArea(.keyboard)
                            Spacer()
                            if userSearch != "" {
                                Button(action: {
                                    userSearch = ""
                                }){
                                    Image(systemName: "xmark")
                                        .font(.system(size: 19, weight: .bold, design: .rounded))
                                }
                            }
                        }.foregroundColor(Color(textColor(title: userSearch)))
                        .font(
                            .system(size: 20,
                                    weight: folderExists ? .bold : .regular,
                                    design: .rounded))
                        .padding(.horizontal, 10)
                )
                Button(action: {
                    showingFilters = showingFilters ? false : true
                }){
                    Image(systemName: "slider.horizontal.3")
                        .font(.title)
                        .foregroundColor(Color("text"))
                }.buttonStyle(ShrinkingButton())
            }.padding(.bottom, 1)
            
            if showingFilters {
                VStack {
                    Group {
                        Toggle(" ", isOn: $warrenty)
                    }.foregroundColor(.black).font(.system(.body, design: .rounded))
                }.padding(.horizontal, 5)
            }
        }
    }
    
    func getColor(title: String) -> String {
        if folderDoesExist() {
            return Folder.getColor(title: title)
        } else {
            return "accent"
        }
    }
    
    func textColor(title: String) -> String {
        if folderDoesExist() {
            return "background"
        } else {
            return "text"
        }
    }
    func folderDoesExist() -> Bool {
        return Folder.folderExists(title: userSearch)
    }
}
