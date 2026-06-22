//
//  SummaryView.swift
//  Pestaña Resumen: portada, presupuesto, tipos de cambio, respaldo, sync, export.
//

import SwiftUI
import UniformTypeIdentifiers

struct SummaryView: View {
    @EnvironmentObject var store: AppState
    @EnvironmentObject var cloud: CloudSync
    @AppStorage("editorName") private var editorName = ""
    @State private var showSync = false
    @State private var showExport = false
    @State private var showImporter = false
    @State private var importMsg: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    hero
                    VStack(alignment: .leading, spacing: 18) {
                        actionsRow
                        cloudCard
                        SectionHeader(eyebrow: "El viaje de un vistazo",
                                      title: "Resumen y presupuesto",
                                      desc: "Mica tiene su congreso la primera semana en Londres; esos días Exe arma su propia agenda (mirá los días libres en el itinerario). Todos los costos en dólares con su equivalente en libras y pesos.")
                        budgetCards
                        ratesCard
                        backupCard
                        noteCard
                    }
                    .padding(50)
                }
            }
            .background(Color.ukCream)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showSync) { SyncView() }
            .sheet(isPresented: $showExport) { ExportView() }
            .fileImporter(isPresented: $showImporter, allowedContentTypes: [.json]) { result in
                switch result {
                case .success(let url):
                    let ok = url.startAccessingSecurityScopedResource()
                    defer { if ok { url.stopAccessingSecurityScopedResource() } }
                    if let data = try? Data(contentsOf: url), store.restore(from: data) {
                        importMsg = "Respaldo restaurado ✓"
                    } else { importMsg = "Archivo de respaldo inválido" }
                case .failure: importMsg = "No se pudo abrir el archivo"
                }
            }
            .alert(importMsg ?? "", isPresented: Binding(get: { importMsg != nil }, set: { if !$0 { importMsg = nil } })) {
                Button("OK", role: .cancel) {}
            }
        }
    }

    // MARK: Hero
    private var hero: some View {
        ZStack(alignment: .bottomLeading) {
            CityImage(url: TripData.imgLondon, height: 320)
            LinearGradient(colors: [.clear, .ukNavy.opacity(0.85)], startPoint: .top, endPoint: .bottom)
                .frame(height: 320)
            VStack(alignment: .leading, spacing: 8) {
                Text("UNITED KINGDOM · MMXXVI")
                    .font(.system(size: 11, weight: .semibold)).tracking(3)
                    .foregroundColor(.ukGold2)
                    .lineLimit(1).minimumScaleFactor(0.6)
                Text("Exe & Mica").font(.serifTitle(38)).foregroundColor(.white)
                    .lineLimit(1).minimumScaleFactor(0.6)
                Text("en el Reino Unido").font(.serifTitle(26, weight: .semibold).italic())
                    .foregroundColor(.ukGold2)
                    .lineLimit(1).minimumScaleFactor(0.6)
                HStack(spacing: 14) {
                    stat("9–25 Jul", "2026")
                    stat("17", "Días")
                    stat("5", "Ciudades")
                }
                .padding(.top, 6)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(50)
        }
        .frame(maxWidth: .infinity)
        .clipped()
    }
    private func stat(_ v: String, _ l: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(v).font(.serifTitle(20, weight: .bold)).foregroundColor(.ukGold2)
                .lineLimit(1).minimumScaleFactor(0.6).fixedSize()
            Text(l.uppercased()).font(.system(size: 10, weight: .medium)).tracking(1).foregroundColor(.white.opacity(0.85))
                .lineLimit(1).fixedSize()
        }
    }

    // MARK: Acciones
    private var actionsRow: some View {
        HStack(spacing: 10) {
            Button { showSync = true } label: {
                Label("Sincronizar", systemImage: "arrow.triangle.2.circlepath")
                    .font(.system(size: 14, weight: .semibold))
                    .frame(maxWidth: .infinity).padding(.vertical, 11)
                    .background(Color.ukRed).foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            Button { showExport = true } label: {
                Label("Exportar", systemImage: "square.and.arrow.up")
                    .font(.system(size: 14, weight: .semibold))
                    .frame(maxWidth: .infinity).padding(.vertical, 11)
                    .background(Color.ukGold).foregroundColor(.ukNavy)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }

    // MARK: Nube (compartido Exe & Mica)
    private var otherName: String { editorName == "Exe" ? "Mica" : (editorName == "Mica" ? "Exe" : "tu compañer@") }
    private var cloudCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: cloud.statusOK ? "checkmark.icloud.fill" : "icloud")
                    .foregroundColor(cloud.statusOK ? .ukGreen : .ukMuted)
                Text("Compartido con \(otherName)")
                    .font(.system(size: 14, weight: .semibold)).foregroundColor(.ukNavy)
                Spacer()
                Button { Task { await cloud.sync() } } label: {
                    Image(systemName: "arrow.clockwise").font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.ukNavy).padding(8)
                        .background(Color.ukCream2).clipShape(Circle())
                }
            }
            Text(cloud.statusText).font(.system(size: 12)).foregroundColor(.ukMuted)
                .fixedSize(horizontal: false, vertical: true)
            HStack(spacing: 8) {
                Text("Soy:").font(.system(size: 13)).foregroundColor(.ukMuted)
                Picker("Soy", selection: $editorName) {
                    Text("Exe").tag("Exe")
                    Text("Mica").tag("Mica")
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 200)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.ukPaper)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.ukCream2, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: Tarjetas de presupuesto
    private var budgetCards: some View {
        let cat = store.budgetByCategory()
        let items: [(String, Int, String)] = [
            ("Presupuesto total", store.total, "2 personas · 17 días"),
            ("Alojamiento", cat["Alojamiento"] ?? 0, "AirBnb + hoteles"),
            ("Vuelos + Trenes", (cat["Vuelos"] ?? 0) + (cat["Transporte"] ?? 0), "Internacional + 4 trenes"),
            ("Comidas", cat["Comidas"] ?? 0, "Afternoon tea incluido"),
            ("Actividades", cat["Actividades"] ?? 0, "Entradas y tours")
        ]
        return LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(items, id: \.0) { it in
                VStack(alignment: .leading, spacing: 3) {
                    Text(it.0.uppercased()).font(.system(size: 11, weight: .medium)).tracking(0.5).foregroundColor(.ukMuted)
                        .lineLimit(1).minimumScaleFactor(0.7)
                    Text(store.usd(it.1)).font(.serifTitle(22)).foregroundColor(.ukNavy)
                        .lineLimit(1).minimumScaleFactor(0.6)
                    Text(store.conv(it.1)).font(.system(size: 11)).foregroundColor(.ukMuted)
                        .lineLimit(1).minimumScaleFactor(0.6)
                    Text(it.2).font(.system(size: 11)).foregroundColor(.ukMuted).padding(.top, 2)
                        .lineLimit(2).fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background(Color.ukPaper)
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.ukCream2, lineWidth: 1))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
    }

    // MARK: Tipos de cambio
    private var ratesCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Tipo de cambio · 1 USD =").font(.system(size: 13, weight: .semibold)).foregroundColor(.ukNavy)
            HStack {
                HStack(spacing: 6) {
                    TextField("ARS", value: $store.rateArs, format: .number)
                        .keyboardType(.decimalPad).frame(width: 80)
                        .padding(8).background(Color.white).clipShape(RoundedRectangle(cornerRadius: 8))
                    Text("ARS").foregroundColor(.ukMuted)
                }
                HStack(spacing: 6) {
                    TextField("GBP", value: $store.rateGbp, format: .number)
                        .keyboardType(.decimalPad).frame(width: 70)
                        .padding(8).background(Color.white).clipShape(RoundedRectangle(cornerRadius: 8))
                    Text("GBP").foregroundColor(.ukMuted)
                }
            }
            Text("Total: \(store.usd(store.total)) · \(store.conv(store.total))")
                .font(.system(size: 14, weight: .semibold)).foregroundColor(.ukRed)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.ukPaper)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.ukCream2, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: Respaldo
    private var backupCard: some View {
        HStack(spacing: 10) {
            if let url = store.backupFileURL() {
                ShareLink(item: url) {
                    Label("Descargar respaldo", systemImage: "tray.and.arrow.down")
                        .font(.system(size: 13, weight: .semibold)).foregroundColor(.ukNavy)
                        .padding(.horizontal, 12).padding(.vertical, 9)
                        .background(Color.ukPaper)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.ukCream2, lineWidth: 1))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            Button { showImporter = true } label: {
                Label("Restaurar", systemImage: "tray.and.arrow.up")
                    .font(.system(size: 13, weight: .semibold)).foregroundColor(.ukNavy)
                    .padding(.horizontal, 12).padding(.vertical, 9)
                    .background(Color.ukPaper)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.ukCream2, lineWidth: 1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            Spacer()
        }
    }

    private var noteCard: some View {
        Text("💡 Tus cambios (comidas, actividades, reservas, enlaces) se guardan automáticamente y no se pierden al cerrar la app. Usá Exportar para pegarlos en el Sheet, o Sincronizar para traer datos frescos de la hoja.")
            .font(.system(size: 13)).foregroundColor(Color(red: 0.42, green: 0.35, blue: 0.16))
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(red: 0.984, green: 0.965, blue: 0.914))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.ukGold, lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
