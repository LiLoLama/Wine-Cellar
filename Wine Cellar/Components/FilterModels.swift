import Foundation
import SwiftUI

// MARK: - Quick Filters

enum QuickFilterCategory: String, CaseIterable, Identifiable {
    case style
    case status
    case drinkReadiness
    case rating
    case vintage
    case price
    case location

    var id: Self { self }

    var title: String {
        switch self {
        case .style: return "Stil"
        case .status: return "Status"
        case .drinkReadiness: return "Trinkreife"
        case .rating: return "Bewertung"
        case .vintage: return "Jahrgang"
        case .price: return "Preis"
        case .location: return "Lagerort"
        }
    }
}

// MARK: - Sorting

enum CellarSortOption: String, CaseIterable, Identifiable {
    case recentlyAdded
    case drinkWindowSoonest
    case ratingHighToLow
    case priceAscending
    case priceDescending
    case vintageNewest
    case vintageOldest
    case quantityHighToLow
    case quantityLowToHigh

    var id: Self { self }

    var label: String {
        switch self {
        case .recentlyAdded: return "Zuletzt hinzugefügt"
        case .drinkWindowSoonest: return "Trinkfenster"
        case .ratingHighToLow: return "Bewertung"
        case .priceAscending: return "Preis ↑"
        case .priceDescending: return "Preis ↓"
        case .vintageNewest: return "Jahrgang neu"
        case .vintageOldest: return "Jahrgang alt"
        case .quantityHighToLow: return "Menge hoch"
        case .quantityLowToHigh: return "Menge niedrig"
        }
    }
}

enum WineInventoryStatus: String, CaseIterable, Identifiable {
    case inStock
    case open
    case depleted

    var id: Self { self }

    var label: String {
        switch self {
        case .inStock: return "Lagernd"
        case .open: return "Offen"
        case .depleted: return "Ausgetrunken"
        }
    }
}

enum DrinkReadinessOption: String, CaseIterable, Identifiable {
    case tooYoung
    case optimal
    case closing
    case pastPeak

    var id: Self { self }

    var label: String {
        switch self {
        case .tooYoung: return "Zu jung"
        case .optimal: return "Trinkreif"
        case .closing: return "Läuft aus"
        case .pastPeak: return "Über dem Zenit"
        }
    }
}

enum RatingQuickFilter: String, CaseIterable, Identifiable {
    case minimumFour
    case minimumFourPointFive
    case unrated

    var id: Self { self }

    var label: String {
        switch self {
        case .minimumFour: return "≥4★"
        case .minimumFourPointFive: return "≥4.5★"
        case .unrated: return "Unbewertet"
        }
    }
}

enum VintageBucket: String, CaseIterable, Identifiable {
    case nonVintage
    case from2015To2018
    case from2019To2021
    case from2022On

    var id: Self { self }

    var label: String {
        switch self {
        case .nonVintage: return "NV"
        case .from2015To2018: return "2015–2018"
        case .from2019To2021: return "2019–2021"
        case .from2022On: return "2022+"
        }
    }
}

enum PriceBucket: String, CaseIterable, Identifiable {
    case upToTwenty
    case twentyToFifty
    case fiftyToOneHundred
    case aboveOneHundred

    var id: Self { self }

    var label: String {
        switch self {
        case .upToTwenty: return "≤20€"
        case .twentyToFifty: return "20–50€"
        case .fiftyToOneHundred: return "50–100€"
        case .aboveOneHundred: return ">100€"
        }
    }
}

enum QuickFilterOption: Hashable, Identifiable {
    case style(WineStyle)
    case status(WineInventoryStatus)
    case readiness(DrinkReadinessOption)
    case rating(RatingQuickFilter)
    case vintage(VintageBucket)
    case price(PriceBucket)
    case location(String)

    var id: String {
        switch self {
        case .style(let style): return "style-\(style.rawValue)"
        case .status(let status): return "status-\(status.rawValue)"
        case .readiness(let readiness): return "readiness-\(readiness.rawValue)"
        case .rating(let rating): return "rating-\(rating.rawValue)"
        case .vintage(let bucket): return "vintage-\(bucket.rawValue)"
        case .price(let bucket): return "price-\(bucket.rawValue)"
        case .location(let location): return "location-\(location)"
        }
    }

