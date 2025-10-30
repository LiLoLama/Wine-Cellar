import SwiftUI

struct FilterSheetView: View {
    @Binding var filterState: CellarFilterState
    @Binding var sortOption: CellarSortOption
    let store: MockDataStore

    @Environment(\.dismiss) private var dismiss

    private var advancedBinding: Binding<AdvancedFilterState> {
        Binding(
            get: { filterState.advancedFilters },
            set: { filterState.advancedFilters = $0 }
        )
    }

    private var advanced: AdvancedFilterState {
        filterState.advancedFilters
    }

    var body: some View {
        Form {
            sortSection
            smartFilterSection
            wineSection
            originSection
            inventorySection
            valueSection
            ratingSection
            openBottleSection
            metadataSection
        }
        .scrollIndicators(.hidden)
        .navigationTitle("Filter")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Zurücksetzen") {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        filterState.selectedQuickFilters.removeAll()
                        filterState.advancedFilters.reset()
                    }
                }
            }
            ToolbarItem(placement: .cancellationAction) {
                Button("Schließen") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Anwenden") { dismiss() }
            }
        }
    }

    private var sortSection: some View {
        Section("Sortierung") {
            Picker("Sortierung", selection: $sortOption) {
                ForEach(CellarSortOption.allCases) { option in
                    Text(option.label).tag(option)
                }
            }
            .pickerStyle(.navigationLink)
        }
    }

    private var smartFilterSection: some View {
        Section("Smart Filter") {
            Picker("Preset", selection: advancedBinding.smartPreset) {
                Text("Keine").tag(SmartFilterPreset?.none)
                ForEach(SmartFilterPreset.allCases) { preset in
                    Text(preset.label).tag(Optional(preset))
                }
            }
            .pickerStyle(.navigationLink)
        }
    }

    private var wineSection: some View {
        Section("A. Wein & Stilistik") {
            NavigationLink("Produzent", destination: StringMultiSelectionView(
                title: "Produzent",
                options: producers,
                selection: advancedBinding.producers
            ))

            TextField("Weinname/Cuvée", text: advancedBinding.wineNameQuery)

            NavigationLink("Stil", destination: EnumMultiSelectionView(
                title: "Stil",
                options: WineStyle.allCases,
                selection: advancedBinding.styles,
                labelProvider: { $0.displayName }
            ))

            NavigationLink("Rebsorten", destination: StringMultiSelectionView(
                title: "Rebsorten",
                options: grapeOptions,
                selection: advancedBinding.grapes
            ))

            Toggle("NV einbeziehen", isOn: advancedBinding.includeNV)

            RangeInputView(
                title: "Jahrgang",
                range: advancedBinding.vintageRange,
                bounds: vintageBounds,
                formatter: { "\($0)" }
            )

            RangeDoubleInputView(
                title: "Alkohol %",
                range: advancedBinding.abvRange,
                bounds: 8.0...20.0,
                step: 0.5,
                formatter: { String(format: "%.1f %%", $0) }
            )

            NavigationLink("Verschluss", destination: EnumMultiSelectionView(
                title: "Verschluss",
                options: BottleClosure.allCases,
                selection: advancedBinding.closures,
                labelProvider: { $0.label }
            ))

            NavigationLink("Flaschengröße", destination: IntMultiSelectionView(
                title: "Flaschengröße",
                options: bottleSizeOptions,
                selection: advancedBinding.bottleSizes,
                formatter: { "\($0) ml" }
            ))

            RangeInputView(
                title: "Trinkfenster",
                range: advancedBinding.drinkWindowRange,
                bounds: drinkWindowBounds,
                formatter: { "\($0)" }
            )

            Picker("Trinkfenster (relativ)", selection: advancedBinding.relativeDrinkWindow) {
                Text("—").tag(DrinkWindowRelativeOption?.none)
                ForEach(DrinkWindowRelativeOption.allCases) { option in
                    Text(option.label).tag(Optional(option))
                }
            }
            .pickerStyle(.navigationLink)

            NavigationLink("Servierhinweise", destination: EnumMultiSelectionView(
                title: "Servierhinweise",
                options: ServingHint.allCases,
                selection: advancedBinding.servingHints,
                labelProvider: { $0.label }
            ))
        }
    }

    private var originSection: some View {
        Section("B. Herkunft & Klassifikation") {
            NavigationLink("Land", destination: StringMultiSelectionView(
                title: "Land",
                options: countries,
                selection: advancedBinding.countries
            ))

            NavigationLink("Region", destination: StringMultiSelectionView(
                title: "Region",
                options: regions,
                selection: advancedBinding.regions
            ))

            NavigationLink("Appellation", destination: StringMultiSelectionView(
                title: "Appellation",
                options: appellations,
                selection: advancedBinding.appellations
            ))

            if qualityLevels.isEmpty {
                LabeledContent("Qualitätsstufe", value: "Keine Daten")
                    .foregroundStyle(Color("SecondaryText"))
            } else {
                NavigationLink("Qualitätsstufe", destination: StringMultiSelectionView(
                    title: "Qualitätsstufe",
                    options: qualityLevels,
                    selection: advancedBinding.qualityLevels
                ))
            }

            if vineyardSites.isEmpty {
                LabeledContent("Weingartenlage", value: "Keine Daten")
                    .foregroundStyle(Color("SecondaryText"))
            } else {
                NavigationLink("Weingartenlage", destination: StringMultiSelectionView(
                    title: "Weingartenlage",
                    options: vineyardSites,
                    selection: advancedBinding.vineyardSites
                ))
            }
        }
    }

    private var inventorySection: some View {
        Section("C. Bestand & Inventar") {
            QuantityFilterView(quantityFilter: advancedBinding.quantityFilter)

            NavigationLink("Lagerort", destination: StringMultiSelectionView(
                title: "Lagerort",
                options: locations,
                selection: advancedBinding.storageLocations
            ))

            RangeInputView(
                title: "Zuletzt hinzugefügt",
                range: .constant(nil),
                bounds: 2020...Calendar.current.component(.year, from: Date()),
                formatter: { "\($0)" }
            )
            .disabled(true)
            .foregroundStyle(Color("SecondaryText"))
        }
    }

    private var valueSection: some View {
        Section("D. Einkauf & Wert") {
            RangeDoubleInputView(
                title: "Preis",
                range: advancedBinding.priceRange,
                bounds: priceBounds,
                step: 5,
                formatter: { String(format: "%.0f €", $0) }
            )

            LabeledContent("Währung", value: "EUR")
                .foregroundStyle(Color("SecondaryText"))

            LabeledContent("Händler", value: "Nicht hinterlegt")
                .foregroundStyle(Color("SecondaryText"))

            LabeledContent("Einkaufsdatum", value: "Nicht hinterlegt")
                .foregroundStyle(Color("SecondaryText"))
        }
    }

    private var ratingSection: some View {
        Section("E. Bewertung & Erlebnis") {
            Slider(
                value: Binding(
                    get: { advanced.minRating ?? 0 },
                    set: { newValue in
                        advancedBinding.minRating.wrappedValue = newValue == 0 ? nil : newValue
                    }
                ),
                in: 0...5,
                step: 0.5
            ) {
                Text("Gesamtbewertung (min.)")
            }
            .accessibilityValue(Text(String(format: "%.1f", advanced.minRating ?? 0)))

            Picker("Bewertet?", selection: Binding(
                get: { advanced.isRated == nil ? -1 : (advanced.isRated == true ? 1 : 0) },
                set: { newValue in
                    switch newValue {
                    case 1: advancedBinding.isRated.wrappedValue = true
                    case 0: advancedBinding.isRated.wrappedValue = false
                    default: advancedBinding.isRated.wrappedValue = nil
                    }
                }
            )) {
                Text("Alle").tag(-1)
                Text("Ja").tag(1)
                Text("Nein").tag(0)
            }
            .pickerStyle(.segmented)

            NavigationLink("Zuletzt verkostet", destination: DateRangeSelectionView(
                title: "Zuletzt verkostet",
                range: advancedBinding.lastTastedRange,
                bounds: tastingBounds
            ))

            Picker("Notizen vorhanden", selection: Binding(
                get: { advanced.hasNotes == nil ? -1 : (advanced.hasNotes == true ? 1 : 0) },
                set: { newValue in
                    switch newValue {
                    case 1: advancedBinding.hasNotes.wrappedValue = true
                    case 0: advancedBinding.hasNotes.wrappedValue = false
                    default: advancedBinding.hasNotes.wrappedValue = nil
                    }
                }
            )) {
                Text("Alle").tag(-1)
                Text("Ja").tag(1)
                Text("Nein").tag(0)
            }
            .pickerStyle(.segmented)
        }
    }

    private var openBottleSection: some View {
        Section("F. Offene Flaschen") {
            RangeInputView(
                title: "Seit X Tagen offen",
                range: advancedBinding.openDaysRange,
                bounds: 0...30,
                formatter: { "\($0)" }
            )

            NavigationLink("Konservierung", destination: EnumMultiSelectionView(
                title: "Konservierung",
                options: PreservationMethod.allCases,
                selection: advancedBinding.preservationMethods,
                labelProvider: { $0.label }
            ))

            NavigationLink("Haltbarkeitsstatus", destination: EnumMultiSelectionView(
                title: "Haltbarkeitsstatus",
                options: OpenBottleFreshnessStatus.allCases,
                selection: advancedBinding.freshnessStatuses,
                labelProvider: { $0.label }
            ))
        }
    }

    private var metadataSection: some View {
        Section("G. Metadaten & Tags") {
            NavigationLink("Tags", destination: StringMultiSelectionView(
                title: "Tags",
                options: tags,
                selection: advancedBinding.tags
            ))

            NavigationLink("Vollständigkeit", destination: EnumMultiSelectionView(
                title: "Vollständigkeit",
                options: DataCompletenessFlag.allCases,
                selection: advancedBinding.completenessFlags,
                labelProvider: { $0.label }
            ))
        }
    }

    private var producers: [String] {
        Array(Set(store.wines.map { $0.producer })).sorted()
    }

    private var grapeOptions: [String] {
        Array(Set(store.wines.flatMap { $0.grapes })).sorted()
    }

    private var countries: [String] {
        Array(Set(store.wines.map { $0.country })).sorted()
    }

    private var regions: [String] {
        Array(Set(store.wines.map { $0.region })).sorted()
    }

    private var appellations: [String] {
        Array(Set(store.wines.map { $0.appellation })).sorted()
    }

    private var qualityLevels: [String] {
        []
    }

    private var vineyardSites: [String] {
        []
    }

    private var locations: [String] {
        Array(Set(store.wines.flatMap { $0.locations })).sorted()
    }

    private var bottleSizeOptions: [Int] {
        [375, 750, 1500]
    }

    private var vintageBounds: ClosedRange<Int> {
        let years = store.wines.compactMap { $0.vintage }
        let minYear = years.min() ?? 1980
        let maxYear = years.max() ?? Calendar.current.component(.year, from: Date())
        return minYear...maxYear
    }

    private var drinkWindowBounds: ClosedRange<Int> {
        let fromYears = store.wines.compactMap { $0.drinkWindow.from }
        let toYears = store.wines.compactMap { $0.drinkWindow.to }
        let minYear = min(fromYears.min() ?? 1980, toYears.min() ?? 1980)
        let maxYear = max(fromYears.max() ?? Calendar.current.component(.year, from: Date()), toYears.max() ?? Calendar.current.component(.year, from: Date()))
        return minYear...maxYear
    }

    private var priceBounds: ClosedRange<Double> {
        let prices = store.wines.compactMap { $0.price?.amount }
        let minPrice = prices.min() ?? 0
        let maxPrice = prices.max() ?? 500
        return minPrice...maxPrice
    }

    private var tags: [String] {
        ["Bio", "Biodynamisch", "Naturwein", "Sammlung", "Geschenk", "Rarität"]
    }

    private var tastingBounds: ClosedRange<Date> {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dates = store.ratings.compactMap { formatter.date(from: $0.date) }
        let now = Date()
        guard let minDate = dates.min(), let maxDate = dates.max() else {
            return Calendar.current.date(byAdding: .year, value: -1, to: now)!...now
        }
        return minDate...maxDate
    }
}

