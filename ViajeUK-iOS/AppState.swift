//
//  AppState.swift
//  Estado observable: datos + estado del usuario + persistencia + monedas + sync.
//

import Foundation
import SwiftUI

@MainActor
final class AppState: ObservableObject {

    // Datos del itinerario (mutables: el sync puede actualizarlos en memoria)
    @Published var plan: [CityBlock] = TripData.makePlan()
    @Published var extras: [ExtraCost] = TripData.makeExtras()

    // Tipos de cambio
    @Published var rateArs: Double = 1500 { didSet { save() } }
    @Published var rateGbp: Double = 0.79 { didSet { save() } }

    // Estado del usuario (overlay)
    @Published var choices: [String: String] = [:]
    @Published var done: [String: Bool] = [:]
    @Published var reserved: [String: Bool] = [:]
    @Published var links: [String: String] = [:]
    @Published var maps: [String: String] = [:]
    @Published var meals: [String: DayMeals] = [:]
    @Published var added: [String: [CustomItem]] = [:]   // dayID -> entradas agregadas
    @Published var deleted: [String: Bool] = [:]         // itemID -> eliminada
    @Published var csvURL: String = ""

    // Feedback de guardado
    @Published var savedFlash = false

    // Sincronización en la nube
    weak var cloud: CloudSync?
    var updatedAt: Date = .distantPast      // marca de tiempo de la última edición local
    private var applyingRemote = false      // evita feedback loop al aplicar cambios remotos

    private let storeKey = "viajeUK2026"

    init() { load() }

    // MARK: - Persistencia
    func snapshot() -> PersistState {
        PersistState(rateArs: rateArs, rateGbp: rateGbp, csvURL: csvURL,
                     choices: choices, done: done, reserved: reserved,
                     links: links, maps: maps, meals: meals,
                     added: added, deleted: deleted, updatedAt: updatedAt)
    }

    func apply(_ s: PersistState) {
        applyingRemote = true
        rateArs = s.rateArs; rateGbp = s.rateGbp; csvURL = s.csvURL
        choices = s.choices; done = s.done; reserved = s.reserved
        links = s.links; maps = s.maps; meals = s.meals
        added = s.added; deleted = s.deleted
        updatedAt = s.updatedAt
        applyingRemote = false
        persistOnly()
    }

    /// Guarda en disco y marca cambio local (dispara push a la nube).
    func save() {
        guard !applyingRemote else { persistOnly(); return }
        updatedAt = Date()
        persistOnly()
        savedFlash = true
        cloud?.scheduleSync()
        Task { try? await Task.sleep(nanoseconds: 1_600_000_000); savedFlash = false }
    }

    private func persistOnly() {
        if let data = try? JSONEncoder().encode(snapshot()) {
            UserDefaults.standard.set(data, forKey: storeKey)
        }
    }

    // MARK: - Merge desde la nube (unión por clave; en conflicto gana el más nuevo)
    /// Fusiona el estado remoto con el local y devuelve el snapshot resultante para re-subir.
    func mergeFromCloud(_ r: PersistState) -> PersistState {
        let remoteNewer = r.updatedAt > updatedAt
        applyingRemote = true
        choices  = Self.mergeDict(choices, r.choices, preferRemote: remoteNewer)
        done     = Self.mergeDict(done, r.done, preferRemote: remoteNewer)
        reserved = Self.mergeDict(reserved, r.reserved, preferRemote: remoteNewer)
        links    = Self.mergeDict(links, r.links, preferRemote: remoteNewer)
        maps     = Self.mergeDict(maps, r.maps, preferRemote: remoteNewer)
        meals    = Self.mergeMeals(meals, r.meals, preferRemote: remoteNewer)
        deleted  = Self.mergeDict(deleted, r.deleted, preferRemote: remoteNewer)
        added    = Self.mergeAdded(added, r.added, preferRemote: remoteNewer)
        if remoteNewer {
            rateArs = r.rateArs; rateGbp = r.rateGbp
            if !r.csvURL.isEmpty { csvURL = r.csvURL }
        }
        updatedAt = max(updatedAt, r.updatedAt)
        applyingRemote = false
        persistOnly()
        return snapshot()
    }

