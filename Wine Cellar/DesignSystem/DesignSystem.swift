//
//  DesignSystem.swift
//  Wine Cellar
//
//  Provides shared tokens, fonts, and helpers for the Caveo mock UI.
//

import SwiftUI
import CoreText
import UIKit

enum CaveoSpacing {
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let s: CGFloat = 12
    static let m: CGFloat = 16
    static let l: CGFloat = 24
    static let xl: CGFloat = 32
}

enum CaveoRadius {
    static let chip: CGFloat = 12
    static let card: CGFloat = 16
}

enum CaveoShadow {
    static let subtle = ShadowStyle(color: Color.black.opacity(0.08), radius: 12, y: 6)

    struct ShadowStyle {
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat

        init(color: Color, radius: CGFloat, x: CGFloat = 0, y: CGFloat) {
            self.color = color
            self.radius = radius
            self.x = x
            self.y = y
        }
    }
}

enum CaveoTypography {
    static func headlineLarge() -> Font {
        Font.custom("CormorantGaramond-SemiBold", size: 28, relativeTo: .largeTitle)
    }

    static func headlineMedium() -> Font {
        Font.custom("CormorantGaramond-Regular", size: 24, relativeTo: .title2)
    }

    static func bodyPrimary() -> Font {
        Font.custom("Inter-Regular", size: 16, relativeTo: .body)
    }

    static func bodyEmphasized() -> Font {
        Font.custom("Inter-SemiBold", size: 16, relativeTo: .body)
    }

    static func bodySecondary() -> Font {
        Font.custom("Inter-Regular", size: 14, relativeTo: .callout)
    }

    static func caption() -> Font {
        Font.custom("Inter-Regular", size: 13, relativeTo: .caption)
    }

    static func chip() -> Font {
        Font.custom("Inter-SemiBold", size: 13, relativeTo: .caption)
    }
}

enum CaveoTheme: String, CaseIterable {
    case light
    case dark

    var label: String {
        switch self {
        case .light: return "Hell"
        case .dark: return "Dunkel"
        }
    }

    var colorScheme: ColorScheme {
        switch self {
        case .light: return .light
        case .dark: return .dark
        }
    }
}

final class ThemeManager: ObservableObject {
    @Published var theme: CaveoTheme = .light

    func toggle() {
        withAnimation(.easeInOut(duration: 0.2)) {
            theme = theme == .light ? .dark : .light
        }
    }
}

enum Haptics {
    static func lightImpact() {
        #if os(iOS)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        #endif
    }
}

enum FontRegistrar {
    private static let fontFiles: [String] = [
        "Inter-Regular",
        "Inter-SemiBold",
        "CormorantGaramond-Regular",
        "CormorantGaramond-SemiBold"
    ]

    static func registerFonts() {
        fontFiles.forEach { name in
            guard let url = Bundle.main.url(forResource: name, withExtension: "ttf") else {
                debugPrint("Font \(name) not found in bundle")
                return
            }
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }
}

extension View {
    func caveoCardBackground() -> some View {
        self
            .padding(CaveoSpacing.m)
            .background(
                RoundedRectangle(cornerRadius: CaveoRadius.card, style: .continuous)
                    .fill(Color("Surface"))
            )
            .overlay(
                RoundedRectangle(cornerRadius: CaveoRadius.card, style: .continuous)
                    .stroke(Color("Border"), lineWidth: 1)
            )
            .shadow(color: CaveoShadow.subtle.color, radius: CaveoShadow.subtle.radius, x: CaveoShadow.subtle.x, y: CaveoShadow.subtle.y)
    }

    func sectionHeader(_ text: String) -> some View {
        VStack(alignment: .leading, spacing: CaveoSpacing.xs) {
            Text(text)
                .font(CaveoTypography.bodyEmphasized())
                .foregroundStyle(Color("PrimaryText"))
        }
    }
}
