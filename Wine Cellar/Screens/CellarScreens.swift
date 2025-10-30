//
//  CellarScreens.swift
//  Wine Cellar
//
//  Keller overview and wine detail screens for the Caveo mock app.
//

import SwiftUI

struct CellarListView: View {
    @EnvironmentObject private var store: MockDataStore
    @State private var searchText: String = ""
    @State private var filterState = CellarFilterState()
    @State private var isFilterSheetPresented = false
    @State private var sortOption: CellarSortOption = .recentlyAdded
    @State private var isQuickFilterExpanded = true

    var body: some View {
        let filteredWines = filterState
            .filteredWines(from: store, searchText: searchText)
            .sorted(by: sortOption, store: store)

        ScrollView {
            VStack(alignment: .leading, spacing: CaveoSpacing.l) {
                SearchBarView(text: $searchText, placeholder: "Produzent, Wein, Rebsorte …")
                    .padding(.top, CaveoSpacing.l)
                    .padding(.horizontal, CaveoSpacing.l)

                VStack(alignment: .leading, spacing: CaveoSpacing.s) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isQuickFilterExpanded.toggle()
                        }
                    } label: {
                        HStack(spacing: CaveoSpacing.xs) {
                            Text("Quick Filter")
                                .font(CaveoTypography.bodyEmphasized())
                                .foregroundStyle(Color("PrimaryText"))
                            Spacer()
                            Image(systemName: isQuickFilterExpanded ? "chevron.up" : "chevron.down")
                                .font(.caption)
                                .foregroundStyle(Color("SecondaryText"))
                        }
                    }
                    .buttonStyle(.plain)

                    if isQuickFilterExpanded {
                        QuickFilterStackView(
                            groups: QuickFilterGroup.makeGroups(store: store),
                            selectedFilters: $filterState.selectedQuickFilters
                        )
                        .transition(.opacity.combined(with: .slide))
                    }
                }
                .padding(.horizontal, CaveoSpacing.l)

                SortPickerView(sortOption: $sortOption)
                    .padding(.horizontal, CaveoSpacing.l)

                VStack(spacing: CaveoSpacing.l) {
                    if filteredWines.isEmpty {
                        EmptyStateView(
                            icon: "line.3.horizontal.decrease.circle",
                            title: "Keine Treffer",
                            subtitle: "Passe deine Filter oder die Suche an, um mehr Weine zu sehen.",
                            actionTitle: "Filter zurücksetzen",
                            action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    filterState = CellarFilterState()
                                    searchText = ""
                                }
                            }
                        )
                        .padding(.top, CaveoSpacing.xl)
                    } else {
                        ForEach(filteredWines) { wine in
                            NavigationLink(value: wine) {
                                WineListCard(wine: wine)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, CaveoSpacing.l)
                .padding(.bottom, CaveoSpacing.xl)
            }
        }
        .scrollIndicators(.hidden)
        .background(Color("Background").ignoresSafeArea())
        .navigationDestination(for: Wine.self) { wine in
            WineDetailView(wine: wine)
        }
        .navigationTitle("Keller")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { isFilterSheetPresented = true }) {
                    Label(filterButtonTitle, systemImage: "slider.horizontal.3")
                        .labelStyle(.titleAndIcon)
                }
                .tint(Color("Accent"))
            }
        }
        .sheet(isPresented: $isFilterSheetPresented) {
            NavigationStack {
                FilterSheetView(
                    filterState: $filterState,
                    sortOption: $sortOption,
                    store: store
                )
            }
        }
    }

    private var filterButtonTitle: String {
        let count = filterState.activeFilterCount
        if count == 0 {
            return "Erweiterte Filter"
        }
        return "Erweiterte Filter (\(count))"
    }
}

private struct QuickFilterStackView: View {
    let groups: [QuickFilterGroup]
    @Binding var selectedFilters: Set<QuickFilterOption>

