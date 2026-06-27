//
//  Theme.swift
//  Paleta "británico clásico": navy / rojo / crema / dorado.
//

import SwiftUI

extension Color {
    static let ukNavy  = Color(red: 0.067, green: 0.141, blue: 0.243)
    static let ukNavy2 = Color(red: 0.106, green: 0.200, blue: 0.345)
    static let ukRed   = Color(red: 0.545, green: 0.118, blue: 0.176)
    static let ukRed2  = Color(red: 0.659, green: 0.169, blue: 0.231)
    static let ukCream = Color(red: 0.965, green: 0.945, blue: 0.894)
    static let ukCream2 = Color(red: 0.937, green: 0.906, blue: 0.827)
    static let ukPaper = Color(red: 1.000, green: 0.992, blue: 0.973)
    static let ukGold  = Color(red: 0.761, green: 0.631, blue: 0.302)
    static let ukGold2 = Color(red: 0.847, green: 0.741, blue: 0.451)
    static let ukGreen = Color(red: 0.184, green: 0.420, blue: 0.275)
    static let ukGreenPastel = Color(red: 0.808, green: 0.902, blue: 0.808)   // verde pastel (fondo)
    static let ukGreenDeep   = Color(red: 0.137, green: 0.365, blue: 0.231)   // verde oscuro (texto/icono)
    static let ukMuted = Color(red: 0.416, green: 0.384, blue: 0.337)
    static let ukBrown = Color(red: 0.659, green: 0.388, blue: 0.169)

    static func category(_ c: String) -> Color {
        switch c {
        case "Vuelos":      return .ukRed
        case "Alojamiento": return .ukNavy
        case "Transporte":  return .ukGold
        case "Actividades": return .ukGreen
        case "Comidas":     return .ukBrown
        default:            return .ukMuted
        }
    }

    /// Color por persona (Exe / Mica / Juntos).
    static func persona(_ p: String) -> Color {
        switch p.lowercased() {
        case "exe":              return .ukNavy
        case "mica":             return .ukRed2
        case "juntos", "ambos":  return .ukGreen
        default:                 return .ukMuted
        }
    }
}

/// Datos de presentación de una persona (ícono + color).
enum PersonaStyle {
    static func icon(_ p: String) -> String {
        switch p.lowercased() {
        case "juntos", "ambos": return "person.2.fill"
        default:                return "person.fill"
        }
    }
    /// Etiqueta canónica con mayúscula inicial.
    static func label(_ p: String) -> String {
        let t = p.trimmingCharacters(in: .whitespaces)
        guard let f = t.first else { return t }
        return f.uppercased() + t.dropFirst().lowercased()
    }
}

/// Tipografías tipo "Playfair / serif" usando las del sistema (serif) para títulos.
extension Font {
    static func serifTitle(_ size: CGFloat, weight: Font.Weight = .bold) -> Font {
        .system(size: size, weight: weight, design: .serif)
    }
}
