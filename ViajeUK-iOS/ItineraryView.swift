//
//  ItineraryView.swift
//  Pestaña Itinerario: ciudades, días, actividades y comidas.
//

import SwiftUI

struct ItineraryView: View {
    @EnvironmentObject var store: AppState

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(eyebrow: "Día a día", title: "Itinerario completo",
                                  desc: "Tocá Editar para cambiar título, horario o precio; agregá notas, marcá Reservado y planificá las comidas. Todo se guarda solo.")
                        .padding(.horizontal, 16).padding(.top, 12)

                    PersonaFilterBar()
                        .padding(.horizontal, 16)

                    if store.unseenNotesCount > 0 {
                        unseenBanner.padding(.horizontal, 16)
                    }

                    ForEach(store.plan) { block in
                        CityCard(block: block)
                    }
                }
                .padding(.bottom, 24)
            }
            .background(Color.ukCream2)
            .navigationTitle("Itinerario")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var unseenBanner: some View {
        HStack(spacing: 8) {
            Image(systemName: "sparkles").foregroundColor(.ukRed)
            Text(store.unseenNotesCount == 1
                 ? "Hay 1 nota nueva o actualizada por tu compañero/a."
                 : "Hay \(store.unseenNotesCount) notas nuevas o actualizadas por tu compañero/a.")
                .font(.system(size: 13, weight: .semibold)).foregroundColor(.ukRed)
            Spacer(minLength: 0)
        }
        .padding(10)
        .background(Color.ukRed.opacity(0.08))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.ukRed.opacity(0.35), lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - Filtro por persona
struct PersonaFilterBar: View {
    @EnvironmentObject var store: AppState
    private let options = ["", "Exe", "Mica", "Juntos"]

    var body: some View {
        HStack(spacing: 8) {
            ForEach(options, id: \.self) { opt in
                chip(opt)
            }
            Spacer(minLength: 0)
        }
    }

    private func chip(_ opt: String) -> some View {
        let selected = store.personaFilter == opt
        let label = opt.isEmpty ? "Todos" : opt
        let c: Color = opt.isEmpty ? .ukNavy : .persona(opt)
        return Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                store.personaFilter = selected ? "" : opt
            }
        } label: {
            HStack(spacing: 5) {
                if !opt.isEmpty {
                    Image(systemName: PersonaStyle.icon(opt)).font(.system(size: 10, weight: .bold))
                }
                Text(label).font(.system(size: 12.5, weight: .semibold))
            }
            .foregroundColor(selected ? .white : c)
            .padding(.horizontal, 12).padding(.vertical, 6)
            .background(selected ? c : c.opacity(0.10))
            .overlay(Capsule().stroke(c.opacity(selected ? 0 : 0.35), lineWidth: 1))
            .clipShape(Capsule())
        }.buttonStyle(.plain)
    }
}

struct DayRef: Identifiable { let id: String }

struct CityCard: View {
    @EnvironmentObject var store: AppState
    let block: CityBlock
    @State private var addRef: DayRef?
    @AppStorage private var expanded: Bool

