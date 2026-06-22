//
//  ItemRow.swift
//  Fila de actividad + selector de día libre.
//

import SwiftUI

struct ItemRowView: View {
    @EnvironmentObject var store: AppState
    let item: ItineraryItem
    let loc: String

    @State private var editingLink = false
    @State private var editingMap = false
    @State private var linkText = ""
    @State private var mapText = ""
    @State private var showPicker = false

    private var done: Bool { store.isDone(item.id) }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Button { store.setDone(item.id, !done) } label: {
                Image(systemName: done ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(done ? .ukGreen : Color.ukMuted.opacity(0.5))
                    .font(.system(size: 20))
            }
            .buttonStyle(.plain)
            .padding(.top, 2)

            if !item.time.isEmpty {
                timeView.frame(width: 66, alignment: .leading)
            }

            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 6) {
                    Text(item.act)
                        .font(.system(size: 15, weight: .semibold))
                        .strikethrough(done, color: .ukMuted)
                        .foregroundColor(done ? .ukMuted : .primary)
                    if item.free {
                        Text("DÍA LIBRE").font(.system(size: 9, weight: .bold)).tracking(0.5)
                            .foregroundColor(.ukGold)
                            .padding(.horizontal, 7).padding(.vertical, 1)
                            .overlay(Capsule().stroke(Color.ukGold, lineWidth: 1))
                    }
                    if let by = item.addedBy, !by.isEmpty {
                        Label(by, systemImage: "person.fill")
                            .labelStyle(.titleAndIcon)
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.ukRed)
                            .padding(.horizontal, 6).padding(.vertical, 1)
                            .background(Color.ukRed.opacity(0.10))
                            .clipShape(Capsule())
                    }
                }
                if !item.det.isEmpty {
                    Text(item.det).font(.system(size: 13)).foregroundColor(.ukMuted)
                }
                metaRow
                if item.free, let fid = item.freeID { freeSlot(fid) }
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 9)
        .contextMenu {
            Button { store.setDone(item.id, !done) } label: {
                Label(done ? "Marcar como pendiente" : "Marcar como hecho",
                      systemImage: done ? "arrow.uturn.backward" : "checkmark")
            }
            Button(role: .destructive) { store.deleteItem(item.id) } label: {
                Label("Eliminar entrada", systemImage: "trash")
            }
        }
        .linkEditor(isPresented: $editingLink, title: "Enlace", text: $linkText) { store.setLink(item, $0) }
        .linkEditor(isPresented: $editingMap, title: "Google Maps", text: $mapText) { store.setMap(item, $0) }
        .sheet(isPresented: $showPicker) {
            SuggestionPickerSheet(freeID: item.freeID ?? "", current: store.choice(item.freeID ?? ""))
        }
    }

    private var timeView: some View {
        let parts = item.time.components(separatedBy: "–")
        return VStack(alignment: .leading, spacing: 0) {
            Text(parts[0]).font(.system(size: 13, weight: .semibold, design: .serif)).foregroundColor(.ukNavy)
            if parts.count > 1 {
                Text("a \(parts[1])").font(.system(size: 11)).foregroundColor(.ukMuted)
            }
        }
    }

    private var metaRow: some View {
        FlowLayout(spacing: 8) {
            if let p = item.price { PriceChip(amount: p) }
            if let c = item.cat { TagPill(text: c, fg: .ukMuted, bg: .clear, border: Color.ukCream2) }
            if item.res != nil { reservedToggle }
            if item.paid == true { TagPill(text: "Pagado", fg: .ukNavy2, bg: Color(red: 0.93,green:0.94,blue:0.96), border: Color(red: 0.87,green:0.89,blue:0.93)) }
            linkButton
            mapButton
        }
    }

    private var reservedToggle: some View {
        let on = store.effReserved(item)
        return Button {
            store.setReserved(item, !on)
        } label: {
            HStack(spacing: 4) {
                Image(systemName: on ? "checkmark.square.fill" : "square")
                Text(on ? "Reservado" : "Sin reservar")
            }
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(on ? .ukGreen : .ukRed)
            .padding(.horizontal, 9).padding(.vertical, 3)
            .background(on ? Color(red: 0.906,green:0.941,blue:0.918) : Color(red: 0.984,green:0.918,blue:0.925))
            .overlay(Capsule().stroke(on ? Color.ukGreen.opacity(0.4) : Color.ukRed.opacity(0.3), lineWidth: 1))
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private var linkButton: some View {
        let v = store.effLink(item)
        return Group {
            if !v.isEmpty {
                HStack(spacing: 4) {
                    Link(destination: URL(string: v) ?? URL(string: "https://google.com")!) {
                        Text("Ver enlace ↗").font(.system(size: 12, weight: .semibold)).foregroundColor(.ukRed)
                    }
                    editPencil { linkText = v; editingLink = true }
                }
            } else {
                addButton("+ enlace") { linkText = ""; editingLink = true }
            }
        }
    }

    private var mapButton: some View {
        let v = store.effMap(item)
        let suggested = store.gmaps("\(item.act) \(loc)")
        return Group {
            if !v.isEmpty {
                HStack(spacing: 4) {
                    Link(destination: URL(string: v) ?? URL(string: suggested)!) {
                        Text("📍 Maps").font(.system(size: 12, weight: .semibold)).foregroundColor(.ukNavy)
                    }
                    editPencil { mapText = v; editingMap = true }
                }
            } else {
                addButton("+ 📍 Maps") { mapText = suggested; editingMap = true }
            }
        }
    }

    private func editPencil(_ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: "pencil").font(.system(size: 10))
                .foregroundColor(.ukMuted)
                .padding(.horizontal, 5).padding(.vertical, 3)
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.ukCream2, lineWidth: 1))
        }.buttonStyle(.plain)
    }
    private func addButton(_ label: String, _ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label).font(.system(size: 11, weight: .medium)).foregroundColor(.ukMuted)
                .padding(.horizontal, 8).padding(.vertical, 3)
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.ukCream2, style: StrokeStyle(lineWidth: 1, dash: [3])))
        }.buttonStyle(.plain)
    }

    private func freeSlot(_ fid: String) -> some View {
        let chosen = store.choice(fid)
        return VStack(alignment: .leading, spacing: 6) {
            Button { showPicker = true } label: {
                Label(chosen.isEmpty ? "Elegir actividad" : "Cambiar actividad", systemImage: "wand.and.stars")
                    .font(.system(size: 13, weight: .semibold)).foregroundColor(.white)
                    .padding(.horizontal, 12).padding(.vertical, 7)
                    .background(Color.ukNavy).clipShape(RoundedRectangle(cornerRadius: 8))
            }
            Text(chosen.isEmpty ? "Todavía sin elegir — ¡vos decidís!" : "✓ Plan elegido: \(chosen)")
                .font(.system(size: 13, weight: chosen.isEmpty ? .regular : .semibold))
                .foregroundColor(chosen.isEmpty ? .ukMuted : .ukGreen)
        }
        .padding(.top, 4)
    }
}

