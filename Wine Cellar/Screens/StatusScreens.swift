//
//  StatusScreens.swift
//  Wine Cellar
//
//  Additional tabs: opened bottles, insights, and profile settings.
//

import SwiftUI

struct OpenListView: View {
    @EnvironmentObject private var store: MockDataStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: CaveoSpacing.l) {
                CaveoCard {
                    VStack(alignment: .leading, spacing: CaveoSpacing.s) {
                        Text("Frisch geöffnet")
                            .font(CaveoTypography.headlineMedium())
                            .foregroundStyle(Color("PrimaryText"))
                        Text("Richtwerte für Haltbarkeit: Rot 3-4 Tage, Weiß 2-3 Tage, Schaumwein 1-2 Tage.")
                            .font(CaveoTypography.bodySecondary())
                            .foregroundStyle(Color("SecondaryText"))
                    }
                }

                VStack(spacing: CaveoSpacing.l) {
                    ForEach(store.openBottles) { bottle in
                        if let wine = store.wine(for: bottle.wineId) {
                            OpenBottleCard(wine: wine, bottle: bottle)
                        }
                    }
                }
            }
            .padding(.horizontal, CaveoSpacing.l)
            .padding(.top, CaveoSpacing.l)
            .padding(.bottom, CaveoSpacing.xl)
        }
        .scrollIndicators(.hidden)
        .background(Color("Background").ignoresSafeArea())
        .navigationTitle("Offen")
    }
}

private struct OpenBottleCard: View {
    let wine: Wine
    let bottle: OpenBottle

    var body: some View {
        CaveoCard {
            VStack(alignment: .leading, spacing: CaveoSpacing.s) {
                Text("\(wine.producer) \n\(wine.name)")
                    .font(CaveoTypography.headlineMedium())
                    .foregroundStyle(Color("PrimaryText"))
                    .lineLimit(2)
                HStack(spacing: CaveoSpacing.s) {
                    BadgeView(info: BadgeInfo(text: bottle.badgeText, tone: .neutral))
                    CaveoChip(text: bottle.preservation.label, icon: bottle.preservation.icon, style: .outline(Color("SecondaryText")))
                }
                Text("Zuletzt geöffnet am \(bottle.openedAt)")
                    .font(CaveoTypography.bodySecondary())
                    .foregroundStyle(Color("SecondaryText"))
            }
        }
    }
}

struct InsightsHomeView: View {
    @EnvironmentObject private var store: MockDataStore

    private var drinkReadyCount: Int {
        store.wines.filter { $0.trinkreifeBadge.text == "trinkreif" }.count
    }

    private var soonDueCount: Int {
        store.wines.filter { $0.trinkreifeBadge.text == "auslaufend" }.count
    }

    private var topRatingsCount: Int {
        store.ratings.filter { $0.stars >= 4.5 }.count
    }

    var body: some View {
        ScrollView {
            VStack(spacing: CaveoSpacing.l) {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: CaveoSpacing.l) {
                    InsightCard(title: "Jetzt trinkreif", value: "\(drinkReadyCount)", icon: "wineglass")
                    InsightCard(title: "Bald fällig", value: "\(soonDueCount)", icon: "timer")
                    InsightCard(title: "Top Bewertungen", value: "\(topRatingsCount)", icon: "star.fill")
                    MiniChartCard()
                }
            }
            .padding(.horizontal, CaveoSpacing.l)
            .padding(.top, CaveoSpacing.l)
            .padding(.bottom, CaveoSpacing.xl)
        }
        .scrollIndicators(.hidden)
        .background(Color("Background").ignoresSafeArea())
        .navigationTitle("Insights")
    }
}

private struct InsightCard: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        CaveoCard {
            VStack(alignment: .leading, spacing: CaveoSpacing.s) {
                Image(systemName: icon)
                    .font(.system(size: 28, weight: .medium))
                    .foregroundStyle(Color("Accent"))
                Text(title)
                    .font(CaveoTypography.bodySecondary())
                    .foregroundStyle(Color("SecondaryText"))
                Text(value)
                    .font(CaveoTypography.headlineLarge())
                    .foregroundStyle(Color("PrimaryText"))
            }
        }
    }
}