    init(block: CityBlock) {
        self.block = block
        _expanded = AppStorage(wrappedValue: true, "exp-\(block.id)")
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottomLeading) {
                CityImage(url: block.image, height: 180)
                LinearGradient(colors: [.clear, .ukNavy.opacity(0.8)], startPoint: .top, endPoint: .bottom)
                    .frame(height: 180)
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(block.dates).font(.system(size: 12)).foregroundColor(.white.opacity(0.9))
                        Text(block.city).font(.serifTitle(22)).foregroundColor(.white)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 1) {
                        Text(store.usd(store.cityBudget(block))).font(.serifTitle(17)).foregroundColor(.white)
                        Text(store.conv(store.cityBudget(block))).font(.system(size: 10)).foregroundColor(.white.opacity(0.9))
                    }
                    .padding(.horizontal, 10).padding(.vertical, 6)
                    .background(.white.opacity(0.16))
                    .clipShape(RoundedRectangle(cornerRadius: 9))
                }
                .padding(16)
            }
            .overlay(alignment: .topTrailing) {
                Image(systemName: expanded ? "chevron.up" : "chevron.down")
                    .font(.system(size: 13, weight: .bold)).foregroundColor(.white)
                    .padding(8).background(.black.opacity(0.28)).clipShape(Circle())
                    .padding(12)
            }
            .contentShape(Rectangle())
            .onTapGesture { expanded.toggle() }

            if expanded {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(block.days.enumerated()), id: \.element.id) { idx, day in
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(spacing: 10) {
                            Text("\(idx + 1)")
                                .font(.system(size: 12, design: .serif)).foregroundColor(.ukGold2)
                                .frame(width: 26, height: 26).background(Color.ukNavy).clipShape(Circle())
                            Text(day.title).font(.serifTitle(17, weight: .semibold)).foregroundColor(.ukNavy)
                        }
                        .padding(.top, 14).padding(.bottom, 4)

                        let dayItems = store.renderItems(day)
                        let dloc = effectiveLoc(day)
                        let visibleItems = dayItems.filter { $0.cat != "Alojamiento" && store.personaVisible($0) }
                        ForEach(visibleItems) { item in
                            ItemRowView(item: item, loc: dloc)
                            Divider().background(Color.ukCream2)
                        }
                        if visibleItems.isEmpty && !store.personaFilter.isEmpty {
                            Text("Sin actividades de \(store.personaFilter) este día.")
                                .font(.system(size: 13)).italic().foregroundColor(.ukMuted)
                                .padding(.vertical, 8)
                        }

                        MealsView(dayID: day.id, loc: dloc)
                            .padding(.vertical, 10)

                        ForEach(dayItems.filter { $0.cat == "Alojamiento" }) { item in
                            LodgingView(item: item, loc: dloc)
                                .padding(.bottom, 8)
                        }

                        Button { addRef = DayRef(id: day.id) } label: {
                            Label("Agregar entrada", systemImage: "plus.circle.fill")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.ukGreenDeep)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 13)
                                .background(Color.ukGreenPastel)
                                .overlay(RoundedRectangle(cornerRadius: 11).stroke(Color.ukGreenDeep.opacity(0.25), lineWidth: 1))
                                .clipShape(RoundedRectangle(cornerRadius: 11))
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 4).padding(.bottom, 6)
                    }
                    if idx < block.days.count - 1 { Divider().background(Color.ukCream2) }
                }
            }
            .padding(.horizontal, 11)
            .padding(.bottom, 14)
            }
        }
        .background(Color.ukPaper)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.ukCream2, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 6)
        .sheet(item: $addRef) { ref in
            AddEntrySheet(dayID: ref.id, dayTitle: dayTitle(ref.id))
        }
    }

    private func dayTitle(_ id: String) -> String {
        block.days.first { $0.id == id }?.title ?? ""
    }

    /// Ciudad efectiva del día: dentro del bloque "Oxford & Cotswolds", el día de la
    /// excursión usa las comidas de Cotswolds; el resto usa la ciudad del bloque.
    private func effectiveLoc(_ day: DayPlan) -> String {
        let hay = day.items.map { "\($0.act) \($0.det)".lowercased() }.joined(separator: " ")
        if hay.contains("cotswold") || hay.contains("cotsworld") { return "Cotswolds" }
        return block.loc
    }
}

// MARK: - Comidas del día
struct MealsView: View {
    @EnvironmentObject var store: AppState
    let dayID: String
    let loc: String
    @State private var expanded = false