    var label: String {
        switch self {
        case .style(let style):
            return style.displayName
        case .status(let status):
            return status.label
        case .readiness(let readiness):
            return readiness.label
        case .rating(let rating):
            return rating.label
        case .vintage(let bucket):
            return bucket.label
        case .price(let bucket):
            return bucket.label
        case .location(let location):
            return location
        }
    }

    var icon: String? {
        switch self {
        case .style(let style):
            return style.icon
        case .status(let status):
            switch status {
            case .inStock: return "shippingbox"
            case .open: return "wineglass"
            case .depleted: return "xmark.bin"
            }
        case .readiness(let readiness):
            switch readiness {
            case .tooYoung: return "hourglass"
            case .optimal: return "checkmark.circle"
            case .closing: return "exclamationmark.triangle"
            case .pastPeak: return "exclamationmark.octagon"
            }
        case .rating(let rating):
            switch rating {
            case .minimumFour, .minimumFourPointFive: return "star"
            case .unrated: return "questionmark"
            }
        case .vintage:
            return "calendar"
        case .price:
            return "eurosign"
        case .location:
            return "tray"
        }
    }

    var category: QuickFilterCategory {
        switch self {
        case .style: return .style
        case .status: return .status
        case .readiness: return .drinkReadiness
        case .rating: return .rating
        case .vintage: return .vintage
        case .price: return .price
        case .location: return .location
        }
    }
}

struct QuickFilterGroup: Identifiable {
    let category: QuickFilterCategory
    let options: [QuickFilterOption]

    var id: QuickFilterCategory { category }

    var title: String { category.title }

    static func makeGroups(store: MockDataStore) -> [QuickFilterGroup] {
        var groups: [QuickFilterGroup] = []

        groups.append(
            QuickFilterGroup(category: .style, options: WineStyle.allCases.map { .style($0) })
        )

        groups.append(
            QuickFilterGroup(category: .status, options: WineInventoryStatus.allCases.map { .status($0) })
        )

        groups.append(
            QuickFilterGroup(category: .drinkReadiness, options: DrinkReadinessOption.allCases.map { .readiness($0) })
        )

        groups.append(
            QuickFilterGroup(category: .rating, options: RatingQuickFilter.allCases.map { .rating($0) })
        )

        groups.append(
            QuickFilterGroup(category: .vintage, options: VintageBucket.allCases.map { .vintage($0) })
        )

        groups.append(
            QuickFilterGroup(category: .price, options: PriceBucket.allCases.map { .price($0) })
        )

        let existingLocations = Set(store.wines.flatMap { $0.locations })
            .sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
        if !existingLocations.isEmpty {
            groups.append(
                QuickFilterGroup(category: .location, options: existingLocations.map { .location($0) })
            )
        }

        return groups
    }
}

// MARK: - Advanced Filters

enum DrinkWindowRelativeOption: String, CaseIterable, Identifiable {
    case readyWithinSixMonths
    case endingWithinTwelveMonths

    var id: Self { self }

    var label: String {
        switch self {
        case .readyWithinSixMonths: return "in ≤6 Monaten trinkreif"
        case .endingWithinTwelveMonths: return "läuft in ≤12 Monaten aus"
        }
    }
}

enum QuantityComparator: String, CaseIterable, Identifiable {
    case atLeast
    case equal
    case atMost

    var id: Self { self }

    var label: String {
        switch self {
        case .atLeast: return "≥"
        case .equal: return "="
        case .atMost: return "≤"
        }
    }
}

enum BottleClosure: String, CaseIterable, Identifiable {
    case cork
    case screwcap
    case other

    var id: Self { self }

    var label: String {
        switch self {
        case .cork: return "Kork"
        case .screwcap: return "Schraubverschluss"
        case .other: return "Sonstige"
        }
    }
}

enum ServingHint: String, CaseIterable, Identifiable {
    case decant
    case servingTemperature

    var id: Self { self }

    var label: String {
        switch self {
        case .decant: return "Dekantieren"
        case .servingTemperature: return "Serviertemperatur vorhanden"
        }
    }
}