    private static func mergeDict<V>(_ a: [String: V], _ b: [String: V], preferRemote: Bool) -> [String: V] {
        var out = a
        for (k, v) in b where out[k] == nil || preferRemote { out[k] = v }
        return out
    }
    private static func mergeMeals(_ a: [String: DayMeals], _ b: [String: DayMeals], preferRemote: Bool) -> [String: DayMeals] {
        var out = a
        for (day, remoteDay) in b {
            var dm = out[day] ?? DayMeals()
            for (mk, meal) in remoteDay.meals where dm.meals[mk] == nil || preferRemote {
                dm.meals[mk] = meal
            }
            out[day] = dm
        }
        return out
    }
    private static func mergeAdded(_ a: [String: [CustomItem]], _ b: [String: [CustomItem]], preferRemote: Bool) -> [String: [CustomItem]] {
        var out = a
        for (day, items) in b {
            var byId: [String: CustomItem] = [:]
            for it in (out[day] ?? []) { byId[it.id] = it }
            for it in items where byId[it.id] == nil || preferRemote { byId[it.id] = it }
            out[day] = byId.values.sorted { $0.createdAt < $1.createdAt }
        }
        return out
    }

    // MARK: - Agregar / eliminar entradas
    /// Items a mostrar para un día: base (sin eliminadas) + agregadas (sin eliminadas), en orden.
    func renderItems(_ day: DayPlan) -> [ItineraryItem] {
        var out = day.items.filter { deleted[$0.id] != true }
        if let customs = added[day.id] {
            out += customs.filter { deleted[$0.id] != true }.map { $0.asItem }
        }
        return out
    }
    func addEntry(_ item: CustomItem) {
        added[item.dayID, default: []].append(item)
        save()
    }
    func deleteItem(_ id: String) {
        deleted[id] = true
        save()
    }
    func isDeleted(_ id: String) -> Bool { deleted[id] == true }
    func restoreItem(_ id: String) { deleted[id] = nil; save() }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storeKey),
              let s = try? JSONDecoder().decode(PersistState.self, from: data) else { return }
        apply(s)
    }

    // MARK: - Accesores efectivos
    func isDone(_ id: String) -> Bool { done[id] ?? false }
    func setDone(_ id: String, _ v: Bool) { done[id] = v; save() }

    func effReserved(_ item: ItineraryItem) -> Bool { reserved[item.id] ?? (item.res ?? false) }
    func setReserved(_ item: ItineraryItem, _ v: Bool) { reserved[item.id] = v; save() }

    func effLink(_ item: ItineraryItem) -> String {
        if let v = links[item.id] { return v }
        if let l = item.link, !isMapURL(l) { return l }
        return ""
    }
    func effMap(_ item: ItineraryItem) -> String {
        if let v = maps[item.id] { return v }
        if let m = item.map, !m.isEmpty { return m }
        if let l = item.link, isMapURL(l) { return l }
        return ""
    }
    func setLink(_ item: ItineraryItem, _ v: String) { links[item.id] = v.trimmingCharacters(in: .whitespaces); save() }
    func setMap(_ item: ItineraryItem, _ v: String) { maps[item.id] = v.trimmingCharacters(in: .whitespaces); save() }

    func choice(_ freeID: String) -> String { choices[freeID] ?? "" }
    func setChoice(_ freeID: String, _ v: String) { choices[freeID] = v; save() }

    // MARK: - Comidas
    func meal(day: String, type: MealType) -> Meal { meals[day]?.meals[type.rawValue] ?? Meal() }
    func setMeal(day: String, type: MealType, _ meal: Meal) {
        var dm = meals[day] ?? DayMeals()
        dm.meals[type.rawValue] = meal
        meals[day] = dm
        save()
    }
    func dayMealTotal(_ day: String) -> Int {
        guard let dm = meals[day] else { return 0 }
        return dm.meals.values.compactMap { $0.price }.reduce(0, +)
    }

    // MARK: - Presupuesto
    func budgetByCategory() -> [String: Int] {
        var cat: [String: Int] = [:]
        for b in plan { for d in b.days { for it in renderItems(d) {
            if let p = it.price { cat[it.cat ?? "Otros", default: 0] += p }
        }}}
        for e in extras { cat[e.cat, default: 0] += e.price }
        return cat
    }
    var total: Int { budgetByCategory().values.reduce(0, +) }

    func cityBudget(_ b: CityBlock) -> Int {
        b.days.flatMap { renderItems($0) }.compactMap { $0.price }.reduce(0, +)
    }

    func loc(_ b: CityBlock) -> String { b.loc }

    // MARK: - Formato de moneda
    private static let nf: NumberFormatter = {
        let f = NumberFormatter(); f.numberStyle = .decimal
        f.groupingSeparator = "."; f.decimalSeparator = ","; f.maximumFractionDigits = 0
        return f
    }()
    func fmt(_ n: Int) -> String { AppState.nf.string(from: NSNumber(value: n)) ?? "\(n)" }
    func usd(_ n: Int) -> String { "USD " + fmt(n) }
    func gbp(_ n: Int) -> String { "£" + fmt(Int((Double(n) * rateGbp).rounded())) }
    func ars(_ n: Int) -> String { "ARS " + fmt(Int((Double(n) * rateArs).rounded())) }
    func conv(_ n: Int) -> String { gbp(n) + " · " + ars(n) }

    // MARK: - Google Maps helper
    func gmaps(_ q: String) -> String {
        let enc = q.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? q
        return "https://www.google.com/maps/search/?api=1&query=\(enc)"
    }
    func isMapURL(_ u: String) -> Bool {
        let s = u.lowercased()
        return s.contains("maps.app.goo") || s.contains("google.") && s.contains("/maps") || s.contains("maps.google")
    }

    // MARK: - Export
    func buildExport() -> String {
        var lines = ["VIAJE UK 2026 — Cambios", "Día\tPlan elegido / Estado", ""]
        lines.append("— DÍAS LIBRES —")
        for b in plan { for d in b.days { for it in d.items where it.free {
            if let fid = it.freeID {
                let c = choices[fid]
                lines.append("\(d.title)\t\(c?.isEmpty == false ? c! : "(sin elegir)")")
            }
        }}}
        lines.append(""); lines.append("— COMIDAS PLANIFICADAS —")
        var anyMeal = false
        for b in plan { for d in b.days {
            if let dm = meals[d.id] {
                for t in MealType.allCases {
                    if let x = dm.meals[t.rawValue], !x.name.isEmpty || x.price != nil {
                        let p = x.price != nil ? " — USD \(x.price!)" : ""
                        lines.append("\(d.title)\t\(t.label): \(x.name.isEmpty ? "(sin nombre)" : x.name)\(p)")
                        anyMeal = true
                    }
                }
            }
        }}
        if !anyMeal { lines.append("(sin comidas elegidas todavía)") }

        lines.append(""); lines.append("— ENTRADAS AGREGADAS —")
        var anyAdd = false
        for b in plan { for d in b.days {
            for c in (added[d.id] ?? []) where deleted[c.id] != true {
                let price = c.price != nil ? " — USD \(c.price!)" : ""
                let time = c.time.isEmpty ? "" : "\(c.time) "
                lines.append("\(d.title)\t+ \(time)\(c.act)\(price)  (agregó \(c.addedBy.isEmpty ? "?" : c.addedBy))")
                anyAdd = true
            }
        }}
        if !anyAdd { lines.append("(ninguna)") }

        lines.append(""); lines.append("— ENTRADAS ELIMINADAS —")
        var anyDel = false
        for b in plan { for d in b.days { for it in d.items where deleted[it.id] == true {
            lines.append("\(d.title)\t− \(it.act)"); anyDel = true
        }}}
        if !anyDel { lines.append("(ninguna)") }

        lines.append(""); lines.append("— RESERVAS Y ENLACES MODIFICADOS —")
        var anyRes = false
        for b in plan { for d in b.days { for it in renderItems(d) {
            if let r = reserved[it.id] { lines.append("\(d.title)\t\(it.act): \(r ? "RESERVADO" : "sin reservar")"); anyRes = true }
            if let m = maps[it.id], !m.isEmpty { lines.append("\(d.title)\t\(it.act) · Maps: \(m)"); anyRes = true }
            if let l = links[it.id], !l.isEmpty { lines.append("\(d.title)\t\(it.act) · Enlace: \(l)"); anyRes = true }
        }}}
        if !anyRes { lines.append("(sin cambios)") }

        lines.append(""); lines.append("— ACTIVIDADES MARCADAS COMO HECHAS —")
        var any = false
        for b in plan { for d in b.days { for it in renderItems(d) where done[it.id] == true {
            lines.append("\(d.title)\t✓ \(it.act)"); any = true
        }}}
        if !any { lines.append("(nada marcado todavía)") }
        return lines.joined(separator: "\n")
    }

    // MARK: - Respaldo
    func backupData() -> Data {
        (try? JSONEncoder().encode(snapshot())) ?? Data()
    }
    func backupFileURL() -> URL? {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("viaje-uk-respaldo.json")
        do { try backupData().write(to: url); return url } catch { return nil }
    }
    func restore(from data: Data) -> Bool {
        guard let s = try? JSONDecoder().decode(PersistState.self, from: data) else { return false }
        apply(s); save(); return true
    }

    // MARK: - Sincronización con la hoja (CSV publicado)
    enum SyncResult { case ok(updated: Int, unmatched: Int); case failure(String) }

    func syncFromCSV() async -> SyncResult {
        let url = csvURL.trimmingCharacters(in: .whitespaces)
        guard let u = URL(string: url), !url.isEmpty else { return .failure("pegá primero la URL del CSV publicado") }
        save()
        do {
            var req = URLRequest(url: u); req.cachePolicy = .reloadIgnoringLocalCacheData
            let (data, resp) = try await URLSession.shared.data(for: req)
            if let http = resp as? HTTPURLResponse, http.statusCode != 200 { return .failure("HTTP \(http.statusCode)") }
            guard let text = String(data: data, encoding: .utf8) else { return .failure("no se pudo leer el CSV") }
            if text.lowercased().contains("<html") { return .failure("la URL no devuelve CSV") }
            let (updated, unmatched) = merge(rows: CSV.parse(text))
            return .ok(updated: updated, unmatched: unmatched)
        } catch {
            return .failure(error.localizedDescription)
        }
    }

    private func merge(rows: [[String]]) -> (Int, Int) {
        guard !rows.isEmpty else { return (0, 0) }
        let headerIdx = rows.firstIndex { row in row.contains { $0.range(of: "Actividad", options: .caseInsensitive) != nil } } ?? 0
        var updated = 0, unmatched = 0
        var newPlan = plan
        var newExtras = extras
        var i = headerIdx + 1
        while i < rows.count {
            let r = rows[i]; i += 1
            if r.count < 5 { continue }
            let dia = r[0], hora = r[1], act = r[3], det = r[4], precio = r[5]
            let link = r.count > 6 ? r[6] : ""
            let res = r.count > 7 ? r[7] : ""
            let paid = r.count > 8 ? r[8] : ""
            let detN = CSV.norm(det)
            if CSV.norm(dia).isEmpty,
               ["total", "asistencia al viajero", "compras varias", "comidas"].contains(detN) {
                if let p = CSV.price(precio) {
                    if detN == "asistencia al viajero" { setExtra(&newExtras, "Asistencia al viajero", p) }
                    if detN == "compras varias" { setExtra(&newExtras, "Compras varias", p) }
                    if detN == "comidas" { setExtra(&newExtras, "Comidas (estimado)", p) }
                }
                continue
            }
            let actN = CSV.norm(act)
            if actN.isEmpty { continue }
            let tok = CSV.dateToken(dia)
            if findAndUpdate(&newPlan, tok: tok, actN: actN, price: CSV.price(precio),
                             res: res, paid: paid, link: link, hora: hora) {
                updated += 1
            } else { unmatched += 1 }
        }
        plan = newPlan
        extras = newExtras
        return (updated, unmatched)
    }

    private func setExtra(_ extras: inout [ExtraCost], _ name: String, _ price: Int) {
        if let idx = extras.firstIndex(where: { $0.act == name }) { extras[idx].price = price }
    }

    private func findAndUpdate(_ plan: inout [CityBlock], tok: String, actN: String,
                               price: Int?, res: String, paid: String, link: String, hora: String) -> Bool {
        for bi in plan.indices {
            for di in plan[bi].days.indices {
                if !tok.isEmpty && CSV.dateToken(plan[bi].days[di].title) != tok { continue }
                for ii in plan[bi].days[di].items.indices {
                    let ia = CSV.norm(plan[bi].days[di].items[ii].act)
                    if !ia.isEmpty && (ia.contains(actN) || actN.contains(ia)) {
                        if let p = price { plan[bi].days[di].items[ii].price = p }
                        if res.range(of: "true", options: .caseInsensitive) != nil { plan[bi].days[di].items[ii].res = true }
                        else if res.range(of: "false", options: .caseInsensitive) != nil { plan[bi].days[di].items[ii].res = false }
                        if paid.range(of: "true", options: .caseInsensitive) != nil { plan[bi].days[di].items[ii].paid = true }
                        else if paid.range(of: "false", options: .caseInsensitive) != nil { plan[bi].days[di].items[ii].paid = false }
                        if link.lowercased().hasPrefix("http") { plan[bi].days[di].items[ii].link = link }
                        if !hora.isEmpty { plan[bi].days[di].items[ii].time = hora.replacingOccurrences(of: " a ", with: "–") }
                        return true
                    }
                }
            }
        }
        return false
    }
}

