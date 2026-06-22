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
                                  desc: "Marcá Reservado, editá enlaces y ubicación en Maps de cada entrada, y planificá las comidas. Todo se guarda solo.")
                        .padding(.horizontal, 16).padding(.top, 12)

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
            .onTapGesture { withAnimation(.easeInOut(duration: 0.25)) { expanded.toggle() } }

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

                        ForEach(store.renderItems(day)) { item in
                            ItemRowView(item: item, loc: block.loc)
                            Divider().background(Color.ukCream2)
                        }

                        Button { addRef = DayRef(id: day.id) } label: {
                            Label("Agregar entrada", systemImage: "plus.circle.fill")
                                .font(.system(size: 13, weight: .semibold)).foregroundColor(.ukRed)
                        }
                        .padding(.top, 8).padding(.bottom, 2)

                        MealsView(dayID: day.id, loc: block.loc)
                            .padding(.vertical, 10)
                    }
                    if idx < block.days.count - 1 { Divider().background(Color.ukCream2) }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 14)
            }
        }
        .background(Color.ukPaper)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.ukCream2, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 12)
        .sheet(item: $addRef) { ref in
            AddEntrySheet(dayID: ref.id, dayTitle: dayTitle(ref.id))
        }
    }

    private func dayTitle(_ id: String) -> String {
        block.days.first { $0.id == id }?.title ?? ""
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
            Button { withAnimation { expanded.toggle() } } label: {
                HStack {
                    Text("🍴 Comidas del día").font(.serifTitle(15, weight: .semibold)).foregroundColor(.ukNavy)
                    if total > 0 {
                        Text("· \(store.usd(total)) · \(store.conv(total)) (2 pers.)")
                            .font(.system(size: 11)).foregroundColor(.ukRed)
                    }
                    Spacer()
                    Image(systemName: expanded ? "chevron.up" : "chevron.down").foregroundColor(.ukMuted).font(.system(size: 12))
                }
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
                TextField("Lugar o plato (libre)", text: $name)
                    .font(.system(size: 13))
                    .padding(7).background(Color.white).clipShape(RoundedRectangle(cornerRadius: 7))
                    .onChange(of: name) { _ in persist() }
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
}