struct QuantityFilter: Hashable {
    var comparator: QuantityComparator
    var value: Int

    func matches(_ quantity: Int) -> Bool {
        switch comparator {
        case .atLeast: return quantity >= value
        case .equal: return quantity == value
        case .atMost: return quantity <= value
        }
    }
}

enum DataCompletenessFlag: String, CaseIterable, Identifiable {
    case missingAppellation
    case missingGrapes
    case missingLocation

    var id: Self { self }

    var label: String {
        switch self {
        case .missingAppellation: return "fehlende Appellation"
        case .missingGrapes: return "fehlende Rebsorte"
        case .missingLocation: return "fehlender Lagerort"
        }
    }
}

enum SmartFilterPreset: String, CaseIterable, Identifiable {
    case drinkReadyToday
    case expiringSoon
    case restockFavorites
    case unrated
    case missingMetadata
    case openBottleWarning

    var id: Self { self }

    var label: String {
        switch self {
        case .drinkReadyToday: return "Trinkreif heute"
        case .expiringSoon: return "Bald fällig"
        case .restockFavorites: return "Nachkaufen"
        case .unrated: return "Unbewertet"
        case .missingMetadata: return "Fehlende Metadaten"
        case .openBottleWarning: return "Offene Flaschen – kritisch"
        }
    }
}

enum OpenBottleFreshnessStatus: String, CaseIterable, Identifiable {
    case withinRecommendation
    case warningExceeded

    var id: Self { self }

    var label: String {
        switch self {
        case .withinRecommendation: return "innerhalb Empfehlung"
        case .warningExceeded: return "Warnung überschritten"
        }
    }
}

struct AdvancedFilterState: Hashable {
    var producers: Set<String> = []
    var wineNameQuery: String = ""
    var styles: Set<WineStyle> = []
    var grapes: Set<String> = []
    var includeNV: Bool = true
    var vintageRange: ClosedRange<Int>?
    var abvRange: ClosedRange<Double>?
    var drinkWindowRange: ClosedRange<Int>?
    var relativeDrinkWindow: DrinkWindowRelativeOption?
    var closures: Set<BottleClosure> = []
    var bottleSizes: Set<Int> = []
    var countries: Set<String> = []
    var regions: Set<String> = []
    var appellations: Set<String> = []
    var qualityLevels: Set<String> = []
    var vineyardSites: Set<String> = []
    var servingHints: Set<ServingHint> = []
    var quantityFilter: QuantityFilter?
    var storageLocations: Set<String> = []
    var priceRange: ClosedRange<Double>?
    var minRating: Double?
    var isRated: Bool?
    var lastTastedRange: ClosedRange<Date>?
    var hasNotes: Bool? = nil
    var openDaysRange: ClosedRange<Int>?
    var preservationMethods: Set<PreservationMethod> = []
    var freshnessStatuses: Set<OpenBottleFreshnessStatus> = []
    var tags: Set<String> = []
    var completenessFlags: Set<DataCompletenessFlag> = []
    var smartPreset: SmartFilterPreset?

    var activeFilterCount: Int {
        var count = 0
        count += producers.isEmpty ? 0 : 1
        count += wineNameQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0 : 1
        count += styles.isEmpty ? 0 : 1
        count += grapes.isEmpty ? 0 : 1
        count += (includeNV ? 0 : 1)
        count += vintageRange == nil ? 0 : 1
        count += abvRange == nil ? 0 : 1
        count += drinkWindowRange == nil ? 0 : 1
        count += relativeDrinkWindow == nil ? 0 : 1
        count += closures.isEmpty ? 0 : 1
        count += bottleSizes.isEmpty ? 0 : 1
        count += countries.isEmpty ? 0 : 1
        count += regions.isEmpty ? 0 : 1
        count += appellations.isEmpty ? 0 : 1
        count += qualityLevels.isEmpty ? 0 : 1
        count += vineyardSites.isEmpty ? 0 : 1
        count += servingHints.isEmpty ? 0 : 1
        count += quantityFilter == nil ? 0 : 1
        count += storageLocations.isEmpty ? 0 : 1
        count += priceRange == nil ? 0 : 1
        count += minRating == nil ? 0 : 1
        count += isRated == nil ? 0 : 1
        count += lastTastedRange == nil ? 0 : 1
        count += hasNotes == nil ? 0 : 1
        count += openDaysRange == nil ? 0 : 1
        count += preservationMethods.isEmpty ? 0 : 1
        count += freshnessStatuses.isEmpty ? 0 : 1
        count += tags.isEmpty ? 0 : 1
        count += completenessFlags.isEmpty ? 0 : 1
        count += smartPreset == nil ? 0 : 1
        return count
    }

