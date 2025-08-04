//
//  MainTabView.swift
//  Gaslight
//
//  Created by Albert Xu on 7/30/25.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var settings = GaslightSettings()
    
    var body: some View {
        TabView {
            ContentView()
                .tabItem {
                    Image(systemName: "square.and.pencil")
                    Text("Write")
                }
            
            NewEntriesListView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Entries")
                }
            
            CalendarView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Calendar")
                }
            
            SettingsView()
                .environmentObject(settings)
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
        .preferredColorScheme(settings.colorScheme)
    }
}