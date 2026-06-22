//
//  SharedComponents.swift
//  Componentes reutilizables.
//

import SwiftUI

/// Imagen de ciudad con degradado de respaldo.
struct CityImage: View {
    let url: String
    var height: CGFloat = 190
    var body: some View {
        AsyncImage(url: URL(string: url)) { phase in
            switch phase {
            case .success(let img): img.resizable().scaledToFill()
            case .empty: ZStack { gradient; ProgressView().tint(.white) }
            default: gradient
            }
        }
        .frame(height: height)
        .frame(maxWidth: .infinity)
        .clipped()
    }
    private var gradient: some View {
        LinearGradient(colors: [.ukNavy2, .ukNavy], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

/// Chip de precio con conversión a £ y ARS.
struct PriceChip: View {
    @EnvironmentObject var store: AppState
    let amount: Int
    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(store.usd(amount)).font(.system(size: 12, weight: .semibold))
                .foregroundColor(.ukNavy)
            Text(store.conv(amount)).font(.system(size: 10))
                .foregroundColor(.ukMuted)
        }
        .padding(.horizontal, 9).padding(.vertical, 4)
        .background(Color.ukCream2)
        .clipShape(RoundedRectangle(cornerRadius: 9))
    }
}

/// Etiqueta de texto tipo pill.
struct TagPill: View {
    let text: String
    var fg: Color = .ukMuted
    var bg: Color = Color.ukCream2
    var border: Color = Color.ukCream2
    var body: some View {
        Text(text).font(.system(size: 11, weight: .semibold))
            .foregroundColor(fg)
            .padding(.horizontal, 9).padding(.vertical, 3)
            .background(bg)
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(border, lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

/// Banner flotante "Guardado ✓".
struct SavedBanner: View {
    @EnvironmentObject var store: AppState
    var body: some View {
        VStack {
            if store.savedFlash {
                Text("Guardado ✓")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16).padding(.vertical, 8)
                    .background(Color.ukNavy)
                    .clipShape(Capsule())
                    .shadow(radius: 6)
                    .transition(.move(edge: .top).combined(with: .opacity))
                Spacer()
            }
        }
        .padding(.top, 8)
        .animation(.easeInOut(duration: 0.25), value: store.savedFlash)
        .allowsHitTesting(false)
    }
}

/// Encabezado de sección.
struct SectionHeader: View {
    let eyebrow: String
    let title: String
    var desc: String? = nil
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(eyebrow.uppercased())
                .font(.system(size: 12, weight: .semibold))
                .tracking(2).foregroundColor(.ukRed)
            Text(title).font(.serifTitle(26)).foregroundColor(.ukNavy)
            if let desc { Text(desc).font(.system(size: 14)).foregroundColor(.ukMuted) }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// Editor de enlace/URL con alerta.
struct LinkEditor: ViewModifier {
    @Binding var isPresented: Bool
    let title: String
    @Binding var text: String
    let onSave: (String) -> Void
    func body(content: Content) -> some View {
        content.alert(title, isPresented: $isPresented) {
            TextField("https://…", text: $text)
                .textInputAutocapitalization(.never)
                .keyboardType(.URL)
            Button("Guardar") { onSave(text) }
            Button("Borrar", role: .destructive) { onSave("") }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("Pegá el enlace (vacío = borrar).")
        }
    }
}

extension View {
    func linkEditor(isPresented: Binding<Bool>, title: String, text: Binding<String>, onSave: @escaping (String) -> Void) -> some View {
        modifier(LinkEditor(isPresented: isPresented, title: title, text: text, onSave: onSave))
    }
}