// MARK: - Helper Views

private struct StringMultiSelectionView: View {
    let title: String
    let options: [String]
    @Binding var selection: Set<String>

    var body: some View {
        List {
            ForEach(options, id: \.self) { option in
                Button(action: { toggle(option) }) {
                    HStack {
                        Text(option)
                        Spacer()
                        if selection.contains(option) {
                            Image(systemName: "checkmark")
                                .foregroundStyle(Color("Accent"))
                        }
                    }
                }
            }
        }
        .navigationTitle(title)
        .listStyle(.insetGrouped)
    }

    private func toggle(_ option: String) {
        if selection.contains(option) {
            selection.remove(option)
        } else {
            selection.insert(option)
        }
    }
}

private struct EnumMultiSelectionView<Option: CaseIterable & Hashable & Identifiable>: View {
    let title: String
    let options: [Option]
    @Binding var selection: Set<Option>
    let labelProvider: (Option) -> String

    init(title: String, options: [Option] = Array(Option.allCases), selection: Binding<Set<Option>>, labelProvider: @escaping (Option) -> String) {
        self.title = title
        self.options = options
        self._selection = selection
        self.labelProvider = labelProvider
    }

    var body: some View {
        List {
            ForEach(options) { option in
                Button(action: { toggle(option) }) {
                    HStack {
                        Text(labelProvider(option))
                        Spacer()
                        if selection.contains(option) {
                            Image(systemName: "checkmark")
                                .foregroundStyle(Color("Accent"))
                        }
                    }
                }
            }
        }
        .navigationTitle(title)
        .listStyle(.insetGrouped)
    }