// MARK: - Parser CSV
enum CSV {
    static func parse(_ text: String) -> [[String]] {
        var rows: [[String]] = []
        var row: [String] = []
        var field = ""
        var inQ = false
        let chars = Array(text)
        var i = 0
        while i < chars.count {
            let c = chars[i]
            if inQ {
                if c == "\"" {
                    if i + 1 < chars.count && chars[i+1] == "\"" { field.append("\""); i += 1 }
                    else { inQ = false }
                } else { field.append(c) }
            } else {
                if c == "\"" { inQ = true }
                else if c == "," { row.append(field); field = "" }
                else if c == "\n" { row.append(field); rows.append(row); row = []; field = "" }
                else if c == "\r" { /* skip */ }
                else { field.append(c) }
            }
            i += 1
        }
        if !field.isEmpty || !row.isEmpty { row.append(field); rows.append(row) }
        return rows
    }

    static func norm(_ s: String) -> String {
        s.lowercased().replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func price(_ s: String) -> Int? {
        let cleaned = s.replacingOccurrences(of: ",", with: "").replacingOccurrences(of: " ", with: "")
        if let m = cleaned.range(of: "usd?\\$?([0-9]+(\\.[0-9]+)?)", options: .regularExpression) {
            let num = cleaned[m].replacingOccurrences(of: "usd", with: "", options: .caseInsensitive)
                .replacingOccurrences(of: "$", with: "")
            if let d = Double(num) { return Int(d.rounded()) }
        }
        if let m = cleaned.range(of: "[0-9]+", options: .regularExpression) {
            return Int(cleaned[m])
        }
        return nil
    }

    /// "Viernes 10 Jul" / "Friday 10 Jul" -> "10 jul"
    static func dateToken(_ s: String) -> String {
        if let m = s.range(of: "([0-9]{1,2})\\s*([A-Za-zÁ-úÀ-ÿ]{3,})", options: .regularExpression) {
            let part = String(s[m])
            let comps = part.split(whereSeparator: { $0 == " " }).map(String.init)
            if comps.count >= 2 {
                let num = comps[0].filter { $0.isNumber }
                let mon = comps[1].prefix(3).lowercased()
                return "\(num) \(mon)"
            }
        }
        return ""
    }
}