    var body: some View {
        VStack(alignment: .leading, spacing: CaveoSpacing.m) {
            ForEach(groups) { group in
                VStack(alignment: .leading, spacing: CaveoSpacing.s) {
                    Text(group.title)
                        .font(CaveoTypography.caption())
                        .foregroundStyle(Color("SecondaryText"))

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: CaveoSpacing.s) {
                            ForEach(group.options, id: \.self) { option in
                                let isSelected = selectedFilters.contains(option)
                                CaveoChip(
                                    text: option.label,
                                    icon: option.icon,
                                    style: isSelected ? .filled(Color("Accent")) : .outline(Color("SecondaryText"))
                                )
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        if isSelected {
                                            selectedFilters.remove(option)
                                        } else {
                                            selectedFilters.insert(option)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

private struct SortPickerView: View {
    @Binding var sortOption: CellarSortOption

    var body: some View {
        HStack {
            Text("Sortierung")
                .font(CaveoTypography.caption())
                .foregroundStyle(Color("SecondaryText"))

            Spacer()

            Menu {
                Picker("Sortierung", selection: $sortOption) {
                    ForEach(CellarSortOption.allCases) { option in
                        Text(option.label).tag(option)
                    }
                }
            } label: {
                HStack(spacing: CaveoSpacing.xs) {
                    Text(sortOption.label)
                        .font(CaveoTypography.bodySecondary())
                        .foregroundStyle(Color("PrimaryText"))
                    Image(systemName: "arrow.up.arrow.down")
                        .foregroundStyle(Color("SecondaryText"))
                }
                .padding(.vertical, CaveoSpacing.xs)
                .padding(.horizontal, CaveoSpacing.s)
                .background(
                    Capsule(style: .continuous)
                        .fill(Color("Surface"))
                )
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(Color("Border"), lineWidth: 1)
                )
            }
        }
    }
}

private struct WineListCard: View {
    let wine: Wine

    var body: some View {
        CaveoCard {
            HStack(alignment: .top, spacing: CaveoSpacing.m) {
                LabelPlaceholder(style: wine.style)
                VStack(alignment: .leading, spacing: CaveoSpacing.s) {
                    Text(wine.producer)
                        .font(CaveoTypography.bodyEmphasized())
                        .foregroundStyle(Color("SecondaryText"))
                        .textCase(.uppercase)
                    Text(wine.name)
                        .font(CaveoTypography.headlineMedium())
                        .foregroundStyle(Color("PrimaryText"))
                        .lineLimit(2)
                        .minimumScaleFactor(0.9)

                    Text(wine.subtitleLine)
                        .font(CaveoTypography.bodySecondary())
                        .foregroundStyle(Color("SecondaryText"))

                    HStack(spacing: CaveoSpacing.s) {
                        CaveoChip(text: wine.styleLabel, style: .filled(wine.style.toneColor))
                        BadgeView(info: wine.trinkreifeBadge)
                    }

                    Divider()
                        .overlay(Color("Border"))

                    VStack(alignment: .leading, spacing: CaveoSpacing.xs) {
                        Label("\(wine.quantity) Flaschen", systemImage: "number.square")
                        Label(wine.locationSummary, systemImage: "shippingbox")
                    }
                    .font(CaveoTypography.bodySecondary())
                    .foregroundStyle(Color("SecondaryText"))
                }
            }
        }
    }
}

private struct LabelPlaceholder: View {
    let style: WineStyle

    var body: some View {
        RoundedRectangle(cornerRadius: CaveoRadius.card, style: .continuous)
            .fill(LinearGradient(colors: [style.toneColor.opacity(0.7), style.toneColor.opacity(0.3)], startPoint: .top, endPoint: .bottom))
            .frame(width: 64, height: 96)
            .overlay(
                RoundedRectangle(cornerRadius: CaveoRadius.card, style: .continuous)
                    .stroke(Color("Surface").opacity(0.4), lineWidth: 1)
            )
            .overlay(alignment: .bottomLeading) {
                Image(systemName: style.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color("Surface").opacity(0.9))
                    .padding(CaveoSpacing.s)
            }
    }
}

struct WineDetailView: View {
    @EnvironmentObject private var store: MockDataStore
    let wine: Wine

    @State private var toast: Toast?
    @State private var showForm: Bool = false

    private var ratings: [Rating] {
        store.ratings(for: wine)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: CaveoSpacing.l) {
                header
                actionRow
                sections
            }
            .padding(.horizontal, CaveoSpacing.l)
            .padding(.bottom, CaveoSpacing.xl * 2)
        }
        .scrollIndicators(.hidden)
        .background(Color("Background").ignoresSafeArea())
        .navigationTitle("Wein")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {}) {
                    Image(systemName: "ellipsis")
                }
                .opacity(0.5)
                .disabled(true)
            }
        }
        .toast($toast)
        .sheet(isPresented: $showForm) {
            AddNoteMockSheet()
        }
        .overlay(alignment: .bottomTrailing) {
            Button(action: {
                showForm = true
            }) {
                Label("Notiz", systemImage: "plus")
                    .font(CaveoTypography.bodyEmphasized())
                    .padding(.horizontal, CaveoSpacing.l)
                    .padding(.vertical, CaveoSpacing.s)
                    .background(
                        Capsule(style: .continuous)
                            .fill(Color("Accent"))
                    )
                    .foregroundStyle(Color("Surface"))
            }
            .padding(.trailing, CaveoSpacing.l)
            .padding(.bottom, CaveoSpacing.l)
            .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 10)
        }
    }

