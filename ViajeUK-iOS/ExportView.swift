//
//  ExportView.swift
//  Hoja para exportar cambios (copiar / compartir).
//

import SwiftUI
import UIKit

struct ExportView: View {
    @EnvironmentObject var store: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var copied = false

    var body: some View {
        NavigationStack {
            let text = store.buildExport()
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    Text("Copiá este texto y pegalo en tu Google Sheet, o compartilo. Incluye días libres, comidas, reservas/enlaces modificados y lo marcado como hecho.")
                        .font(.system(size: 14)).foregroundColor(.ukMuted)

                    Text(text)
                        .font(.system(size: 12, design: .monospaced))
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .background(Color.white)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.ukCream2, lineWidth: 1))
                        .clipShape(RoundedRectangle(cornerRadius: 10))

                    HStack(spacing: 10) {
                        Button {
                            UIPasteboard.general.string = text
                            copied = true
                        } label: {
                            Label(copied ? "Copiado ✓" : "Copiar", systemImage: "doc.on.doc")
                                .font(.system(size: 14, weight: .semibold)).foregroundColor(.white)
                                .frame(maxWidth: .infinity).padding(.vertical, 11)
                                .background(Color.ukNavy).clipShape(RoundedRectangle(cornerRadius: 9))
                        }
                        ShareLink(item: text) {
                            Label("Compartir", systemImage: "square.and.arrow.up")
                                .font(.system(size: 14, weight: .semibold)).foregroundColor(.ukNavy)
                                .frame(maxWidth: .infinity).padding(.vertical, 11)
                                .background(Color.ukGold).clipShape(RoundedRectangle(cornerRadius: 9))
                        }
                    }
                }
                .padding(20)
            }
            .background(Color.ukCream)
            .navigationTitle("Exportar cambios")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Cerrar") { dismiss() } } }
        }
    }
}
