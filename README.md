# Caveo – Wine Cellar Mock

Caveo ist ein minimalistisches SwiftUI-Mockup für eine Weinkeller-Verwaltungs-App. Das Projekt richtet sich an Design-Reviews und Navigations-Demos – **es gibt keine echten Funktionen, keine Persistenz und keine Netzwerkanbindung**.

## Features

- Moderne SwiftUI-Oberfläche mit Tab-Navigation (Keller, Hinzufügen, Offen, Insights, Profil)
- Konsistente Gestaltung mit individuellen Farb- und Typografie-Tokens
- Eingebundene Fonts **Inter** und **Cormorant Garamond** für UI und Headlines
- Dummy-Daten aus `mockData.json` (Bundle) für Weine, offene Flaschen und Bewertungen
- Karten-, Chip-, Badge- und Toast-Komponenten inklusive subtiler Animationen und Haptik (Mock)

## Voraussetzungen

- Xcode 15.4 oder neuer
- iOS 16.0+ Simulator oder Gerät

## Projektstruktur

```
Wine Cellar/
├── Assets.xcassets        # Farbpalette, App Icon
├── ContentView.swift      # Root-Tab-Navigation
├── DesignSystem/          # Tokens, Fonts, Font-Registrierung
├── Components/            # Reusable UI-Bausteine (Cards, Chips, Toast …)
├── Screens/               # Tab-spezifische Views (Keller, Add, Offen, Insights, Profil)
├── Data/mockData.json     # Statische Beispieldaten
└── Wine_CellarApp.swift   # App-Einstieg, Environment-Setup
```

## Nutzung

1. Projekt in Xcode öffnen (`Wine Cellar.xcodeproj`).
2. Ziel `Wine Cellar` auf einem iOS 16+ Simulator ausführen.
3. Durch die Tabs navigieren und UI-Elemente begutachten. Buttons lösen lediglich Mock-Toast/Haptik aus.

## Hinweise

- Alle Farben stammen aus dem Asset-Katalog (Light/Dark-Varianten).
- Fonts werden beim App-Start registriert und können mit `Font.custom()` genutzt werden.
- Das Projekt speichert keine Daten und führt keine Netzwerk- oder Kameraaktionen aus.

Lizenz siehe [LICENSE](LICENSE).