    mutating func reset() {
        self = AdvancedFilterState()
    }
}

// MARK: - Master Filter State

struct CellarFilterState {
    var selectedQuickFilters: Set<QuickFilterOption> = []
    var advancedFilters: AdvancedFilterState = AdvancedFilterState()

    var activeFilterCount: Int {
        selectedQuickFilters.count + advancedFilters.activeFilterCount
    }

    mutating func toggle(option: QuickFilterOption) {
        if selectedQuickFilters.contains(option) {
            selectedQuickFilters.remove(option)
        } else {
            selectedQuickFilters.insert(option)
        }
    }

    func filteredWines(from store: MockDataStore, searchText: String) -> [Wine] {
        store.wines.filter { wine in
            matchesSearch(wine: wine, searchText: searchText) &&
            matchesQuickFilters(wine: wine, store: store) &&
            matchesAdvancedFilters(wine: wine, store: store)
        }
    }

    private func matchesSearch(wine: Wine, searchText: String) -> Bool {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return true }
        let query = trimmed.lowercased()
        let haystack: [String] = [
            wine.producer,
            wine.name,
            wine.subtitleLine,
            wine.region,
            wine.appellation,
            wine.country
        ] + wine.grapes + wine.locations
        return haystack.contains { $0.lowercased().contains(query) }
    }

    private func matchesQuickFilters(wine: Wine, store: MockDataStore) -> Bool {
        guard !selectedQuickFilters.isEmpty else { return true }

        let grouped = Dictionary(grouping: selectedQuickFilters, by: { $0.category })

        for (category, options) in grouped {
            guard options.isEmpty == false else { continue }
            let matchesCategory: Bool
            switch category {
            case .style:
                matchesCategory = options.contains { option in
                    if case let .style(style) = option { return wine.style == style }
                    return false
                }
            case .status:
                let statuses = wineStatuses(for: wine, store: store)
                matchesCategory = options.contains { option in
                    if case let .status(status) = option { return statuses.contains(status) }
                    return false
                }
            case .drinkReadiness:
                let readiness = drinkReadiness(for: wine)
                matchesCategory = options.contains { option in
                    if case let .readiness(value) = option { return readiness == value }
                    return false
                }
            case .rating:
                let averageRating = averageRating(for: wine, store: store)
                matchesCategory = options.contains { option in
                    guard case let .rating(filter) = option else { return false }
                    switch filter {
                    case .minimumFour:
                        guard let rating = averageRating else { return false }
                        return rating >= 4
                    case .minimumFourPointFive:
                        guard let rating = averageRating else { return false }
                        return rating >= 4.5
                    case .unrated:
                        return averageRating == nil
                    }
                }
            case .vintage:
                matchesCategory = options.contains { option in
                    guard case let .vintage(bucket) = option else { return false }
                    return bucket.contains(vintage: wine.vintage)
                }
            case .price:
                matchesCategory = options.contains { option in
                    guard case let .price(bucket) = option else { return false }
                    return bucket.contains(price: wine.price)
                }
            case .location:
                matchesCategory = options.contains { option in
                    guard case let .location(location) = option else { return false }
                    return wine.locations.contains(where: { $0 == location })
                }
            }

            if matchesCategory == false {
                return false
            }
        }

        return true
    }

    private func matchesAdvancedFilters(wine: Wine, store: MockDataStore) -> Bool {
        let filters = advancedFilters

        if !filters.producers.isEmpty && filters.producers.contains(where: { $0 == wine.producer }) == false {
            return false
        }

        let trimmedNameQuery = filters.wineNameQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedNameQuery.isEmpty == false {
            let query = trimmedNameQuery.lowercased()
            let matches = wine.name.lowercased().contains(query) || wine.producer.lowercased().contains(query)
            if matches == false {
                return false
            }
        }

        if filters.styles.isEmpty == false && filters.styles.contains(wine.style) == false {
            return false
        }

        if filters.grapes.isEmpty == false {
            let normalizedGrapes = Set(wine.grapes.map { $0.lowercased() })
            let matchesGrape = filters.grapes.contains { grape in
                normalizedGrapes.contains(grape.lowercased()) ||
                GrapeSynonyms.matches(grape: grape, with: normalizedGrapes)
            }
            if matchesGrape == false {
                return false
            }
        }

        if filters.includeNV == false && wine.vintage == nil {
            return false
        }

        if let range = filters.vintageRange {
            guard let vintage = wine.vintage, range.contains(vintage) else { return false }
        }

        if let range = filters.abvRange {
            guard let abv = wine.abv, range.contains(abv) else { return false }
        }

        if let windowRange = filters.drinkWindowRange {
            let from = wine.drinkWindow.from ?? Int.min
            let to = wine.drinkWindow.to ?? Int.max
            let match = windowRange.overlaps(from...to)
            if match == false {
                return false
            }
        }

        if let relative = filters.relativeDrinkWindow {
            guard let currentYear = Calendar.current.dateComponents([.year], from: Date()).year else { return false }
            switch relative {
            case .readyWithinSixMonths:
                if let from = wine.drinkWindow.from {
                    if from - currentYear > 1 { return false }
                }
            case .endingWithinTwelveMonths:
                if let to = wine.drinkWindow.to {
                    if to - currentYear > 1 { return false }
                } else {
                    return false
                }
            }
        }

        if filters.closures.isEmpty == false {
            guard let closure = wine.closure, filters.closures.contains(closure) else { return false }
        }

        if filters.bottleSizes.isEmpty == false {
            guard let size = wine.bottleSizeInMl, filters.bottleSizes.contains(size) else { return false }
        }

        if filters.countries.isEmpty == false && filters.countries.contains(wine.country) == false {
            return false
        }

        if filters.regions.isEmpty == false && filters.regions.contains(wine.region) == false {
            return false
        }

        if filters.appellations.isEmpty == false && filters.appellations.contains(wine.appellation) == false {
            return false
        }

        if filters.storageLocations.isEmpty == false {
            let matchesLocation = filters.storageLocations.contains { location in
                wine.locations.contains(location)
            }
            if matchesLocation == false {
                return false
            }
        }

        if filters.servingHints.isEmpty == false {
            let hints = wine.servingHints
            if filters.servingHints.isDisjoint(with: hints) {
                return false
            }
        }

        if let quantityFilter = filters.quantityFilter {
            if quantityFilter.matches(wine.quantity) == false {
                return false
            }
        }

        if let priceRange = filters.priceRange {
            guard let amount = wine.price?.amount, priceRange.contains(amount) else { return false }
        }

        if let minRating = filters.minRating {
            guard let rating = averageRating(for: wine, store: store), rating >= minRating else { return false }
        }

        if let isRated = filters.isRated {
            let hasRating = averageRating(for: wine, store: store) != nil
            if hasRating != isRated { return false }
        }

        if let tastingRange = filters.lastTastedRange {
            guard let lastTasted = store.lastTastingDate(for: wine), tastingRange.contains(lastTasted) else { return false }
        }

        if let hasNotes = filters.hasNotes {
            let noteExists = store.hasNotes(for: wine)
            if noteExists != hasNotes { return false }
        }

        if let openDaysRange = filters.openDaysRange {
            guard let openBottle = store.openBottle(for: wine), openDaysRange.contains(openBottle.daysOpen) else { return false }
        }

        if filters.preservationMethods.isEmpty == false {
            guard let method = store.openBottle(for: wine)?.preservation, filters.preservationMethods.contains(method) else { return false }
        }

        if filters.freshnessStatuses.isEmpty == false {
            guard let status = freshnessStatus(for: wine, store: store), filters.freshnessStatuses.contains(status) else { return false }
        }

        if filters.tags.isEmpty == false {
            let wineTags = wine.tags
            if filters.tags.isDisjoint(with: wineTags) {
                return false
            }
        }

        if filters.completenessFlags.isEmpty == false {
            let missingFlags = dataCompletenessFlags(for: wine)
            let matches = filters.completenessFlags.allSatisfy { missingFlags.contains($0) }
            if matches == false {
                return false
            }
        }

        if let preset = filters.smartPreset {
            if matches(preset: preset, wine: wine, store: store) == false {
                return false
            }
        }

        return true
    }

    private func wineStatuses(for wine: Wine, store: MockDataStore) -> Set<WineInventoryStatus> {
        var statuses: Set<WineInventoryStatus> = []
        if wine.quantity > 0 {
            statuses.insert(.inStock)
        } else {
            statuses.insert(.depleted)
        }
        if store.openBottle(for: wine) != nil {
            statuses.insert(.open)
        }
        return statuses
    }

    private func drinkReadiness(for wine: Wine) -> DrinkReadinessOption {
        guard let currentYear = Calendar.current.dateComponents([.year], from: Date()).year else {
            return .optimal
        }

        if let from = wine.drinkWindow.from, currentYear < from {
            return .tooYoung
        }

        if let to = wine.drinkWindow.to {
            if currentYear > to {
                return .pastPeak
            }
            if currentYear == to {
                return .closing
            }
        }

        return .optimal
    }

    private func averageRating(for wine: Wine, store: MockDataStore) -> Double? {
        let ratings = store.ratings(for: wine)
        guard ratings.isEmpty == false else { return nil }
        let total = ratings.reduce(0.0) { $0 + $1.stars }
        return total / Double(ratings.count)
    }

    private func freshnessStatus(for wine: Wine, store: MockDataStore) -> OpenBottleFreshnessStatus? {
        guard let bottle = store.openBottle(for: wine) else { return nil }
        if bottle.daysOpen <= 3 {
            return .withinRecommendation
        } else {
            return .warningExceeded
        }
    }

    private func dataCompletenessFlags(for wine: Wine) -> Set<DataCompletenessFlag> {
        var flags: Set<DataCompletenessFlag> = []
        if wine.appellation.isEmpty {
            flags.insert(.missingAppellation)
        }
        if wine.grapes.isEmpty {
            flags.insert(.missingGrapes)
        }
        if wine.locations.isEmpty {
            flags.insert(.missingLocation)
        }
        return flags
    }

    private func matches(preset: SmartFilterPreset, wine: Wine, store: MockDataStore) -> Bool {
        guard let currentYear = Calendar.current.dateComponents([.year], from: Date()).year else { return true }
        switch preset {
        case .drinkReadyToday:
            if let from = wine.drinkWindow.from, currentYear < from { return false }
            if let to = wine.drinkWindow.to, currentYear > to { return false }
            return true
        case .expiringSoon:
            if let to = wine.drinkWindow.to {
                return to - currentYear <= 0
            }
            return false
        case .restockFavorites:
            return wine.isFavouriteStyle && wine.quantity <= 2
        case .unrated:
            return averageRating(for: wine, store: store) == nil
        case .missingMetadata:
            return !dataCompletenessFlags(for: wine).isEmpty
        case .openBottleWarning:
            return freshnessStatus(for: wine, store: store) == .warningExceeded
        }
    }
}

