//
//  IdeasView.swift
//  Pestaña Ideas: lugares y actividades por ciudad (mercados, comidas, rooftops, pubs, atracciones).
//  Con estrellas + reseñas, filtros por ciudad/tipo, umbrales configurables y tope por tipo.
//  Tap en una idea abre Google Maps.
//

import SwiftUI

struct IdeasView: View {
    @EnvironmentObject var store: AppState
    @Environment(\.openURL) private var openURL

    @State private var cityFilter: String? = nil      // nil = todas
    @State private var typeFilter: IdeaType? = nil     // nil = todos
    @State private var showFilters = false

    // Umbrales configurables (persisten)
    @AppStorage("ideaMinStars")   private var minStars: Double = 4.2
    @AppStorage("ideaMinReviews") private var minReviews: Double = 150
    @AppStorage("ideaPerType")    private var perType: Double = 5

    private var allIdeas: [Idea] { TripData.ideasCatalog }

    private let cityOrder = ["Londres", "Oxford", "Cotswolds", "York", "Edimburgo"]

    private var cities: [String] {
        let present = Set(allIdeas.map { $0.city })
        var ordered = cityOrder.filter { present.contains($0) }
        ordered += present.subtracting(ordered).sorted()
        return ordered
    }

    /// Tipos presentes en la ciudad elegida (para no mostrar chips vacíos).
    private var availableTypes: [IdeaType] {
        let base = allIdeas.filter { cityFilter == nil || $0.city == cityFilter }
        return IdeaType.allCases.filter { t in base.contains { $0.type == t } }
    }

    /// Ideas que pasan todos los filtros (ciudad, tipo, estrellas y reseñas).
    private var filtered: [Idea] {
        allIdeas.filter { i in
            (cityFilter == nil || i.city == cityFilter) &&
            (typeFilter == nil || i.type == typeFilter) &&
            i.stars >= minStars &&
            Double(i.reviews) >= minReviews
        }
    }

