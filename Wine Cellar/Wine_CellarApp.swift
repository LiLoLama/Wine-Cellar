//
//  Wine_CellarApp.swift
//  Wine Cellar
//
//  Entry point for the Caveo mock experience.
//

import SwiftUI

@main
struct Wine_CellarApp: App {
    @StateObject private var store = MockDataStore()
    @StateObject private var themeManager = ThemeManager()

    init() {
        FontRegistrar.registerFonts()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .environmentObject(themeManager)
                .background(Color("Background"))
        }
    }
}
