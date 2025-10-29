//
//  ContentView.swift
//  Wine Cellar
//
//  Root tab view for the Caveo mock application.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        TabView {
            NavigationStack {
                CellarListView()
            }
            .tabItem {
                Label("Keller", systemImage: "wineglass")
            }

            NavigationStack {
                AddHomeView()
            }
            .tabItem {
                Label("Hinzufügen", systemImage: "plus.circle")
            }

            NavigationStack {
                OpenListView()
            }
            .tabItem {
                Label("Offen", systemImage: "drop.triangle")
            }

            NavigationStack {
                InsightsHomeView()
            }
            .tabItem {
                Label("Insights", systemImage: "chart.bar.xaxis")
            }

            NavigationStack {
                ProfileHomeView()
            }
            .tabItem {
                Label("Profil", systemImage: "person")
            }
        }
        .tint(Color("Accent"))
        .preferredColorScheme(themeManager.theme.colorScheme)
    }
}

#Preview {
    ContentView()
        .environmentObject(MockDataStore())
        .environmentObject(ThemeManager())
}
