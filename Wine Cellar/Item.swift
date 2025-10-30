//
//  MockModels.swift
//  Wine Cellar
//
//  Created for Caveo mock experience.
//

import Foundation
import SwiftUI

struct MockDataContainer: Codable {
    let wines: [Wine]
    let openBottles: [OpenBottle]
    let ratings: [Rating]
}

enum WineStyle: String, Codable, CaseIterable, Identifiable {
    case red
    case white
    case rose
    case sparkling
    case sweet
    case orange
    case fortified

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .red: return "Rot"
        case .white: return "Weiß"
        case .rose: return "Rosé"
        case .sparkling: return "Sparkling"
        case .sweet: return "Süß"
        case .orange: return "Orange"
        case .fortified: return "Fortified"
        }
    }

    var icon: String {
        switch self {
        case .red: return "wineglass"
        case .white: return "sun.max"
        case .rose: return "drop"
        case .sparkling: return "sparkles"
        case .sweet: return "leaf"
        case .orange: return "circle.dashed"
        case .fortified: return "flame"
        }
    }

    var toneColor: Color {
        switch self {
        case .red: return Color("Accent")
        case .white: return Color("SecondaryAccent")
        case .rose: return Color.pink.opacity(0.6)
        case .sparkling: return Color.yellow.opacity(0.7)
        case .sweet: return Color.orange.opacity(0.7)
        case .orange: return Color.orange
        case .fortified: return Color("PrimaryText").opacity(0.7)
        }
    }
}

struct DrinkWindow: Codable, Hashable {
    let from: Int?
    let to: Int?

    var label: String {
        switch (from, to) {
        case let (from?, to?):
            return "\(from)–\(to)"
        case (nil, let to?):
            return "bis \(to)"
        case (let from?, nil):
            return "ab \(from)"
        default:
            return "—"
        }
    }
}

struct WinePrice: Codable, Hashable {
    let amount: Double
    let currency: String

    var formatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        return formatter.string(from: amount as NSNumber) ?? String(format: "%.2f %@", amount, currency)
    }
}

struct Wine: Identifiable, Codable, Hashable {
    let id: String
    let producer: String
    let name: String
    let vintage: Int?
    let style: WineStyle
    let region: String
    let appellation: String
    let country: String
    let grapes: [String]
    let abv: Double?
    let drinkWindow: DrinkWindow
    let locations: [String]
    let quantity: Int
    let price: WinePrice?

    var displayTitle: String {
        "\(producer) \n\(name)"
    }

    var titleLine: String {
        "\(producer) \n\(name)"
    }

    var subtitleLine: String {
        let vintageText = vintage.map(String.init) ?? "NV"
        return "\(vintageText) • \(region) • \(appellation)"
    }

    var locationSummary: String {
        locations.joined(separator: ", ")
    }

    var styleLabel: String { style.displayName }

    var trinkreifeBadge: BadgeInfo {
        guard let currentYear = Calendar.current.dateComponents([.year], from: Date()).year else {
            return BadgeInfo(text: "trinkreif", tone: .success)
        }
        if let from = drinkWindow.from, currentYear < from {
            return BadgeInfo(text: "zu jung", tone: .caution)
        }
        if let to = drinkWindow.to, currentYear > to {
            return BadgeInfo(text: "auslaufend", tone: .warning)
        }
        return BadgeInfo(text: "trinkreif", tone: .success)
    }
}

struct OpenBottle: Identifiable, Codable {
    var id: String { wineId }
    let wineId: String
    let openedAt: String
    let preservation: PreservationMethod
    let daysOpen: Int

    var badgeText: String {
        "seit \(daysOpen) Tagen"
    }
}

enum PreservationMethod: String, Codable, CaseIterable, Identifiable {
    case cork
    case vacuum
    case argon

    var id: Self { self }

    var label: String {
        switch self {
        case .cork: return "Korken"
        case .vacuum: return "Vakuum"
        case .argon: return "Argon"
        }
    }

    var icon: String {
        switch self {
        case .cork: return "seal"
        case .vacuum: return "drop.triangle"
        case .argon: return "cloud.fog"
        }
    }
}

struct Rating: Identifiable, Codable {
    var id: String { "\(wineId)-\(date)" }
    let wineId: String
    let date: String
    let stars: Double
    let notes: String
}

final class MockDataStore: ObservableObject {
    @Published private(set) var wines: [Wine] = []
    @Published private(set) var openBottles: [OpenBottle] = []
    @Published private(set) var ratings: [Rating] = []

    init() {
        load()
    }

    func load() {
        guard let url = Bundle.main.url(forResource: "mockData", withExtension: "json") else {
            debugPrint("mockData.json not found in bundle")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let result = try decoder.decode(MockDataContainer.self, from: data)
            wines = result.wines
            openBottles = result.openBottles
            ratings = result.ratings
        } catch {
            debugPrint("Failed to decode mock data: \(error)")
        }
    }

    func wine(for id: String) -> Wine? {
        wines.first(where: { $0.id == id })
    }

    func ratings(for wine: Wine) -> [Rating] {
        ratings.filter { $0.wineId == wine.id }
    }

    func openBottle(for wine: Wine) -> OpenBottle? {
        openBottles.first { $0.wineId == wine.id }
    }
}

struct BadgeInfo: Identifiable {
    enum Tone {
        case success
        case caution
        case warning
        case neutral

        var background: Color {
            switch self {
            case .success: return Color("SecondaryAccent").opacity(0.2)
            case .caution: return Color.orange.opacity(0.2)
            case .warning: return Color("Accent").opacity(0.18)
            case .neutral: return Color("Muted")
            }
        }

        var text: Color {
            switch self {
            case .success: return Color("SecondaryAccent")
            case .caution: return Color.orange
            case .warning: return Color("Accent")
            case .neutral: return Color("SecondaryText")
            }
        }
    }

    let text: String
    let tone: Tone

    var id: String { text }
}