    private func toggle(_ option: Option) {
        if selection.contains(option) {
            selection.remove(option)
        } else {
            selection.insert(option)
        }
    }
}

private struct IntMultiSelectionView: View {
    let title: String
    let options: [Int]
    @Binding var selection: Set<Int>
    let formatter: (Int) -> String

    var body: some View {
        List {
            ForEach(options, id: \.self) { option in
                Button(action: { toggle(option) }) {
                    HStack {
                        Text(formatter(option))
                        Spacer()
                        if selection.contains(option) {
                            Image(systemName: "checkmark")
                                .foregroundStyle(Color("Accent"))
                        }
                    }
                }
            }
        }
        .navigationTitle(title)
        .listStyle(.insetGrouped)
    }

    private func toggle(_ option: Int) {
        if selection.contains(option) {
            selection.remove(option)
        } else {
            selection.insert(option)
        }
    }
}

private struct RangeInputView: View {
    let title: String
    @Binding var range: ClosedRange<Int>?
    let bounds: ClosedRange<Int>
    let formatter: (Int) -> String

    var body: some View {
        VStack(alignment: .leading, spacing: CaveoSpacing.xs) {
            Toggle(isOn: Binding(
                get: { range != nil },
                set: { newValue in
                    if newValue {
                        range = range ?? bounds
                    } else {
                        range = nil
                    }
                }
            )) {
                Text(title)
            }

            if let bindingRange = optionalBinding($range) {
                HStack {
                    Stepper(value: Binding(
                        get: { bindingRange.wrappedValue.lowerBound },
                        set: { newValue in
                            let upper = max(newValue, bindingRange.wrappedValue.upperBound)
                            bindingRange.wrappedValue = newValue...upper
                        }
                    ), in: bounds) {
                        Text("Von \(formatter(bindingRange.wrappedValue.lowerBound))")
                    }
                    Stepper(value: Binding(
                        get: { bindingRange.wrappedValue.upperBound },
                        set: { newValue in
                            let lower = min(newValue, bindingRange.wrappedValue.lowerBound)
                            bindingRange.wrappedValue = lower...newValue
                        }
                    ), in: bounds) {
                        Text("Bis \(formatter(bindingRange.wrappedValue.upperBound))")
                    }
                }
            }
        }
    }
}

