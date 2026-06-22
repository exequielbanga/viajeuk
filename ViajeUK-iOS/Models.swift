//
//  Models.swift
//  Estructuras de datos (Codable) del itinerario y estado.
//

import Foundation

// MARK: - Itinerario

struct ItineraryItem: Identifiable, Codable, Hashable {
    var id: String = ""
    var time: String = ""
    var act: String
    var det: String = ""
    var price: Int? = nil        // USD (para 2 personas, como en la hoja)
    var cat: String? = nil
    var res: Bool? = nil         // nil = no es una reserva; true/false = estado
    var paid: Bool? = nil
    var link: String? = nil      // enlace de info/booking
    var map: String? = nil       // enlace de Google Maps
    var free: Bool = false       // día/slot libre
    var freeID: String? = nil    // id estable para guardar la elección
    var addedBy: String? = nil   // nombre de quien la agregó (entradas custom); nil = entrada base
    var custom: Bool = false     // true si es una entrada agregada por el usuario

    init(time: String = "", act: String, det: String = "", price: Int? = nil,
         cat: String? = nil, res: Bool? = nil, paid: Bool? = nil,
         link: String? = nil, map: String? = nil, free: Bool = false, freeID: String? = nil) {
        self.time = time; self.act = act; self.det = det; self.price = price
        self.cat = cat; self.res = res; self.paid = paid; self.link = link
        self.map = map; self.free = free; self.freeID = freeID
    }
}

/// Entrada agregada por el usuario (Exe o Mica), sincronizada por la nube.
struct CustomItem: Identifiable, Codable, Hashable {
    var id: String = "cust-" + UUID().uuidString
    var dayID: String
    var time: String = ""
    var act: String
    var det: String = ""
    var price: Int? = nil
    var cat: String? = nil
    var link: String? = nil
    var map: String? = nil
    var addedBy: String = ""
    var createdAt: Date = Date()

    var asItem: ItineraryItem {
        var it = ItineraryItem(time: time, act: act, det: det, price: price,
                               cat: cat, res: false, paid: false, link: link, map: map)
        it.id = id
        it.addedBy = addedBy
        it.custom = true
        return it
    }
}

struct DayPlan: Identifiable, Codable, Hashable {
    var id: String = ""
    var title: String
    var items: [ItineraryItem]
}

struct CityBlock: Identifiable, Codable, Hashable {
    var id: String = ""
    var city: String
    var dates: String
    var image: String
    var loc: String          // London / Oxford / Cotswolds / York / Edinburgh
    var days: [DayPlan]
}

struct ExtraCost: Identifiable, Codable, Hashable {
    var id = UUID()
    var act: String
    var price: Int
    var cat: String
}

// MARK: - Sugerencias

struct Suggestion: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var cost: Int            // USD; 0 = gratis
    var time: String
}

struct MealOption: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var pricePP: Int         // USD por persona
}

struct Idea: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var free: String? = nil
    var cost: String? = nil
    var ai: Bool = false
}

// MARK: - Comidas (estado del usuario)

struct Meal: Codable, Hashable {
    var name: String = ""
    var price: Int? = nil    // USD para 2 personas
    var map: String? = nil
}

struct DayMeals: Codable, Hashable {
    var meals: [String: Meal] = [:]   // clave = MealType.rawValue
}

enum MealType: String, CaseIterable, Identifiable, Codable {
    case desayuno, almuerzo, merienda, cena
    var id: String { rawValue }
    var label: String {
        switch self {
        case .desayuno: return "Desayuno"
        case .almuerzo: return "Almuerzo"
        case .merienda: return "Merienda"
        case .cena:     return "Cena"
        }
    }
    var emoji: String {
        switch self {
        case .desayuno: return "🥐"
        case .almuerzo: return "🍽️"
        case .merienda: return "🫖"
        case .cena:     return "🌙"
        }
    }
}

// MARK: - Snapshot persistible

/// Lo que se guarda en disco (UserDefaults / archivo de respaldo) y se sincroniza en la nube.
struct PersistState: Codable {
    var rateArs: Double = 1500
    var rateGbp: Double = 0.79
    var csvURL: String = ""
    var choices: [String: String] = [:]
    var done: [String: Bool] = [:]
    var reserved: [String: Bool] = [:]
    var links: [String: String] = [:]
    var maps: [String: String] = [:]
    var meals: [String: DayMeals] = [:]
    var added: [String: [CustomItem]] = [:]   // dayID -> entradas agregadas
    var deleted: [String: Bool] = [:]         // itemID -> eliminada
    var updatedAt: Date = .distantPast        // para resolución de conflictos en la sync
}

extension PersistState {
    // Decodificación tolerante: claves faltantes (versiones viejas) usan valores por defecto.
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        rateArs  = try c.decodeIfPresent(Double.self, forKey: .rateArs) ?? 1500
        rateGbp  = try c.decodeIfPresent(Double.self, forKey: .rateGbp) ?? 0.79
        csvURL   = try c.decodeIfPresent(String.self, forKey: .csvURL) ?? ""
        choices  = try c.decodeIfPresent([String: String].self, forKey: .choices) ?? [:]
        done     = try c.decodeIfPresent([String: Bool].self, forKey: .done) ?? [:]
        reserved = try c.decodeIfPresent([String: Bool].self, forKey: .reserved) ?? [:]
        links    = try c.decodeIfPresent([String: String].self, forKey: .links) ?? [:]
        maps     = try c.decodeIfPresent([String: String].self, forKey: .maps) ?? [:]
        meals    = try c.decodeIfPresent([String: DayMeals].self, forKey: .meals) ?? [:]
        added    = try c.decodeIfPresent([String: [CustomItem]].self, forKey: .added) ?? [:]
        deleted  = try c.decodeIfPresent([String: Bool].self, forKey: .deleted) ?? [:]
        updatedAt = try c.decodeIfPresent(Date.self, forKey: .updatedAt) ?? .distantPast
    }
}