    var body: some View {
        let total = store.dayMealTotal(dayID)
        return VStack(alignment: .leading, spacing: 0) {
            Button { withAnimation(.easeInOut(duration: 0.15)) { expanded.toggle() } } label: {
                HStack {
                    Text("🍴 Comidas del día").font(.serifTitle(15, weight: .semibold)).foregroundColor(.ukNavy)
                    if total > 0 {
                        Text("· \(store.usd(total)) · \(store.conv(total)) (2 pers.)")
                            .font(.system(size: 11)).foregroundColor(.ukRed)
                    }
                    Spacer()
                    Image(systemName: expanded ? "chevron.up" : "chevron.down").foregroundColor(.ukMuted).font(.system(size: 12))
                }
                .padding(.vertical, 2)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if expanded {
                VStack(spacing: 8) {
                    ForEach(MealType.allCases) { type in
                        MealRow(dayID: dayID, loc: loc, type: type)
                    }
                }
                .padding(.top, 10)
            }
        }
        .padding(12)
        .background(Color(red: 0.984, green: 0.969, blue: 0.925))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.ukCream2, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct MealRow: View {
    @EnvironmentObject var store: AppState
    let dayID: String
    let loc: String
    let type: MealType

    @State private var name = ""
    @State private var priceText = ""
    @State private var editingMap = false
    @State private var mapText = ""
    @State private var loaded = false
    @State private var resolving = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Text("\(type.emoji) \(type.label)")
                    .font(.system(size: 13, weight: .semibold)).frame(width: 96, alignment: .leading)
                Menu {
                    ForEach(TripData.meals(loc: loc, type: type)) { opt in
                        Button("\(opt.name) · \(store.usd(opt.pricePP * 2))") { pick(opt) }
                    }
                } label: {
                    Image(systemName: "list.bullet").foregroundColor(.ukNavy)
                        .padding(7).background(Color.white).clipShape(RoundedRectangle(cornerRadius: 7))
                }
                let m = store.meal(day: dayID, type: type)
                if let map = m.map, !map.isEmpty, let url = URL(string: map) {
                    Link(destination: url) { Text("📍").font(.system(size: 16)) }
                } else {
                    Button { mapText = store.gmaps("\(name) \(loc)"); editingMap = true } label: {
                        Image(systemName: "mappin.circle").foregroundColor(.ukMuted)
                    }.buttonStyle(.plain)
                }
            }
            HStack(spacing: 8) {
                ZStack(alignment: .trailing) {
                    TextField("Lugar, plato o pegá un link de Maps", text: $name)
                        .font(.system(size: 13))
                        .padding(7).background(Color.white).clipShape(RoundedRectangle(cornerRadius: 7))
                        .onChange(of: name) { v in handleNameChange(v) }
                    if resolving {
                        ProgressView().scaleEffect(0.7).padding(.trailing, 8)
                    }
                }
                TextField("USD", text: $priceText)
                    .keyboardType(.numberPad).frame(width: 64)
                    .font(.system(size: 13)).multilineTextAlignment(.trailing)
                    .padding(7).background(Color.white).clipShape(RoundedRectangle(cornerRadius: 7))
                    .onChange(of: priceText) { _ in persist() }
            }
        }
        .onAppear(perform: loadOnce)
        .linkEditor(isPresented: $editingMap, title: "Google Maps de la comida", text: $mapText) { v in
            var m = store.meal(day: dayID, type: type); m.map = v; store.setMeal(day: dayID, type: type, m)
        }
    }

    private func loadOnce() {
        guard !loaded else { return }
        let m = store.meal(day: dayID, type: type)
        name = m.name
        priceText = m.price.map { String($0) } ?? ""
        loaded = true
    }
    private func pick(_ opt: MealOption) {
        name = opt.name
        priceText = String(opt.pricePP * 2)
        let m = Meal(name: opt.name, price: opt.pricePP * 2, map: store.gmaps("\(opt.name) \(loc)"))
        store.setMeal(day: dayID, type: type, m)
    }
    private func persist() {
        guard loaded else { return }
        var m = store.meal(day: dayID, type: type)
        m.name = name
        m.price = Int(priceText.filter { $0.isNumber })
        store.setMeal(day: dayID, type: type, m)
    }

    /// Si pegan un link de Google Maps en el campo de nombre, lo procesamos;
    /// si no, persistimos el texto normal.
    private func handleNameChange(_ v: String) {
        guard loaded, !resolving else { return }
        let t = v.trimmingCharacters(in: .whitespaces)
        if store.isMapURL(t) {
            Task { await resolvePastedMap(t) }
        } else {
            persist()
        }
    }

    /// Pegaron un link de Maps: lo guarda como mapa, intenta resolver el nombre del lugar
    /// y, si coincide con una sugerencia de la ciudad, completa el costo.
    @MainActor
    private func resolvePastedMap(_ url: String) async {
        resolving = true
        var m = store.meal(day: dayID, type: type)
        m.map = url                                   // (2) actualiza el link al mapa
        store.setMeal(day: dayID, type: type, m)

        let place = await PlaceResolver.name(from: url)
        let suggestions = TripData.meals(loc: loc, type: type)

        if let place, !place.isEmpty {
            name = place                              // (1) pone el nombre del lugar
            m.name = place
            // (3) costo: si el lugar coincide con una sugerencia de la ciudad, usa su precio
            if let opt = suggestions.first(where: {
                $0.name.localizedCaseInsensitiveContains(place) || place.localizedCaseInsensitiveContains($0.name)
            }) {
                priceText = String(opt.pricePP * 2)
                m.price = opt.pricePP * 2
            } else if m.price == nil, let avg = suggestions.map(\.pricePP).max() {
                // estimación suave por tipo de comida en esta ciudad
                let est = Int((Double(suggestions.map(\.pricePP).reduce(0,+)) / Double(max(suggestions.count,1))).rounded()) * 2
                priceText = String(est == 0 ? avg * 2 : est)
                m.price = Int(priceText)
            }
        } else {
            name = ""                                 // no se pudo resolver: dejamos el campo libre
            m.name = ""
        }
        store.setMeal(day: dayID, type: type, m)
        resolving = false
    }
}