private struct RangeDoubleInputView: View {
    let title: String
    @Binding var range: ClosedRange<Double>?
    let bounds: ClosedRange<Double>
    let step: Double
    let formatter: (Double) -> String

    var body: some View {
        VStack(alignment: .leading, spacing: CaveoSpacing.xs) {
            Toggle(isOn: Binding(
                get: { range != nil },
                set: { newValue in
                    if newValue {
                        range = range ?? bounds
                    } else {
                        range = nil
                    }
                }
            )) {
                Text(title)
            }

            if let bindingRange = optionalBinding($range) {
                VStack(alignment: .leading, spacing: CaveoSpacing.xs) {
                    HStack {
                        Stepper(value: Binding(
                            get: { bindingRange.wrappedValue.lowerBound },
                            set: { newValue in
                                let upper = max(newValue, bindingRange.wrappedValue.upperBound)
                                bindingRange.wrappedValue = newValue...upper
                            }
                        ), in: bounds, step: step) {
                            Text("Von \(formatter(bindingRange.wrappedValue.lowerBound))")
                        }
                    }
                    HStack {
                        Stepper(value: Binding(
                            get: { bindingRange.wrappedValue.upperBound },
                            set: { newValue in
                                let lower = min(newValue, bindingRange.wrappedValue.lowerBound)
                                bindingRange.wrappedValue = lower...newValue
                            }
                        ), in: bounds, step: step) {
                            Text("Bis \(formatter(bindingRange.wrappedValue.upperBound))")
                        }
                    }
                }
            }
        }
    }
}

