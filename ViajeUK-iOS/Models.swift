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
    var persona: String? = nil   // "Exe" / "Mica" / "Juntos" (columna Persona de la hoja)
    var addedBy: String? = nil   // nombre de quien la agregó (entradas custom); nil = entrada base
    var custom: Bool = false     // true si es una entrada agregada por el usuario

    init(time: String = "", act: String, det: String = "", price: Int? = nil,
         cat: String? = nil, res: Bool? = nil, paid: Bool? = nil,
         link: String? = nil, map: String? = nil, free: Bool = false, freeID: String? = nil,
         persona: String? = nil) {
        self.time = time; self.act = act; self.det = det; self.price = price
        self.cat = cat; self.res = res; self.paid = paid; self.link = link
        self.map = map; self.free = free; self.freeID = freeID; self.persona = persona
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
    var persona: String = ""
    var addedBy: String = ""
    var createdAt: Date = Date()

    var asItem: ItineraryItem {
        var it = ItineraryItem(time: time, act: act, det: det, price: price,
                               cat: cat, res: false, paid: false, link: link, map: map,
                               persona: persona.isEmpty ? nil : persona)
        it.id = id
        it.addedBy = addedBy
        it.custom = true
        return it
    }
}

/// Edición de una entrada (base o agregada): sobrescribe título, horario, detalle y precio.
struct ItemEdit: Codable, Hashable {
    var act: String? = nil
    var time: String? = nil
    var det: String? = nil
    var price: Int? = nil
    var priceSet: Bool = false   // true => se aplica el precio (puede ser nil = sin precio)
    var persona: String? = nil   // nil => no editada; "" no se usa
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

enum IdeaType: String, CaseIterable, Identifiable, Hashable {
    // Orden de declaración = orden de aparición en la pantalla Ideas
    case mercado, desayuno, almuerzo, merienda, afternoonTea, rooftop, cena, pub
    case museo, visita, espectaculo, parque, mirador, paseo, compras, excursion, experiencia, comida
    var id: String { rawValue }
    var label: String {
        switch self {
        case .mercado:     return "Mercado"
        case .desayuno:    return "Desayuno"
        case .almuerzo:    return "Almuerzo"
        case .merienda:    return "Merienda"
        case .afternoonTea:return "Afternoon tea"
        case .rooftop:     return "Rooftop"
        case .cena:        return "Cena"
        case .pub:         return "Pub"
        case .museo:       return "Museo"
        case .visita:      return "Visita"
        case .espectaculo: return "Espectáculo"
        case .parque:      return "Parque"
        case .mirador:     return "Mirador"
        case .paseo:       return "Paseo"
        case .compras:     return "Compras"
        case .excursion:   return "Excursión"
        case .experiencia: return "Experiencia"
        case .comida:      return "Comida"
        }
    }
    var emoji: String {
        switch self {
        case .mercado:     return "🧺"
        case .desayuno:    return "🥐"
        case .almuerzo:    return "🍽️"
        case .merienda:    return "☕"
        case .afternoonTea:return "🫖"
        case .rooftop:     return "🌆"
        case .cena:        return "🌙"
        case .pub:         return "🍺"
        case .museo:       return "🏛️"
        case .visita:      return "🎟️"
        case .espectaculo: return "🎭"
        case .parque:      return "🌳"
        case .mirador:     return "🔭"
        case .paseo:       return "🚶"
        case .compras:     return "🛍️"
        case .excursion:   return "🚌"
        case .experiencia: return "✨"
        case .comida:      return "🍽️"
        }
    }
}

struct Idea: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var free: String? = nil
    var cost: String? = nil
    var ai: Bool = false
    var city: String = "Londres"
    var type: IdeaType = .visita
    var stars: Double = 0        // 0 = sin dato
    var reviews: Int = 0         // 0 = sin dato
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

// MARK: - Metadatos de notas

/// Quién y cuándo tocó por última vez la nota de una entrada (para resaltar cambios).
struct NoteMeta: Codable, Hashable {
    var by: String = ""        // "Exe" / "Mica"
    var at: Date = Date()      // momento de la última edición
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
    var edits: [String: ItemEdit] = [:]       // itemID -> edición (título/horario/precio/detalle)
    var notes: [String: String] = [:]         // itemID -> nota de texto libre
    var noteMeta: [String: NoteMeta] = [:]    // itemID -> autor + fecha de la última edición de la nota
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
        edits    = try c.decodeIfPresent([String: ItemEdit].self, forKey: .edits) ?? [:]
        notes    = try c.decodeIfPresent([String: String].self, forKey: .notes) ?? [:]
        noteMeta = try c.decodeIfPresent([String: NoteMeta].self, forKey: .noteMeta) ?? [:]
        updatedAt = try c.decodeIfPresent(Date.self, forKey: .updatedAt) ?? .distantPast
    }
}
