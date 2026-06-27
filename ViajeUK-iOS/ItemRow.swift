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
    @State private var showEdit = false
    @State private var showNotes = false

    private var done: Bool { store.isDone(item.id) }

    private enum Travel { case plane, train }
    private var travel: Travel? {
        let a = item.act.lowercased()
        if item.cat == "Vuelos" || a.contains("vuelo") || a.contains("avión") || a.contains("avion") {
            return .plane
        }
        if a.contains("tren") || a.contains("train") || item.cat == "Transporte" {
            return .train
        }
        return nil
    }
    private var travelColor: Color { .ukGold }   // vuelos y trenes con el mismo color

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Button { store.setDone(item.id, !done) } label: {
                Image(systemName: done ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(done ? .ukGreen : Color.ukMuted.opacity(0.5))
                    .font(.system(size: 22))
            }
            .buttonStyle(.plain)
            .padding(.top, 1)

            VStack(alignment: .leading, spacing: 7) {
                // Línea de título: horario (pill) + actividad + insignias
                HStack(alignment: .top, spacing: 8) {
                    if !item.time.isEmpty { timePill }
                    if let t = travel {
                        Image(systemName: t == .plane ? "airplane" : "tram.fill")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(travelColor)
                            .padding(.top, 1)
                    }
                    Text(item.act)
                        .font(.system(size: 16.5, weight: .semibold))
                        .strikethrough(done, color: .ukMuted)
                        .foregroundColor(done ? .ukMuted : .primary)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer(minLength: 8)
                    let per = store.persona(item)
                    if !per.isEmpty { personaChip(per) }
                    if let by = item.addedBy, !by.isEmpty {
                        Label(by, systemImage: "person.fill")
                            .labelStyle(.titleAndIcon)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.ukRed)
                            .padding(.horizontal, 6).padding(.vertical, 1)
                            .background(Color.ukRed.opacity(0.10))
                            .clipShape(Capsule())
                            .padding(.top, 2)
                    }
                }
                if !item.det.isEmpty {
                    Text(item.det).font(.system(size: 14)).foregroundColor(.ukMuted)
                        .fixedSize(horizontal: false, vertical: true)
                }
                metaRow
                if store.hasNote(item.id) { notePreview }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 11)
        .padding(.horizontal, travel != nil ? 10 : 0)
        .background(
            Group {
                if travel != nil {
                    travelColor.opacity(0.08)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(travelColor)
                                .frame(width: 3)
                                .padding(.vertical, 6)
                        }
                }
            }
        )
        .contextMenu {
            Button { showEdit = true } label: { Label("Editar entrada", systemImage: "square.and.pencil") }
            Button { openNotes() } label: { Label("Notas", systemImage: "note.text") }
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
        .sheet(isPresented: $showEdit) { EditEntrySheet(item: item) }
        .sheet(isPresented: $showNotes) { NotesSheet(item: item) }
    }

    private func personaChip(_ p: String) -> some View {
        let c = Color.persona(p)
        return Label(PersonaStyle.label(p), systemImage: PersonaStyle.icon(p))
            .labelStyle(.titleAndIcon)
            .font(.system(size: 9.5, weight: .bold))
            .foregroundColor(c)
            .padding(.horizontal, 6).padding(.vertical, 1)
            .background(c.opacity(0.10))
            .overlay(Capsule().stroke(c.opacity(0.35), lineWidth: 1))
            .clipShape(Capsule())
            .padding(.top, 2)
    }

    private var timePill: some View {
        let parts = item.time.components(separatedBy: "–")
        return VStack(spacing: 0) {
            Text(parts[0]).font(.system(size: 13.5, weight: .bold, design: .serif))
            if parts.count > 1 {
                Text(parts[1]).font(.system(size: 11, weight: .medium))
                    .foregroundColor(.ukGold2)
            }
        }
        .foregroundColor(.white)
        .padding(.horizontal, 9).padding(.vertical, parts.count > 1 ? 4 : 6)
        .background(Color.ukNavy)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var metaRow: some View {
        FlowLayout(spacing: 10) {
            if let p = item.price { PriceChip(amount: p) }
            if item.paid == true { TagPill(text: "Pagado", fg: .ukNavy2, bg: Color(red: 0.93,green:0.94,blue:0.96), border: Color(red: 0.87,green:0.89,blue:0.93)) }
            linkButton
            mapButton
            notesButton
        }
    }

    private var notesButton: some View {
        let has = store.hasNote(item.id)
        let unseen = store.noteIsUnseen(item.id)
        return Button { openNotes() } label: {
            HStack(spacing: 5) {
                Image(systemName: has ? "note.text" : "note.text.badge.plus")
                Text(unseen ? "Nota nueva" : "Notas")
            }
            .font(.system(size: 14.5, weight: .semibold))
            .foregroundColor(unseen ? .ukRed : (has ? .ukBrown : .ukMuted))
            .padding(.horizontal, 13).padding(.vertical, 8)
            .background(unseen ? Color.ukRed.opacity(0.10) : (has ? Color.ukBrown.opacity(0.10) : .clear))
            .overlay(Capsule().stroke(unseen ? Color.ukRed.opacity(0.55) : (has ? Color.ukBrown.opacity(0.4) : Color.ukCream2), lineWidth: unseen ? 1.5 : 1))
            .clipShape(Capsule())
            .overlay(alignment: .topTrailing) {
                if unseen {
                    Circle().fill(Color.ukRed).frame(width: 8, height: 8)
                        .overlay(Circle().stroke(.white, lineWidth: 1.5))
                        .offset(x: 3, y: -3)
                }
            }
        }.buttonStyle(.plain)
    }

    /// Abre el editor de notas y marca la nota como vista por este usuario.
    private func openNotes() {
        showNotes = true
        store.markNoteSeen(item.id)
    }

    /// Texto "Actualizada por X · hace…" para el encabezado de la nota.
    private var noteByline: String? {
        let by = store.noteAuthor(item.id)
        guard !by.isEmpty, let at = store.noteUpdatedAt(item.id) else { return nil }
        let rel = Self.relFmt.localizedString(for: at, relativeTo: Date())
        return "\(by) · \(rel)"
    }
    private static let relFmt: RelativeDateTimeFormatter = {
        let f = RelativeDateTimeFormatter(); f.locale = Locale(identifier: "es"); f.unitsStyle = .short
        return f
    }()

    private var editButton: some View {
        Button { showEdit = true } label: {
            HStack(spacing: 4) {
                Image(systemName: "square.and.pencil")
                Text("Editar")
            }
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(.ukNavy)
            .padding(.horizontal, 9).padding(.vertical, 4)
            .overlay(Capsule().stroke(Color.ukCream2, lineWidth: 1))
            .clipShape(Capsule())
        }.buttonStyle(.plain)
    }

    private var notePreview: some View {
        let unseen = store.noteIsUnseen(item.id)
        let accent: Color = unseen ? .ukRed : .ukBrown
        let by = store.noteAuthor(item.id)
        return Button { openNotes() } label: {
            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 6) {
                    Image(systemName: unseen ? "sparkles" : "note.text")
                        .font(.system(size: 11, weight: .semibold)).foregroundColor(accent)
                    if unseen && !by.isEmpty {
                        Text("\(by) actualizó esta nota")
                            .font(.system(size: 11.5, weight: .bold)).foregroundColor(accent)
                    } else if let byline = noteByline {
                        Text("Nota · \(byline)")
                            .font(.system(size: 11, weight: .semibold)).foregroundColor(.ukMuted)
                    }
                    Spacer(minLength: 0)
                    if unseen {
                        Text("NUEVO").font(.system(size: 8.5, weight: .black)).tracking(0.5)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6).padding(.vertical, 2)
                            .background(Color.ukRed).clipShape(Capsule())
                    }
                }
                Text(store.note(item.id))
                    .font(.system(size: 13.5)).italic()
                    .foregroundColor(unseen ? .primary : .ukMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(9)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(accent.opacity(unseen ? 0.10 : 0.06))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(accent.opacity(unseen ? 0.55 : 0.18), lineWidth: unseen ? 1.5 : 1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }.buttonStyle(.plain)
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
                HStack(spacing: 5) {
                    Link(destination: URL(string: v) ?? URL(string: "https://google.com")!) {
                        Text("Ver enlace ↗")
                            .font(.system(size: 14.5, weight: .semibold)).foregroundColor(.ukRed)
                            .padding(.horizontal, 13).padding(.vertical, 8)
                            .overlay(Capsule().stroke(Color.ukRed.opacity(0.35), lineWidth: 1))
                            .clipShape(Capsule())
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
                HStack(spacing: 5) {
                    Link(destination: URL(string: v) ?? URL(string: suggested)!) {
                        Text("📍 Maps")
                            .font(.system(size: 14.5, weight: .semibold)).foregroundColor(.ukNavy)
                            .padding(.horizontal, 13).padding(.vertical, 8)
                            .overlay(Capsule().stroke(Color.ukNavy.opacity(0.30), lineWidth: 1))
                            .clipShape(Capsule())
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
            Image(systemName: "pencil").font(.system(size: 12))
                .foregroundColor(.ukMuted)
                .padding(.horizontal, 7).padding(.vertical, 6)
                .overlay(RoundedRectangle(cornerRadius: 7).stroke(Color.ukCream2, lineWidth: 1))
        }.buttonStyle(.plain)
    }
    private func addButton(_ label: String, _ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label).font(.system(size: 13.5, weight: .medium)).foregroundColor(.ukMuted)
                .padding(.horizontal, 12).padding(.vertical, 7)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.ukCream2, style: StrokeStyle(lineWidth: 1, dash: [3])))
        }.buttonStyle(.plain)
    }

}