// MARK: - Resolver nombre de lugar desde un link de Google Maps
enum PlaceResolver {
    /// Devuelve el nombre del lugar a partir de una URL de Google Maps (incluye short links).
    static func name(from urlString: String) async -> String? {
        guard let url = URL(string: urlString) else { return nil }
        // Atajo: si ya es una URL larga con /place/<Nombre>, parseamos directo.
        if let n = parsePlaceName(urlString) { return n }
        var req = URLRequest(url: url)
        req.setValue("Mozilla/5.0 (iPhone)", forHTTPHeaderField: "User-Agent")
        req.timeoutInterval = 12
        do {
            let (data, resp) = try await URLSession.shared.data(for: req)
            if let finalURL = resp.url?.absoluteString, let n = parsePlaceName(finalURL) { return n }
            if let html = String(data: data, encoding: .utf8), let n = parseTitle(html) { return n }
        } catch { return nil }
        return nil
    }

    /// Extrae "<Nombre>" de .../place/<Nombre>/... o del parámetro q=.
    static func parsePlaceName(_ url: String) -> String? {
        if let r = url.range(of: "/place/") {
            let after = url[r.upperBound...]
            let raw = after.split(separator: "/").first.map(String.init) ?? ""
            let cleaned = clean(raw)
            if !cleaned.isEmpty && !cleaned.lowercased().contains("maps") { return cleaned }
        }
        if let comps = URLComponents(string: url),
           let q = comps.queryItems?.first(where: { $0.name == "q" })?.value,
           q.contains(where: { $0.isLetter }) {   // tiene letras => es un nombre, no coordenadas
            return clean(q)
        }
        return nil
    }

    /// Toma el <title> de la página de Maps como respaldo.
    static func parseTitle(_ html: String) -> String? {
        guard let s = html.range(of: "<title>"), let e = html.range(of: "</title>") else { return nil }
        var title = String(html[s.upperBound..<e.lowerBound])
        for junk in [" - Google Maps", " – Google Maps", "Google Maps"] {
            title = title.replacingOccurrences(of: junk, with: "")
        }
        title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        return title.isEmpty ? nil : title
    }

    private static func clean(_ s: String) -> String {
        (s.removingPercentEncoding ?? s)
            .replacingOccurrences(of: "+", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - Hospedaje del día (celda simple: nombre editable + Maps)
struct LodgingView: View {
    @EnvironmentObject var store: AppState
    @Environment(\.openURL) private var openURL
    let item: ItineraryItem
    let loc: String

    @State private var name = ""
    @State private var editingMap = false
    @State private var mapText = ""
    @State private var loaded = false

    var body: some View {
        let map = store.effMap(item)
        return HStack(spacing: 10) {
            Image(systemName: "bed.double.fill")
                .font(.system(size: 15)).foregroundColor(.ukNavy)

            TextField("Nombre del hospedaje", text: $name)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.ukNavy)
                .onChange(of: name) { _ in persist() }

            Spacer(minLength: 8)

            if !map.isEmpty, let url = URL(string: map) {
                HStack(spacing: 6) {
                    Button { openURL(url) } label: {
                        Label("Maps", systemImage: "mappin.circle.fill")
                            .font(.system(size: 13, weight: .semibold)).foregroundColor(.ukNavy)
                    }.buttonStyle(.plain)
                    Button { mapText = map; editingMap = true } label: {
                        Image(systemName: "pencil").font(.system(size: 11)).foregroundColor(.ukMuted)
                    }.buttonStyle(.plain)
                }
            } else {
                Button { mapText = store.gmaps("\(name) \(loc)"); editingMap = true } label: {
                    Label("Ubicación", systemImage: "mappin.circle")
                        .font(.system(size: 13, weight: .semibold)).foregroundColor(.ukRed)
                }.buttonStyle(.plain)
            }
        }
        .padding(12)
        .background(Color.ukPaper)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.ukCream2, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .onAppear { if !loaded { name = item.act; loaded = true } }
        .linkEditor(isPresented: $editingMap, title: "Google Maps del hospedaje", text: $mapText) { store.setMap(item, $0) }
    }

    private func persist() {
        guard loaded else { return }
        store.setEdit(item.id,
                      act: name.trimmingCharacters(in: .whitespaces),
                      time: item.time, det: item.det, price: item.price)
    }
}
