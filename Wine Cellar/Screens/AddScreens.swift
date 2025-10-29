//
//  AddScreens.swift
//  Wine Cellar
//
//  UI mocks for adding and reviewing wines.
//

import SwiftUI

struct AddHomeView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: CaveoSpacing.l) {
                Text("Wie möchtest du hinzufügen?")
                    .font(CaveoTypography.headlineMedium())
                    .foregroundStyle(Color("PrimaryText"))
                    .frame(maxWidth: .infinity, alignment: .leading)

                NavigationLink(destination: AddManualView()) {
                    OptionCard(title: "Manuell eintragen", subtitle: "Geführtes Formular mit allen Details", icon: "square.and.pencil")
                }
                .buttonStyle(.plain)

                NavigationLink(destination: AddReviewView()) {
                    OptionCard(title: "Label scannen (KI)", subtitle: "Schneller Vorschlag aus Foto oder Text", icon: "viewfinder")
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, CaveoSpacing.l)
            .padding(.top, CaveoSpacing.l)
            .padding(.bottom, CaveoSpacing.xl)
        }
        .scrollIndicators(.hidden)
        .background(Color("Background").ignoresSafeArea())
        .navigationTitle("Hinzufügen")
    }
}

private struct OptionCard: View {
    let title: String
    let subtitle: String
    let icon: String

    var body: some View {
        CaveoCard {
            HStack(alignment: .center, spacing: CaveoSpacing.m) {
                Image(systemName: icon)
                    .font(.system(size: 36, weight: .medium))
                    .frame(width: 64, height: 64)
                    .background(
                        RoundedRectangle(cornerRadius: CaveoRadius.card, style: .continuous)
                            .fill(Color("Muted"))
                    )
                    .foregroundStyle(Color("Accent"))

                VStack(alignment: .leading, spacing: CaveoSpacing.xs) {
                    Text(title)
                        .font(CaveoTypography.bodyEmphasized())
                        .foregroundStyle(Color("PrimaryText"))
                    Text(subtitle)
                        .font(CaveoTypography.bodySecondary())
                        .foregroundStyle(Color("SecondaryText"))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(Color("SecondaryText"))
            }
        }
    }
}

struct AddManualView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var producer = ""
    @State private var wineName = ""
    @State private var vintage = ""
    @State private var style: WineStyle = .red
    @State private var region = ""
    @State private var appellation = ""
    @State private var grapes = ""
    @State private var abv = ""
    @State private var drinkFrom = ""
    @State private var drinkTo = ""
    @State private var location = ""
    @State private var quantity = ""
    @State private var price = ""
    @State private var retailer = ""
    @State private var notes = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: CaveoSpacing.l) {
                Group {
                    FieldSection(title: "Basics") {
                        CaveoTextField("Produzent", text: $producer)
                        CaveoTextField("Weinname", text: $wineName)
                        CaveoTextField("Jahrgang", text: $vintage, keyboard: .numberPad)
                        StylePicker(selection: $style)
                    }

                    FieldSection(title: "Herkunft") {
                        CaveoTextField("Region", text: $region)
                        CaveoTextField("Appellation", text: $appellation)
                        CaveoTextField("Rebsorten", text: $grapes, prompt: "Pinot Noir, Chardonnay …")
                    }

                    FieldSection(title: "Details") {
                        CaveoTextField("Alkohol %", text: $abv, keyboard: .decimalPad)
                        HStack(spacing: CaveoSpacing.s) {
                            CaveoTextField("Trinkfenster von", text: $drinkFrom, keyboard: .numberPad)
                            CaveoTextField("bis", text: $drinkTo, keyboard: .numberPad)
                        }
                        CaveoTextField("Lagerort", text: $location, prompt: "Rack B • Fach 3")
                        CaveoTextField("Menge", text: $quantity, keyboard: .numberPad)
                        CaveoTextField("Preis", text: $price, keyboard: .decimalPad)
                        CaveoTextField("Händler", text: $retailer)
                    }

                    FieldSection(title: "Notizen") {
                        CaveoTextEditor("Notizen", text: $notes)
                    }
                }

                VStack(spacing: CaveoSpacing.s) {
                    SecondaryButton(title: "Abbrechen") {
                        dismiss()
                    }
                    NavigationLink(destination: AddReviewView()) {
                        Text("Weiter")
                            .font(CaveoTypography.bodyEmphasized())
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, CaveoSpacing.m)
                            .background(
                                RoundedRectangle(cornerRadius: CaveoRadius.card, style: .continuous)
                                    .fill(Color("Accent"))
                            )
                            .foregroundStyle(Color("Surface"))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.bottom, CaveoSpacing.xl)
            }
            .padding(.horizontal, CaveoSpacing.l)
            .padding(.top, CaveoSpacing.l)
        }
        .background(Color("Background").ignoresSafeArea())
        .navigationTitle("Manuell eintragen")
    }
}