// MARK: - Editar entrada (título / horario / detalle / precio)
struct EditEntrySheet: View {
    @EnvironmentObject var store: AppState
    @Environment(\.dismiss) private var dismiss
    let item: ItineraryItem

    @State private var act: String
    @State private var time: String
    @State private var det: String
    @State private var priceText: String
    @State private var persona: String

    init(item: ItineraryItem) {
        self.item = item
        _act = State(initialValue: item.act)
        _time = State(initialValue: item.time)
        _det = State(initialValue: item.det)
        _priceText = State(initialValue: item.price.map(String.init) ?? "")
        _persona = State(initialValue: (item.persona?.isEmpty == false) ? item.persona! : "Juntos")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Editar entrada") {
                    TextField("Título", text: $act)
                    TextField("Horario (ej. 09:00 o 09:00–11:00)", text: $time)
                    TextField("Detalle (opcional)", text: $det, axis: .vertical)
                }
                Section("¿Para quién es esta actividad?") {
                    Picker("Persona", selection: $persona) {
                        Text("Exe").tag("Exe")
                        Text("Mica").tag("Mica")
                        Text("Juntos").tag("Juntos")
                    }
                    .pickerStyle(.segmented)
                }
                Section("Precio (USD · 2 pers.)") {
                    HStack {
                        Text("Precio USD")
                        Spacer()
                        TextField("—", text: $priceText)
                            .keyboardType(.numberPad).multilineTextAlignment(.trailing)
                            .frame(width: 100)
                    }
                    if let p = Int(priceText.filter { $0.isNumber }), p > 0 {
                        Text("≈ \(store.conv(p))").font(.caption).foregroundColor(.ukMuted)
                    } else {
                        Text("Dejalo vacío para una entrada sin costo.").font(.caption).foregroundColor(.ukMuted)
                    }
                }
            }
            .navigationTitle("Editar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancelar") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") { save() }
                        .disabled(act.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func save() {
        let normTime = time
            .replacingOccurrences(of: " a ", with: "–")
            .replacingOccurrences(of: " - ", with: "–")
            .replacingOccurrences(of: " – ", with: "–")
            .trimmingCharacters(in: .whitespaces)
        let p = Int(priceText.filter { $0.isNumber })
        store.setEdit(item.id,
                      act: act.trimmingCharacters(in: .whitespaces),
                      time: normTime,
                      det: det.trimmingCharacters(in: .whitespaces),
                      price: (p ?? 0) > 0 ? p : nil,
                      persona: persona)
        dismiss()
    }
}

