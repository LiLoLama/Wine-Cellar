//
//  Components.swift
//  Wine Cellar
//
//  Contains reusable building blocks for the Caveo mock UI.
//

import SwiftUI

struct CaveoCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .caveoCardBackground()
    }
}

struct CaveoChip: View {
    enum Style {
        case filled(Color)
        case outline(Color)
    }

    let text: String
    let icon: String?
    let style: Style

    init(text: String, icon: String? = nil, style: Style) {
        self.text = text
        self.icon = icon
        self.style = style
    }

    var body: some View {
        HStack(spacing: CaveoSpacing.xs) {
            if let icon {
                Image(systemName: icon)
            }
            Text(text)
        }
        .font(CaveoTypography.chip())
        .padding(.vertical, CaveoSpacing.xs)
        .padding(.horizontal, CaveoSpacing.m)
        .background(background)
        .foregroundStyle(foreground)
        .overlay(
            RoundedRectangle(cornerRadius: CaveoRadius.chip, style: .continuous)
                .stroke(borderColor, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: CaveoRadius.chip, style: .continuous))
    }

    private var background: Color {
        switch style {
        case .filled(let color):
            return color.opacity(0.15)
        case .outline:
            return Color.clear
        }
    }

    private var foreground: Color {
        switch style {
        case .filled(let color):
            return color
        case .outline(let color):
            return color
        }
    }

    private var borderColor: Color {
        switch style {
        case .filled(let color):
            return color.opacity(0.3)
        case .outline(let color):
            return color.opacity(0.6)
        }
    }
}

struct BadgeView: View {
    let info: BadgeInfo

    var body: some View {
        Text(info.text.uppercased())
            .font(CaveoTypography.caption())
            .padding(.vertical, CaveoSpacing.xxs)
            .padding(.horizontal, CaveoSpacing.s)
            .background(
                Capsule(style: .continuous)
                    .fill(info.tone.background)
            )
            .foregroundStyle(info.tone.text)
    }
}

struct RatingStarsView: View {
    let rating: Double

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<5, id: \.self) { index in
                let starValue = Double(index) + 1
                let fill = rating >= starValue
                    ? 1
                    : (rating + 0.5 >= starValue ? 0.5 : 0)
                StarShape(fill: fill)
                    .frame(width: 16, height: 16)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Bewertung: \(String(format: "%.1f", rating)) von 5 Sternen")
    }

    private struct StarShape: View {
        let fill: Double

        var body: some View {
            Image(systemName: systemName)
                .symbolRenderingMode(.palette)
                .foregroundStyle(Color("Accent"), Color("Accent").opacity(0.2))
        }

        private var systemName: String {
            switch fill {
            case 1: return "star.fill"
            case 0.5: return "star.leadinghalf.filled"
            default: return "star"
            }
        }
    }
}

struct SearchBarView: View {
    @Binding var text: String
    let placeholder: String

    var body: some View {
        HStack(spacing: CaveoSpacing.s) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color("SecondaryText"))
            TextField(placeholder, text: $text)
                .textFieldStyle(.plain)
                .font(CaveoTypography.bodyPrimary())
        }
        .padding(.horizontal, CaveoSpacing.m)
        .padding(.vertical, CaveoSpacing.s)
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

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    let actionTitle: String
    let action: () -> Void

    var body: some View {
        VStack(spacing: CaveoSpacing.l) {
            Image(systemName: icon)
                .font(.system(size: 48, weight: .medium))
                .foregroundStyle(Color("SecondaryText"))
            VStack(spacing: CaveoSpacing.s) {
                Text(title)
                    .font(CaveoTypography.headlineMedium())
                    .foregroundStyle(Color("PrimaryText"))
                Text(subtitle)
                    .font(CaveoTypography.bodySecondary())
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color("SecondaryText"))
            }
            Button(action: {
                Haptics.lightImpact()
                action()
            }) {
                Text(actionTitle)
                    .font(CaveoTypography.bodyEmphasized())
                    .padding(.horizontal, CaveoSpacing.xl)
                    .padding(.vertical, CaveoSpacing.s)
                    .background(
                        Capsule(style: .continuous)
                            .fill(Color("Accent"))
                    )
                    .foregroundStyle(Color("Surface"))
            }
        }
        .padding(CaveoSpacing.l)
    }
}

struct PrimaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: {
            Haptics.lightImpact()
            withAnimation(.easeInOut(duration: 0.22)) {
                action()
            }
        }) {
            Text(title)
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
}

struct SecondaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(CaveoTypography.bodyPrimary())
                .frame(maxWidth: .infinity)
                .padding(.vertical, CaveoSpacing.m)
                .background(
                    RoundedRectangle(cornerRadius: CaveoRadius.card, style: .continuous)
                        .stroke(Color("Border"), lineWidth: 1)
                        .background(
                            RoundedRectangle(cornerRadius: CaveoRadius.card, style: .continuous)
                                .fill(Color("Surface"))
                        )
                )
                .foregroundStyle(Color("PrimaryText"))
        }
        .buttonStyle(.plain)
    }
}

struct Toast: Identifiable, Equatable {
    let id = UUID()
    let message: String
    let icon: String
}

private struct ToastView: View {
    let toast: Toast

    var body: some View {
        HStack(spacing: CaveoSpacing.s) {
            Image(systemName: toast.icon)
                .font(.system(size: 18, weight: .semibold))
            Text(toast.message)
                .font(CaveoTypography.bodyPrimary())
        }
        .padding(.horizontal, CaveoSpacing.l)
        .padding(.vertical, CaveoSpacing.s)
        .background(
            Capsule(style: .continuous)
                .fill(Color("Surface"))
        )
        .overlay(
            Capsule(style: .continuous)
                .stroke(Color("Border"), lineWidth: 1)
        )
        .shadow(color: CaveoShadow.subtle.color, radius: 16, y: 8)
        .foregroundStyle(Color("PrimaryText"))
    }
}

private struct ToastModifier: ViewModifier {
    @Binding var toast: Toast?

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottom) {
                if let toast {
                    ToastView(toast: toast)
                        .padding(.horizontal, CaveoSpacing.l)
                        .padding(.bottom, CaveoSpacing.l)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(.easeInOut(duration: 0.22), value: toast)
            .onChange(of: toast) { _, newValue in
                guard let toast = newValue else { return }
                let currentID = toast.id
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    if self.toast?.id == currentID {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            self.toast = nil
                        }
                    }
                }
            }
    }
}

extension View {
    func toast(_ toast: Binding<Toast?>) -> some View {
        modifier(ToastModifier(toast: toast))
    }
}