    /// Agrupadas por tipo (en el orden del enum), ordenadas por rating y limitadas por tipo.
    private var grouped: [(type: IdeaType, items: [Idea])] {
        let cap = max(1, Int(perType))
        var out: [(IdeaType, [Idea])] = []
        for t in IdeaType.allCases {
            let items = filtered.filter { $0.type == t }
                .sorted { ($0.stars, $0.reviews) > ($1.stars, $1.reviews) }
            if !items.isEmpty { out.append((t, Array(items.prefix(cap)))) }
        }
        return out.map { (type: $0.0, items: $0.1) }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    SectionHeader(eyebrow: "Para los días libres", title: "Lugares y actividades",
                                  desc: "Los mejores lugares por ciudad y categoría, con su puntaje. Filtrá por ciudad, tipo o ajustá los mínimos. Tocá uno para abrirlo en Maps.")

                    filterSection
                    advancedFilters

                    if grouped.isEmpty {
                        Text("No hay lugares con esos filtros. Probá bajar el mínimo de estrellas o reseñas.")
                            .font(.system(size: 14)).foregroundColor(.ukMuted)
                            .padding(.vertical, 8)
                    } else {
                        ForEach(grouped, id: \.type) { section in
                            typeSection(section.type, section.items)
                        }
                        .animation(.easeInOut(duration: 0.22), value: cityFilter)
                    }
                }
                .padding(20)
            }
            .background(Color.ukCream2)
            .navigationTitle("Ideas")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Sección por tipo

    private func typeSection(_ type: IdeaType, _ items: [Idea]) -> some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack(spacing: 6) {
                Text("\(type.emoji) \(type.label)").font(.serifTitle(18, weight: .semibold)).foregroundColor(.ukNavy)
                Text("\(items.count)").font(.system(size: 11, weight: .bold)).foregroundColor(.ukMuted)
                    .padding(.horizontal, 6).padding(.vertical, 1)
                    .background(Color.ukCream2).clipShape(Capsule())
            }
            FlowLayout(spacing: 8, lineSpacing: 8) {
                ForEach(items) { idea in ideaPill(idea) }
            }
        }
    }

    // MARK: - Filtros básicos

    private var filterSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            filterRow(title: "Ciudad") {
                chip("Todas", active: cityFilter == nil) { cityFilter = nil }
                ForEach(cities, id: \.self) { c in
                    chip(c, active: cityFilter == c) { cityFilter = (cityFilter == c) ? nil : c }
                }
            }
            filterRow(title: "Tipo") {
                chip("Todos", active: typeFilter == nil) { typeFilter = nil }
                ForEach(availableTypes) { t in
                    chip("\(t.emoji) \(t.label)", active: typeFilter == t) {
                        typeFilter = (typeFilter == t) ? nil : t
                    }
                }
            }
        }
        .onChange(of: cityFilter) { _ in
            if let t = typeFilter, !availableTypes.contains(t) { typeFilter = nil }
        }
    }

    // MARK: - Filtros avanzados (sliders)

    private var advancedFilters: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button { withAnimation(.easeInOut(duration: 0.15)) { showFilters.toggle() } } label: {
                HStack {
                    Image(systemName: "slider.horizontal.3")
                    Text("Ajustes: ★ \(minStars, specifier: "%.1f")+ · \(Int(minReviews))+ reseñas · \(Int(perType)) por tipo")
                        .font(.system(size: 12.5, weight: .semibold))
                    Spacer()
                    Image(systemName: showFilters ? "chevron.up" : "chevron.down").font(.system(size: 12))
                }
                .foregroundColor(.ukNavy)
                .padding(.vertical, 4)
                .contentShape(Rectangle())
            }.buttonStyle(.plain)

            if showFilters {
                VStack(alignment: .leading, spacing: 14) {
                    sliderRow(title: "Estrellas mínimas", value: "\(String(format: "%.1f", minStars)) ★") {
                        Slider(value: $minStars, in: 3.5...5.0, step: 0.1).tint(.ukGold)
                    }
                    sliderRow(title: "Reseñas mínimas", value: "\(Int(minReviews))+") {
                        Slider(value: $minReviews, in: 0...3000, step: 50).tint(.ukGreen)
                    }
                    sliderRow(title: "Cantidad por tipo", value: "\(Int(perType))") {
                        Slider(value: $perType, in: 1...15, step: 1).tint(.ukNavy)
                    }
                }
                .padding(12)
                .background(Color.ukPaper)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.ukCream2, lineWidth: 1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.top, 8)
            }
        }
    }

    private func sliderRow<S: View>(title: String, value: String, @ViewBuilder _ slider: () -> S) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(title).font(.system(size: 13, weight: .semibold)).foregroundColor(.ukNavy)
                Spacer()
                Text(value).font(.system(size: 13, weight: .bold)).foregroundColor(.ukRed)
            }
            slider()
        }
    }

    private func filterRow<Content: View>(title: String, @ViewBuilder _ chips: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title.uppercased()).font(.system(size: 11, weight: .bold)).tracking(1)
                .foregroundColor(.ukMuted)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) { chips() }
            }
        }
    }

    private func chip(_ label: String, active: Bool, _ action: @escaping () -> Void) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) { action() }
        } label: {
            Text(label).font(.system(size: 13, weight: active ? .semibold : .medium))
                .foregroundColor(active ? .white : .ukNavy)
                .padding(.horizontal, 13).padding(.vertical, 7)
                .background(active ? Color.ukNavy : Color.ukPaper)
                .overlay(Capsule().stroke(active ? Color.ukNavy : Color.ukCream2, lineWidth: 1))
                .clipShape(Capsule())
        }.buttonStyle(.plain)
    }

    // MARK: - Pill de idea (tap → Maps)

    private func ideaPill(_ idea: Idea) -> some View {
        Button {
            open(store.gmaps("\(idea.name) \(idea.city)"))
        } label: {
            HStack(spacing: 5) {
                Text(idea.name).font(.system(size: 13, weight: .medium)).foregroundColor(.ukNavy)
                if idea.stars > 0 {
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill").font(.system(size: 9)).foregroundColor(.ukGold)
                        Text(String(format: "%.1f", idea.stars)).font(.system(size: 12, weight: .bold)).foregroundColor(.ukNavy)
                        Text("(\(revs(idea.reviews)))").font(.system(size: 11)).foregroundColor(.ukMuted)
                    }
                }
                if let f = idea.free {
                    Text(f).font(.system(size: 12, weight: .semibold)).foregroundColor(.ukGreen)
                }
                if let c = idea.cost {
                    Text(c).font(.system(size: 12, weight: .semibold)).foregroundColor(.ukRed)
                }
                Image(systemName: "mappin.circle.fill").font(.system(size: 12)).foregroundColor(.ukMuted.opacity(0.7))
            }
            .padding(.horizontal, 14).padding(.vertical, 9)
            .background(Color.ukPaper)
            .overlay(Capsule().stroke(Color.ukCream2, lineWidth: 1))
            .clipShape(Capsule())
        }.buttonStyle(.plain)
    }

    /// Formatea reseñas: 1500 → "1.5k", 22000 → "22k".
    private func revs(_ n: Int) -> String {
        if n >= 10000 { return "\(n / 1000)k" }
        if n >= 1000 { return String(format: "%.1fk", Double(n) / 1000) }
        return "\(n)"
    }

    private func open(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        openURL(url)
    }
}
