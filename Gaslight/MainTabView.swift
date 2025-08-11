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
    @State private var showingSettings = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                    Text("Home")
                }
                .tag(0)
            
            ContentView()
                .tabItem {
                    Image(systemName: selectedTab == 1 ? "plus.circle.fill" : "plus.circle")
                    Text("New Entry")
                }
                .tag(1)
            
            NewEntriesListView()
                .tabItem {
                    Image(systemName: selectedTab == 2 ? "book.fill" : "book")
                    Text("Journal")
                }
                .tag(2)
            
            CalendarView()
                .tabItem {
                    Image(systemName: selectedTab == 3 ? "calendar.circle.fill" : "calendar")
                    Text("Calendar")
                }
                .tag(3)
        }
        .preferredColorScheme(settings.colorScheme)
        .onChange(of: selectedTab) { _, newValue in
            // Add haptic feedback on tab switch
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
        }
        .sheet(isPresented: $showingSettings) {
            NavigationView {
                SettingsView()
                    .environmentObject(settings)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                showingSettings = false
                            }
                            .fontWeight(.semibold)
                        }
                    }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShowSettings"))) { _ in
            showingSettings = true
        }
    }
    
}