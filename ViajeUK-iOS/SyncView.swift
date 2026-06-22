//
//  SyncView.swift
//  Hoja de sincronización con Google Sheet.
//

import SwiftUI

struct SyncView: View {
    @EnvironmentObject var store: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var report: String = ""
    @State private var working = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Esta app ya tiene los datos de tu hoja a la fecha de la última sincronización: \(TripData.lastSync). Como tu hoja es privada, la app no puede leerla en vivo por sí sola.")
                        .font(.system(size: 14)).foregroundColor(.ukMuted)

                    optBox(title: "🗣️ Opción simple (recomendada)") {
                        Text("Pedime en el chat: “re-sincronizá la web con el Sheet”. Releo la hoja con tu permiso y actualizo el itinerario, conservando tus comidas y elecciones.")
                            .font(.system(size: 13)).foregroundColor(.ukMuted)
                    }

                    optBox(title: "⚡ Sincronizar en vivo (opcional)") {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Si publicás la hoja (en el Sheet: Archivo → Compartir → Publicar en la web → CSV) y pegás esa URL acá, la app traerá precios, reservas y enlaces directo de la hoja. No toca tus comidas ni elecciones.")
                                .font(.system(size: 13)).foregroundColor(.ukMuted)
                            TextField("URL del CSV publicado…", text: $store.csvURL)
                                .textInputAutocapitalization(.never).keyboardType(.URL)
                                .padding(10).background(Color.white)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.ukCream2, lineWidth: 1))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            Button {
                                Task { await runSync() }
                            } label: {
                                HStack {
                                    if working { ProgressView().tint(.white) }
                                    Text(working ? "Sincronizando…" : "Sincronizar ahora")
                                }
                                .font(.system(size: 14, weight: .semibold)).foregroundColor(.white)
                                .frame(maxWidth: .infinity).padding(.vertical, 11)
                                .background(Color.ukNavy).clipShape(RoundedRectangle(cornerRadius: 9))
                            }
                            .disabled(working)
                            if !report.isEmpty {
                                Text(report).font(.system(size: 13)).foregroundColor(.ukNavy)
                            }
                        }
                    }
                }
                .padding(20)
            }
            .background(Color.ukCream)
            .navigationTitle("Sincronizar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Cerrar") { dismiss() } } }
        }
    }

    private func runSync() async {
        working = true; report = ""
        let result = await store.syncFromCSV()
        working = false
        switch result {
        case .ok(let updated, let unmatched):
            report = "✓ Sincronizado. \(updated) entradas actualizadas" +
                (unmatched > 0 ? " · \(unmatched) filas sin coincidencia (pedime que las agregue)." : ".")
        case .failure(let msg):
            report = "❌ No se pudo leer la hoja (\(msg)). Verificá que esté publicada como CSV y la URL. Tus cambios locales están a salvo."
        }
    }

    private func optBox<Content: View>(title: String, @ViewBuilder _ content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.serifTitle(16, weight: .semibold)).foregroundColor(.ukNavy)
            content()
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.ukCream)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.ukCream2, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
