//
//  AddEntrySheet.swift
//  Alta de una entrada nueva en un día (indicando quién la agrega).
//

import SwiftUI

struct AddEntrySheet: View {
    @EnvironmentObject var store: AppState
    @Environment(\.dismiss) private var dismiss
    @AppStorage("editorName") private var editorName = ""

    let dayID: String
    let dayTitle: String

    @State private var act = ""
    @State private var time = ""
    @State private var det = ""
    @State private var priceText = ""
    @State private var category = ""        // "" = sin categoría
    @State private var persona = "Juntos"   // Exe / Mica / Juntos

    private let categories = ["", "Actividades", "Comidas", "Transporte", "Alojamiento", "Otros"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Nueva entrada · \(dayTitle)") {
                    TextField("Actividad (ej. Cena de laboratorio)", text: $act)
                    TextField("Hora (ej. 20:00 o «Tarde»)", text: $time)
                    TextField("Detalle (opcional)", text: $det)
                }
                Section("Costo y categoría") {
                    HStack {
                        Text("Precio USD")
                        Spacer()
                        TextField("0", text: $priceText)
                            .keyboardType(.numberPad).multilineTextAlignment(.trailing)
                            .frame(width: 100)
                    }
                    if let p = Int(priceText.filter { $0.isNumber }), p > 0 {
                        Text("≈ \(store.conv(p)) (2 pers.)").font(.caption).foregroundColor(.ukMuted)
                    }
                    Picker("Categoría", selection: $category) {
                        Text("Sin categoría").tag("")
                        ForEach(categories.dropFirst(), id: \.self) { Text($0).tag($0) }
                    }
                }
                Section("¿Para quién es esta actividad?") {
                    Picker("Persona", selection: $persona) {
                        Text("Exe").tag("Exe")
                        Text("Mica").tag("Mica")
                        Text("Juntos").tag("Juntos")
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle("Agregar entrada")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancelar") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Agregar") { add() }
                        .disabled(act.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func add() {
        let name = act.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }
        let price = Int(priceText.filter { $0.isNumber })
        let item = CustomItem(
            dayID: dayID,
            time: time.trimmingCharacters(in: .whitespaces),
            act: name,
            det: det.trimmingCharacters(in: .whitespaces),
            price: (price ?? 0) > 0 ? price : nil,
            cat: category.isEmpty ? nil : category,
            persona: persona,
            addedBy: editorName.isEmpty ? "Exe" : editorName
        )
        store.addEntry(item)
        dismiss()
    }
}