private extension VintageBucket {
    func contains(vintage: Int?) -> Bool {
        switch self {
        case .nonVintage:
            return vintage == nil
        case .from2015To2018:
            guard let vintage else { return false }
            return (2015...2018).contains(vintage)
        case .from2019To2021:
            guard let vintage else { return false }
            return (2019...2021).contains(vintage)
        case .from2022On:
            guard let vintage else { return false }
            return vintage >= 2022
        }
    }
}

private extension PriceBucket {
    func contains(price: WinePrice?) -> Bool {
        guard let amount = price?.amount else { return false }
        switch self {
        case .upToTwenty:
            return amount <= 20
        case .twentyToFifty:
            return amount > 20 && amount <= 50
        case .fiftyToOneHundred:
            return amount > 50 && amount <= 100
        case .aboveOneHundred:
            return amount > 100
        }
    }
}

// MARK: - Helpers

extension Array where Element == Wine {
    func sorted(by option: CellarSortOption, store: MockDataStore) -> [Wine] {
        switch option {
        case .recentlyAdded:
            return self.sorted { $0.id > $1.id }
        case .drinkWindowSoonest:
            return self.sorted { lhs, rhs in
                lhs.drinkWindowStartOrFallback < rhs.drinkWindowStartOrFallback
            }
        case .ratingHighToLow:
            return self.sorted { lhs, rhs in
                let lhsRating = store.averageRating(for: lhs) ?? -1
                let rhsRating = store.averageRating(for: rhs) ?? -1
                if lhsRating == rhsRating {
                    return lhs.producer < rhs.producer
                }
                return lhsRating > rhsRating
            }
        case .priceAscending:
            return self.sorted { lhs, rhs in
                (lhs.price?.amount ?? .infinity) < (rhs.price?.amount ?? .infinity)
            }
        case .priceDescending:
            return self.sorted { lhs, rhs in
                (lhs.price?.amount ?? 0) > (rhs.price?.amount ?? 0)
            }
        case .vintageNewest:
            return self.sorted { lhs, rhs in
                (lhs.vintage ?? Int.min) > (rhs.vintage ?? Int.min)
            }
        case .vintageOldest:
            return self.sorted { lhs, rhs in
                (lhs.vintage ?? Int.max) < (rhs.vintage ?? Int.max)
            }
        case .quantityHighToLow:
            return self.sorted { $0.quantity > $1.quantity }
        case .quantityLowToHigh:
            return self.sorted { $0.quantity < $1.quantity }
        }
    }
}