private struct QuantityFilterView: View {
    @Binding var quantityFilter: QuantityFilter?

    var body: some View {
        VStack(alignment: .leading, spacing: CaveoSpacing.s) {
            Toggle("Menge filtern", isOn: Binding(
                get: { quantityFilter != nil },
                set: { newValue in
                    if newValue {
                        quantityFilter = quantityFilter ?? QuantityFilter(comparator: .atLeast, value: 1)
                    } else {
                        quantityFilter = nil
                    }
                }
            ))

            if let binding = optionalBinding($quantityFilter) {
                Picker("Vergleich", selection: binding.comparator) {
                    ForEach(QuantityComparator.allCases) { comparator in
                        Text(comparator.label).tag(comparator)
                    }
                }
                .pickerStyle(.segmented)

                Stepper(value: binding.value, in: 0...200) {
                    Text("Wert: \(binding.value.wrappedValue)")
                }
            }
        }
    }
}

private struct DateRangeSelectionView: View {
    let title: String
    @Binding var range: ClosedRange<Date>?
    let bounds: ClosedRange<Date>

    var body: some View {
        Form {
            Toggle(isOn: Binding(
                get: { range != nil },
                set: { newValue in
                    if newValue {
                        range = range ?? bounds
                    } else {
                        range = nil
                    }
                }
            )) {
                Text(title)
            }

            if let bindingRange = optionalBinding($range) {
                DatePicker(
                    "Von",
                    selection: Binding(
                        get: { bindingRange.wrappedValue.lowerBound },
                        set: { newValue in
                            let upper = max(newValue, bindingRange.wrappedValue.upperBound)
                            bindingRange.wrappedValue = newValue...upper
                        }
                    ),
                    in: bounds,
                    displayedComponents: .date
                )

                DatePicker(
                    "Bis",
                    selection: Binding(
                        get: { bindingRange.wrappedValue.upperBound },
                        set: { newValue in
                            let lower = min(newValue, bindingRange.wrappedValue.lowerBound)
                            bindingRange.wrappedValue = lower...newValue
                        }
                    ),
                    in: bounds,
                    displayedComponents: .date
                )
            }
        }
        .navigationTitle(title)
    }
}

// MARK: - Binding Helpers

private func optionalBinding<T>(_ binding: Binding<T?>) -> Binding<T>? {
    guard let value = binding.wrappedValue else { return nil }
    return Binding<T>(
        get: { binding.wrappedValue ?? value },
        set: { newValue in binding.wrappedValue = newValue }
    )
}