// MARK: - Sheet de selección de sugerencias
struct SuggestionPickerSheet: View {
    @EnvironmentObject var store: AppState
    @Environment(\.dismiss) private var dismiss
    let freeID: String
    let current: String

    @State private var search = ""
    @State private var custom = ""

    private var filtered: [Suggestion] {
        if search.isEmpty { return TripData.suggestions }
        return TripData.suggestions.filter { $0.name.localizedCaseInsensitiveContains(search) }
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Tu propio plan") {
                    HStack {
                        TextField("Escribí una actividad…", text: $custom)
                        Button("Usar") {
                            let v = custom.trimmingCharacters(in: .whitespaces)
                            if !v.isEmpty { store.setChoice(freeID, v); dismiss() }
                        }.disabled(custom.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
                Section("Sugerencias (AI · marcadas por la IA)") {
                    ForEach(filtered) { s in
                        Button {
                            let cost = s.cost > 0 ? "USD \(s.cost)" : "gratis"
                            store.setChoice(freeID, "\(s.name) (\(cost), \(s.time))")
                            dismiss()
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(s.name).foregroundColor(.primary)
                                    Text("\(s.cost > 0 ? store.usd(s.cost) + " · " + store.conv(s.cost) : "Gratis") · \(s.time)")
                                        .font(.caption).foregroundColor(.ukMuted)
                                }
                                Spacer()
                            }
                        }
                    }
                }
            }
            .searchable(text: $search, prompt: "Buscar actividad")
            .navigationTitle("Elegir actividad")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cerrar") { dismiss() } }
                if !current.isEmpty {
                    ToolbarItem(placement: .destructiveAction) {
                        Button("Quitar", role: .destructive) { store.setChoice(freeID, ""); dismiss() }
                    }
                }
            }
        }
    }
}
