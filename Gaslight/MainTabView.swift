//
//  MainTabView.swift
//  Gaslight
//
//  Created by Albert Xu on 7/30/25.
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    @StateObject private var settings = GaslightSettings()
    @Environment(\.modelContext) private var modelContext
    @Query private var entries: [JournalEntry]
    @State private var selectedTab = 0
    // Settings now handled as a dedicated tab
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                    Text("Home")
                }
                .tag(0)
            
            NewEntriesListView()
                .tabItem {
                    Image(systemName: selectedTab == 1 ? "book.fill" : "book")
                    Text("History")
                }
                .tag(1)
            
            ContentView()
                .tabItem {
                    Image(systemName: selectedTab == 2 ? "plus.circle.fill" : "plus.circle")
                    Text("New Entry")
                }
                .tag(2)
            
            CalendarView()
                .tabItem {
                    Image(systemName: selectedTab == 3 ? "calendar.circle.fill" : "calendar")
                    Text("Calendar")
                }
                .tag(3)
            
            NavigationView {
                SettingsView()
                    .environmentObject(settings)
            }
                .tabItem {
                    Image(systemName: selectedTab == 4 ? "gearshape.fill" : "gearshape")
                    Text("Settings")
                }
                .tag(4)
        }
        .preferredColorScheme(settings.colorScheme)
        .onChange(of: selectedTab) { _, newValue in
            // Add haptic feedback on tab switch
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShowSettings"))) { _ in
            selectedTab = 4 // Navigate to Settings tab instead of showing sheet
        }
    }
    
}