private struct FieldSection<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: CaveoSpacing.s) {
            Text(title.uppercased())
                .font(CaveoTypography.bodyEmphasized())
                .foregroundStyle(Color("SecondaryText"))
            VStack(spacing: CaveoSpacing.s) {
                content
            }
            .padding(CaveoSpacing.m)
            .background(
                RoundedRectangle(cornerRadius: CaveoRadius.card, style: .continuous)
                    .fill(Color("Surface"))
            )
            .overlay(
                RoundedRectangle(cornerRadius: CaveoRadius.card, style: .continuous)
                    .stroke(Color("Border"), lineWidth: 1)
            )
        }
    }
}

private struct StylePicker: View {
    @Binding var selection: WineStyle

    var body: some View {
        VStack(alignment: .leading, spacing: CaveoSpacing.xs) {
            Text("Stil")
                .font(CaveoTypography.bodyPrimary())
                .foregroundStyle(Color("SecondaryText"))
            Picker("Stil", selection: $selection) {
                ForEach(WineStyle.allCases) { style in
                    Text(style.displayName).tag(style)
                }
            }
            .pickerStyle(.segmented)
        }
    }
}

private struct CaveoTextField: View {
    let title: String
    @Binding var text: String
    var prompt: String? = nil
    var keyboard: UIKeyboardType = .default

    init(_ title: String, text: Binding<String>, prompt: String? = nil, keyboard: UIKeyboardType = .default) {
        self.title = title
        self._text = text
        self.prompt = prompt
        self.keyboard = keyboard
    }

    var body: some View {
        VStack(alignment: .leading, spacing: CaveoSpacing.xs) {
            Text(title)
                .font(CaveoTypography.bodyPrimary())
                .foregroundStyle(Color("SecondaryText"))
            TextField("", text: $text, prompt: prompt.map { Text($0) })
                .keyboardType(keyboard)
                .textFieldStyle(.plain)
                .font(CaveoTypography.bodyPrimary())
                .padding(.vertical, CaveoSpacing.xs)
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .frame(height: 1)
                        .foregroundStyle(Color("Border"))
                }
        }
    }
}

private struct CaveoTextEditor: View {
    let title: String
    @Binding var text: String

    init(_ title: String, text: Binding<String>) {
        self.title = title
        self._text = text
    }

    var body: some View {
        VStack(alignment: .leading, spacing: CaveoSpacing.xs) {
            Text(title)
                .font(CaveoTypography.bodyPrimary())
                .foregroundStyle(Color("SecondaryText"))
            TextEditor(text: $text)
                .frame(minHeight: 120)
                .padding(CaveoSpacing.xs)
                .background(
                    RoundedRectangle(cornerRadius: CaveoRadius.card, style: .continuous)
                        .fill(Color("Muted"))
                )
        }
    }
}

struct AddReviewView: View {
    @State private var toast: Toast?

    private let exampleJSON: String = """
{
  "producer": "Weingut Keller",
  "wine": "Riesling von der Fels",
  "vintage": 2021,
  "style": "white",
  "region": "Rheinhessen",
  "notes": "Säure, Steinobst, Energie"
}
"""

    var body: some View {
        VStack(spacing: CaveoSpacing.l) {
            VStack(alignment: .leading, spacing: CaveoSpacing.s) {
                Text("Überprüfen")
                    .font(CaveoTypography.headlineMedium())
                    .foregroundStyle(Color("PrimaryText"))
                Text("Abgleich des KI-Vorschlags. Keine echten Daten – nur Visualisierung.")
                    .font(CaveoTypography.bodySecondary())
                    .foregroundStyle(Color("SecondaryText"))
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            ScrollView {
                Text(exampleJSON)
                    .font(.system(size: 13, weight: .regular, design: .monospaced))
                    .padding(CaveoSpacing.m)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: CaveoRadius.card, style: .continuous)
                            .fill(Color("Surface"))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: CaveoRadius.card, style: .continuous)
                            .stroke(Color("Border"), lineWidth: 1)
                    )
                    .padding(.horizontal, CaveoSpacing.l)
            }

            PrimaryButton(title: "Speichern") {
                toast = Toast(message: "Gespeichert (Mock)", icon: "checkmark")
            }
            .padding(.horizontal, CaveoSpacing.l)

            Spacer()
        }
        .padding(.top, CaveoSpacing.l)
        .background(Color("Background").ignoresSafeArea())
        .navigationTitle("Überprüfen")
        .toast($toast)
    }
}
