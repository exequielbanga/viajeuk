//
//  BudgetView.swift
//  Pestaña Presupuesto: desglose por categoría + dona.
//

import SwiftUI

struct BudgetView: View {
    @EnvironmentObject var store: AppState

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    SectionHeader(eyebrow: "Las cuentas claras", title: "Presupuesto",
                                  desc: "Desglose para dos personas, en dólares con equivalente en libras y pesos.")

                    let cat = store.budgetByCategory()
                    let total = store.total

                    DonutView(cat: cat, total: total)
                        .frame(height: 230)
                        .frame(maxWidth: .infinity)

                    VStack(spacing: 0) {
                        header
                        ForEach(TripData.categoryOrder, id: \.self) { c in
                            if let v = cat[c], v > 0 {
                                row(c, v, total, isTotal: false)
                                Divider().background(Color.ukCream2)
                            }
                        }
                        row("Total", total, total, isTotal: true)
                    }
                    .background(Color.ukPaper)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.ukCream2, lineWidth: 1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    legend(cat)
                }
                .padding(20)
            }
            .background(Color.ukCream)
            .navigationTitle("Presupuesto")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var header: some View {
        HStack {
            Text("Categoría").font(.system(size: 12, weight: .semibold)).frame(maxWidth: .infinity, alignment: .leading)
            Text("USD").font(.system(size: 12, weight: .semibold)).frame(width: 70, alignment: .trailing)
            Text("ARS").font(.system(size: 12, weight: .semibold)).frame(width: 90, alignment: .trailing)
            Text("%").font(.system(size: 12, weight: .semibold)).frame(width: 36, alignment: .trailing)
        }
        .foregroundColor(Color(red: 0.94,green:0.92,blue:0.85))
        .padding(.horizontal, 12).padding(.vertical, 10)
        .background(Color.ukNavy)
    }

    private func row(_ c: String, _ v: Int, _ total: Int, isTotal: Bool) -> some View {
        let pct = total > 0 ? Int((Double(v) / Double(total) * 100).rounded()) : 0
        return HStack {
            HStack(spacing: 7) {
                if !isTotal {
                    Circle().fill(Color.category(c)).frame(width: 10, height: 10)
                }
                Text(c).font(.system(size: 14, weight: isTotal ? .bold : .regular))
            }.frame(maxWidth: .infinity, alignment: .leading)
            Text(store.usd(v)).font(.system(size: 13, weight: .semibold, design: .serif))
                .foregroundColor(isTotal ? .ukRed : .ukNavy).frame(width: 70, alignment: .trailing)
            Text(store.fmt(Int((Double(v) * store.rateArs).rounded()))).font(.system(size: 12))
                .frame(width: 90, alignment: .trailing)
            Text("\(pct)%").font(.system(size: 13, weight: .semibold)).frame(width: 36, alignment: .trailing)
        }
        .padding(.horizontal, 12).padding(.vertical, 11)
        .background(isTotal ? Color.ukCream2 : Color.clear)
    }

    private func legend(_ cat: [String: Int]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(TripData.categoryOrder, id: \.self) { c in
                if let v = cat[c], v > 0 {
                    HStack(spacing: 8) {
                        RoundedRectangle(cornerRadius: 3).fill(Color.category(c)).frame(width: 12, height: 12)
                        Text("\(c) — \(store.usd(v)) · \(store.conv(v))").font(.system(size: 13))
                        Spacer()
                    }
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.ukPaper)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.ukCream2, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Dona con Canvas
struct DonutView: View {
    @EnvironmentObject var store: AppState
    let cat: [String: Int]
    let total: Int

    var body: some View {
        Canvas { ctx, size in
            let cx = size.width / 2, cy = size.height / 2
            let r = min(cx, cy) - 6
            let rin = r * 0.6
            var start = Angle(degrees: -90)
            for c in TripData.categoryOrder {
                guard let v = cat[c], v > 0, total > 0 else { continue }
                let sweep = Angle(degrees: Double(v) / Double(total) * 360)
                var path = Path()
                path.move(to: CGPoint(x: cx, y: cy))
                path.addArc(center: CGPoint(x: cx, y: cy), radius: r,
                            startAngle: start, endAngle: start + sweep, clockwise: false)
                path.closeSubpath()
                ctx.fill(path, with: .color(Color.category(c)))
                start += sweep
            }
            // agujero
            let hole = Path(ellipseIn: CGRect(x: cx - rin, y: cy - rin, width: rin * 2, height: rin * 2))
            ctx.fill(hole, with: .color(.ukPaper))
            // texto central
            let txt = Text("USD\n\(store.fmt(total / 1000)).\((total % 1000) / 100)k")
                .font(.serifTitle(20)).foregroundColor(.ukNavy)
            ctx.draw(txt, at: CGPoint(x: cx, y: cy), anchor: .center)
        }
    }
}
