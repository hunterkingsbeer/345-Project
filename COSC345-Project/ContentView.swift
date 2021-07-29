//
//  ContentView.swift
//  COSC345-Project
//
//  Created by Hunter Kingsbeer on 7/05/21.
//

import SwiftUI
import CoreData


// -------------------------------------------------------------------------- PREVIEW
/// ContentView_Previews is what xCode uses to preview the app in the IDE.
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(UserSettings())
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

// -------------------------------------------------------------------------- VIEWS

/// AddPanelType holds the various states for the Add panel.
enum AddPanelType {
    /// Displays the standard homepage view for the add panel. Two option, add from gallery or camera.
    case homepage
    /// Displays the panel's add from camera view
    case camera
    /// Displays the panel's add from gallery view
    case gallery
}

/// DashPanelType holds the various states for the dashboard panel.
enum DashPanelType {
    /// Displays the standard homepage view for the Dashpanel. Showing the Receipts, folders, settings and notifcations.
    case homepage
    /// Displays the
    case expanded
    /// Displays the settings view
    case settings
}

/// ContentView is the main content view that is called when starting the app.
struct ContentView: View {
    /// AddPanelType maintains and updates the add panels view state.
    @State var addPanelState: AddPanelType = .homepage // need to make these global vars
    /// DashPanelState maintains and updates the dashboards view state.
    @State var dashPanelState: DashPanelType = .homepage
    /// Settings imports the UserSettings
    @EnvironmentObject var settings : UserSettings

    var body: some View {
        ZStack(alignment: .top) {
            // BACKGROUND BLOBS ------------------
            BackgroundView(addPanelState: addPanelState,
                           dashPanelState: dashPanelState)
            
            // COMPANY TITLE ------------------
            VStack {
                // DASHBOARD (UPPER) ------------------
                if addPanelState == .homepage {
                    DashboardPanelParent(dashPanelState: $dashPanelState)
                        .padding(.bottom, dashPanelState != .expanded ? 12 : 0)
                        .transition(AnyTransition.opacity
                                        .combined(with: .scale(scale: 0.75)))
                        
                }
                
                // ADD RECEIPT (LOWER) ------------------
                if dashPanelState != .expanded {
                    AddPanelParent(addPanelState: $addPanelState)
                        .transition(AnyTransition.opacity.combined(with: .scale(scale: 0.75)))
                        .animation(.spring())
                    Spacer()
                }
            }.ignoresSafeArea(.keyboard) // broken code, find fix
            .padding(.horizontal, addPanelState == .homepage ? 15 : 0)
        }.colorScheme(settings.darkMode ? .dark : .light)
    }
}

/// Background view is the background of the application
/// - Main Parent: ContentView
struct BackgroundView: View {
    /// AddPanelType maintains and updates the add panels view state.
    var addPanelState: AddPanelType
    /// DashPanelState maintains and updates the dashboards view state.
    var dashPanelState: DashPanelType
    /// Settings imports the UserSettings
    @EnvironmentObject var settings: UserSettings
    @State var colors = Color.getColors()
    
    var body: some View {
        ZStack {
            Color(settings.contrast ? "backgroundContrast" : "background").ignoresSafeArea(.all)
            if !settings.minimal {
                VStack {
                    Circle()
                        .fill(LinearGradient(gradient: Gradient(colors: [colors[settings.style].top1, colors[settings.style].top2]), startPoint: .top, endPoint: .bottom))
                        .scaleEffect(x: 1.5) // gives it that clean stretched out look
                        .padding(.top, -UIScreen.screenHeight * 0.55)
                        //.padding(.top, -UIScreen.screenHeight * (dashPanelState != .expanded ? 0.5 : 0.38))
                        .animation(.spring())
                    Spacer()
                    Circle()
                        .fill(LinearGradient(gradient: Gradient(colors: [colors[settings.style].bottom1, colors[settings.style].bottom2]), startPoint: .top, endPoint: .bottom))
                        .scaleEffect(x: 1.5)
                        .padding(.bottom, -UIScreen.screenHeight * (addPanelState == .homepage ? 0.6 : 0.38))
                        .animation(.spring())
                }
            }
        }.animation(.easeInOut)
    }
}