// MARK: - Notas de la entrada (texto libre compartido)
struct NotesSheet: View {
    @EnvironmentObject var store: AppState
    @Environment(\.dismiss) private var dismiss
    let item: ItineraryItem

    @State private var text: String

    init(item: ItineraryItem) {
        self.item = item
        _text = State(initialValue: "")
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(item.act).font(.serifTitle(18, weight: .semibold)).foregroundColor(.ukNavy)
                let by = store.noteAuthor(item.id)
                if !by.isEmpty, let at = store.noteUpdatedAt(item.id) {
                    Label("Última edición: \(by) · \(at.formatted(date: .abbreviated, time: .shortened))",
                          systemImage: "clock.arrow.circlepath")
                        .font(.system(size: 12)).foregroundColor(.ukMuted)
                }
                Text("Nota compartida — la pueden editar Exe y Mica.")
                    .font(.system(size: 13)).foregroundColor(.ukMuted)
                TextEditor(text: $text)
                    .font(.system(size: 16))
                    .padding(8)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.ukCream2, lineWidth: 1))
                    .frame(minHeight: 220)
            }
            .padding(16)
            .navigationTitle("Notas")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancelar") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") { store.setNote(item.id, text); dismiss() }
                }
            }
            .onAppear { text = store.note(item.id); store.markNoteSeen(item.id) }
        }
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
