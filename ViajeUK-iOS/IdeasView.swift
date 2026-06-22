//
//  IdeasView.swift
//  Pestaña Ideas: actividades potenciales (con badge AI) + pubs.
//

import SwiftUI

struct IdeasView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    SectionHeader(eyebrow: "Para los días libres", title: "Actividades potenciales",
                                  desc: "Ideas de tu lista más sugerencias mías (marcadas AI). Muchos museos de Londres son gratis. En el itinerario, cada día libre tiene un menú con todas estas opciones.")

                    group("🎟️ Londres & alrededores", TripData.ideasLondon)
                    group("🏰 Escapadas de un día", TripData.ideasTrips)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Pubs de Londres").font(.serifTitle(20)).foregroundColor(.ukNavy)
                        FlowLayout(spacing: 8, lineSpacing: 8) {
                            ForEach(TripData.pubs, id: \.self) { p in
                                pill { Text("🍺 \(p)").font(.system(size: 13)) }
                            }
                        }
                    }
                }
                .padding(20)
            }
            .background(Color.ukCream2)
            .navigationTitle("Ideas")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func group(_ title: String, _ ideas: [Idea]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).font(.serifTitle(20)).foregroundColor(.ukNavy)
            FlowLayout(spacing: 8, lineSpacing: 8) {
                ForEach(ideas) { idea in
                    pill(ai: idea.ai) {
                        HStack(spacing: 5) {
                            if idea.ai {
                                Text("AI").font(.system(size: 9, weight: .bold)).tracking(0.5)
                                    .foregroundColor(.ukGold2)
                                    .padding(.horizontal, 5).padding(.vertical, 1)
                                    .background(Color.ukNavy).clipShape(RoundedRectangle(cornerRadius: 5))
                            }
                            Text(idea.name).font(.system(size: 13, weight: .medium)).foregroundColor(.ukNavy)
                            if let f = idea.free {
                                Text(f).font(.system(size: 12, weight: .semibold)).foregroundColor(.ukGreen)
                            }
                            if let c = idea.cost {
                                Text(c).font(.system(size: 12, weight: .semibold)).foregroundColor(.ukRed)
                            }
                        }
                    }
                }
            }
        }
    }

    private func pill<Content: View>(ai: Bool = false, @ViewBuilder _ content: () -> Content) -> some View {
        content()
            .padding(.horizontal, 14).padding(.vertical, 9)
            .background(ai ? Color(red: 0.992, green: 0.980, blue: 0.941) : Color.ukPaper)
            .overlay(Capsule().stroke(ai ? Color.ukGold : Color.ukCream2, lineWidth: 1))
            .clipShape(Capsule())
    }
}
