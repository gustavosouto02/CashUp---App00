//
//  ExpensesResumoView.swift
//  CashUp
//
//  Created by Gustavo Souto Pereira on 19/05/25.
//

import SwiftUI

struct ExpensesResumoView: View {
    let income: Double
    let expense: Double
    var balance: Double {
        income - expense
    }
    
    private var saldoColor: Color {
        income >= expense ? .green : .red
    }
    
    var body: some View {
        HStack{
            resumoItem(value: income, label: "Renda", color: .primary)
            Spacer()
            resumoItem(value: expense, label: "Despesa", color: .primary)
            Spacer()
            resumoItem(value: balance, label: "Saldo", color: saldoColor)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    private func resumoItem(value: Double, label: String, color: Color) -> some View {
        VStack(alignment: .center, spacing: 4) {
            Text("R$ \(value, specifier: "%.2f")")
                .font(.title3)
                .bold()
                .foregroundStyle(color)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity) // Distribui igualmente e centraliza
    }
}