struct GrapeSynonyms {
    static func matches(grape: String, with normalizedGrapes: Set<String>) -> Bool {
        let lowercased = grape.lowercased()
        guard let synonyms = dictionary[lowercased] else { return false }
        return !normalizedGrapes.isDisjoint(with: synonyms)
    }

    private static let dictionary: [String: Set<String>] = {
        var map: [String: Set<String>] = [:]
        func add(_ key: String, synonyms: [String]) {
            map[key] = Set(synonyms.map { $0.lowercased() })
        }
        add("spätburgunder", synonyms: ["pinot noir"])
        add("grauburgunder", synonyms: ["pinot gris", "pinot grigio"])
        add("weißburgunder", synonyms: ["pinot blanc"])
        add("blaufränkisch", synonyms: ["lemberger"])
        return map
    }()
}

private extension Set where Element == String {
    func isDisjoint(with other: Set<String>) -> Bool {
        return intersection(other).isEmpty
    }
}

private extension Wine {
    var tags: Set<String> {
        Set(metadataTags)
    }

    var metadataTags: [String] {
        // Placeholder for future metadata such as Bio/Biodynamisch etc.
        []
    }

    var isFavouriteStyle: Bool {
        switch style {
        case .red, .sparkling:
            return true
        default:
            return false
        }
    }

    var drinkWindowStartOrFallback: Int {
        if let from = drinkWindow.from {
            return from
        }
        if let to = drinkWindow.to {
            return to
        }
        return Int.max
    }

    var closure: BottleClosure? {
        switch style {
        case .sparkling, .white: return .screwcap
        case .sweet, .fortified: return .other
        default: return .cork
        }
    }

    var bottleSizeInMl: Int? { 750 }

    var servingHints: Set<ServingHint> {
        var hints: Set<ServingHint> = []
        if style == .red || style == .fortified {
            hints.insert(.decant)
        }
        if style == .sparkling || style == .white {
            hints.insert(.servingTemperature)
        }
        return hints
    }
}

extension MockDataStore {
    func averageRating(for wine: Wine) -> Double? {
        let ratings = ratings(for: wine)
        guard ratings.isEmpty == false else { return nil }
        let total = ratings.reduce(0.0) { $0 + $1.stars }
        return total / Double(ratings.count)
    }

    func lastTastingDate(for wine: Wine) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dates = ratings(for: wine).compactMap { formatter.date(from: $0.date) }
        return dates.max()
    }

    func hasNotes(for wine: Wine) -> Bool {
        ratings(for: wine).contains { !$0.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }
}