    private var header: some View {
        HStack(alignment: .top, spacing: CaveoSpacing.l) {
            RoundedRectangle(cornerRadius: CaveoRadius.card, style: .continuous)
                .fill(LinearGradient(colors: [wine.style.toneColor.opacity(0.9), wine.style.toneColor.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 120, height: 160)
                .overlay(
                    RoundedRectangle(cornerRadius: CaveoRadius.card, style: .continuous)
                        .stroke(Color("Surface").opacity(0.5), lineWidth: 1)
                )
                .overlay(alignment: .topLeading) {
                    Text(wine.vintage.map(String.init) ?? "NV")
                        .font(CaveoTypography.bodyEmphasized())
                        .padding(.all, CaveoSpacing.xs)
                        .background(Color("Surface").opacity(0.8), in: Capsule())
                        .padding(CaveoSpacing.s)
                }
            VStack(alignment: .leading, spacing: CaveoSpacing.s) {
                Text(wine.name)
                    .font(CaveoTypography.headlineLarge())
                    .foregroundStyle(Color("PrimaryText"))
                    .multilineTextAlignment(.leading)
                Text("\(wine.producer) • \(wine.region)")
                    .font(CaveoTypography.bodyPrimary())
                    .foregroundStyle(Color("SecondaryText"))

                HStack(spacing: CaveoSpacing.s) {
                    CaveoChip(text: wine.styleLabel, style: .filled(wine.style.toneColor))
                    BadgeView(info: wine.trinkreifeBadge)
                }

                VStack(alignment: .leading, spacing: CaveoSpacing.xs) {
                    Label(wine.appellation, systemImage: "globe.europe.africa")
                    Label(wine.grapes.formattedList(limit: 2), systemImage: "leaf")
                    if let abv = wine.abv {
                        Label(String(format: "%.1f%% Vol.", abv), systemImage: "drop")
                    }
                }
                .font(CaveoTypography.bodySecondary())
                .foregroundStyle(Color("SecondaryText"))
            }
        }
        .padding(.top, CaveoSpacing.l)
    }

    private var actionRow: some View {
        HStack(spacing: CaveoSpacing.s) {
            ActionPill(title: "Öffnen", icon: "wineglass")
            ActionPill(title: "Austrinken", icon: "checkmark.seal")
            ActionPill(title: "Bewerten", icon: "star")
        }
        .padding(.vertical, CaveoSpacing.s)
    }

    private var sections: some View {
        VStack(alignment: .leading, spacing: CaveoSpacing.l) {
            SectionCard(title: "Bestand & Lagerorte") {
                Text("\(wine.quantity) Flaschen • \(wine.locationSummary)")
                    .font(CaveoTypography.bodyPrimary())
                    .foregroundStyle(Color("PrimaryText"))
            }

            SectionCard(title: "Trinkfenster") {
                HStack(alignment: .center, spacing: CaveoSpacing.s) {
                    BadgeView(info: wine.trinkreifeBadge)
                    Text(wine.drinkWindow.label)
                        .font(CaveoTypography.bodyPrimary())
                        .foregroundStyle(Color("PrimaryText"))
                }
            }

            SectionCard(title: "Kaufdetails") {
                VStack(alignment: .leading, spacing: CaveoSpacing.xs) {
                    Label("Händler: Caveo Selection", systemImage: "bag")
                    if let price = wine.price?.formatted {
                        Label("Preis: \(price)", systemImage: "eurosign.circle")
                    }
                    Label("Kaufdatum: 12.04.2024", systemImage: "calendar")
                }
                .font(CaveoTypography.bodySecondary())
                .foregroundStyle(Color("SecondaryText"))
            }

            SectionCard(title: "Notizen") {
                Text("Feine Textur, viel Spannung und ein langes, salziges Finale. Notiz zur Erinnerung – keine echte Persistenz.")
                    .font(CaveoTypography.bodyPrimary())
                    .foregroundStyle(Color("PrimaryText"))
                    .multilineTextAlignment(.leading)
            }

           SectionCard(title: "Bewertungen") {
                VStack(alignment: .leading, spacing: CaveoSpacing.m) {
                    ForEach(ratings) { rating in
                        VStack(alignment: .leading, spacing: CaveoSpacing.xs) {
                            HStack {
                                RatingStarsView(rating: rating.stars)
                                Spacer()
                                Text(rating.date)
                                    .font(CaveoTypography.caption())
                                    .foregroundStyle(Color("SecondaryText"))
                            }
                            Text(rating.notes)
                                .font(CaveoTypography.bodySecondary())
                                .foregroundStyle(Color("PrimaryText"))
                        }
                        .padding(.bottom, CaveoSpacing.xs)
                        .overlay(alignment: .bottom) {
                            Divider()
                                .overlay(Color("Border"))
                                .opacity(rating.id == ratings.last?.id ? 0 : 1)
                        }
                    }
                }
            }
        }
    }

    private func ActionPill(title: String, icon: String) -> some View {
        Button {
            Haptics.lightImpact()
            toast = Toast(message: "\(title) (Mock)", icon: icon)
        } label: {
            Label(title, systemImage: icon)
                .font(CaveoTypography.bodyEmphasized())
                .padding(.vertical, CaveoSpacing.s)
                .padding(.horizontal, CaveoSpacing.l)
                .background(
                    Capsule(style: .continuous)
                        .fill(Color("Surface"))
                )
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(Color("Border"), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

private struct SectionCard<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        CaveoCard {
            VStack(alignment: .leading, spacing: CaveoSpacing.s) {
                Text(title)
                    .font(CaveoTypography.bodyEmphasized())
                    .foregroundStyle(Color("SecondaryText"))
                    .textCase(.uppercase)
                content
            }
        }
    }
}

private struct AddNoteMockSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var note: String = ""
    @State private var rating: Double = 4

    var body: some View {
        NavigationStack {
            Form {
                Section("Notiz") {
                    TextEditor(text: $note)
                        .frame(minHeight: 120)
                }
                Section("Bewertung") {
                    Slider(value: $rating, in: 0...5, step: 0.5)
                    Text("\(rating, specifier: "%.1f") Sterne")
                        .font(CaveoTypography.bodyPrimary())
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color("Background"))
            .navigationTitle("Neue Notiz")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Schließen") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fertig") { dismiss() }
                }
            }
        }
    }
}

private extension Array where Element == String {
    func formattedList(limit: Int) -> String {
        guard count > limit else { return joined(separator: ", ") }
        let head = prefix(limit).joined(separator: ", ")
        return head + " +\(count - limit)"
    }
}
