//
//  ContentView.swift
//  Estructura principal con pestañas.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: AppState

    var body: some View {
        ZStack(alignment: .top) {
            TabView {
                SummaryView()
                    .tabItem { Label("Resumen", systemImage: "house.fill") }
                ItineraryView()
                    .tabItem { Label("Itinerario", systemImage: "calendar") }
                BudgetView()
                    .tabItem { Label("Presupuesto", systemImage: "chart.pie.fill") }
                IdeasView()
                    .tabItem { Label("Ideas", systemImage: "lightbulb.fill") }
            }
            SavedBanner()
        }
    }
}

#Preview {
    ContentView().environmentObject(AppState())
}
