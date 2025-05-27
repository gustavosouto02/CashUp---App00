//
//  ResumoDespesasCardView.swift
//  CashUp
//
//  Created by Gustavo Souto Pereira on 27/05/25.
//

import SwiftUI
import Charts

struct ResumoDespesasCardView: View {
    var categoriasResumo: [CategoriaResumo]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Resumo de Despesas")
                .font(.headline)

            // Gráfico de Pizza
            Chart {
                ForEach(categoriasResumo) { item in
                    SectorMark(
                        angle: .value("Total", item.percentual),
                        innerRadius: .ratio(0.6),
                        angularInset: 1.5
                    )
                    .foregroundStyle(item.categoria.color)
                }
            }
            .frame(height: 150)

            // Lista de Categorias
            ForEach(categoriasResumo.prefix(3)) { item in
                HStack {
                    Rectangle()
                        .fill(item.categoria.color)
                        .frame(width: 10, height: 10)
                        .cornerRadius(2)

                    Text(item.categoria.nome)
                        .font(.subheadline)

                    Spacer()

                    Text(String(format: "%.0f%%", item.percentual * 100))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            if categoriasResumo.count > 3 {
                HStack {
                    Rectangle()
                        .fill(Color.gray)
                        .frame(width: 10, height: 10)
                        .cornerRadius(2)

                    Text("Outras")
                        .font(.subheadline)

                    Spacer()

                    let outrasPercent = categoriasResumo.dropFirst(3).map { $0.percentual }.reduce(0, +)
                    Text(String(format: "%.0f%%", outrasPercent * 100))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
        .padding(.horizontal)
    }
}