private struct MiniChartCard: View {
    var body: some View {
        CaveoCard {
            VStack(alignment: .leading, spacing: CaveoSpacing.s) {
                Text("Lagerentwicklung")
                    .font(CaveoTypography.bodySecondary())
                    .foregroundStyle(Color("SecondaryText"))
                GeometryReader { geometry in
                    HStack(alignment: .bottom, spacing: CaveoSpacing.s) {
                        ForEach(Array(sampleValues.enumerated()), id: \.offset) { item in
                            Capsule(style: .continuous)
                                .fill(LinearGradient(colors: [Color("Accent"), Color("Accent").opacity(0.5)], startPoint: .bottom, endPoint: .top))
                                .frame(width: (geometry.size.width - CaveoSpacing.s * CGFloat(sampleValues.count - 1)) / CGFloat(sampleValues.count), height: max(12, geometry.size.height * item.element))
                                .animation(.easeInOut(duration: 0.25), value: item.element)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                }
                .frame(height: 120)
            }
        }
    }

    private var sampleValues: [CGFloat] {
        [0.25, 0.6, 0.4, 0.8]
    }
}

struct ProfileHomeView: View {
    @EnvironmentObject private var themeManager: ThemeManager

    @State private var selectedLanguage: Int = 0

    var body: some View {
        ScrollView {
            VStack(spacing: CaveoSpacing.l) {
                profileHeader
                themeSection
                preferencesSection
                footer
            }
            .padding(.horizontal, CaveoSpacing.l)
            .padding(.top, CaveoSpacing.l)
            .padding(.bottom, CaveoSpacing.xl)
        }
        .scrollIndicators(.hidden)
        .background(Color("Background").ignoresSafeArea())
        .navigationTitle("Profil")
    }

    private var profileHeader: some View {
        CaveoCard {
            HStack(spacing: CaveoSpacing.m) {
                Circle()
                    .fill(Color("Muted"))
                    .frame(width: 72, height: 72)
                    .overlay(
                        Text("LS")
                            .font(CaveoTypography.bodyEmphasized())
                            .foregroundStyle(Color("PrimaryText"))
                    )
                VStack(alignment: .leading, spacing: CaveoSpacing.xs) {
                    Text("Liam Schmid")
                        .font(CaveoTypography.bodyEmphasized())
                        .foregroundStyle(Color("PrimaryText"))
                    Text("liam@caveo.app")
                        .font(CaveoTypography.bodySecondary())
                        .foregroundStyle(Color("SecondaryText"))
                }
                Spacer()
            }
        }
    }

    private var themeSection: some View {
        CaveoCard {
            VStack(alignment: .leading, spacing: CaveoSpacing.s) {
                Text("Theme")
                    .font(CaveoTypography.bodyEmphasized())
                    .foregroundStyle(Color("SecondaryText"))
                Picker("Theme", selection: Binding(get: { themeManager.theme }, set: { newValue in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        themeManager.theme = newValue
                    }
                })) {
                    ForEach(CaveoTheme.allCases, id: \.self) { theme in
                        Text(theme.label).tag(theme)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
    }

    private var preferencesSection: some View {
        CaveoCard {
            VStack(alignment: .leading, spacing: CaveoSpacing.s) {
                Text("Sprache")
                    .font(CaveoTypography.bodyEmphasized())
                    .foregroundStyle(Color("SecondaryText"))
                Picker("Sprache", selection: $selectedLanguage) {
                    Text("Deutsch").tag(0)
                    Text("English").tag(1)
                }
                .pickerStyle(.segmented)

                Divider().overlay(Color("Border"))

                VStack(alignment: .leading, spacing: CaveoSpacing.xs) {
                    Label("Benachrichtigungen", systemImage: "bell")
                        .opacity(0.5)
                    Text("In Planung – bald konfigurierbar.")
                        .font(CaveoTypography.bodySecondary())
                        .foregroundStyle(Color("SecondaryText"))
                }
            }
        }
    }

    private var footer: some View {
        VStack(alignment: .leading, spacing: CaveoSpacing.s) {
            Text("Version 0.1.0-mock")
                .font(CaveoTypography.bodySecondary())
                .foregroundStyle(Color("SecondaryText"))
            Text("Caveo ist ein Design-Mockup. Keine echten Daten oder Netzwerkverbindungen.")
                .font(CaveoTypography.caption())
                .foregroundStyle(Color("SecondaryText"))
        }
        .padding(.horizontal, CaveoSpacing.s)
    }
}
