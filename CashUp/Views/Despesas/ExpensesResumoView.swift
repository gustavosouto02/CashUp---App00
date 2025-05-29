//
//  ExpensesResumoView.swift
//  CashUp
//
//  Created by Gustavo Souto Pereira on 19/05/25.
//

// Arquivo: CashUp/Views/Despesas/ExpensesResumoView.swift
// Praticamente inalterado, pois já recebe valores. A fonte dos valores mudou no ViewModel.

import SwiftUI

struct ExpensesResumoView: View {
    let income: Double
    let expense: Double
    var balance: Double {
        income - expense
    }
    
    private var saldoColor: Color {
        // Pequena correção: se income for igual a expense, pode ser primário ou verde.
        // Se o saldo for negativo, vermelho.
        if balance == 0 {
            return .primary // ou .gray, .orange, etc.
        }
        return balance > 0 ? .green : .red
    }
    
    var body: some View {
        HStack{
            resumoItem(value: income, label: "Renda", color: .green) // Cor explícita para renda
            Spacer()
            resumoItem(value: expense, label: "Despesa", color: .red) // Cor explícita para despesa
            Spacer()
            resumoItem(value: balance, label: "Saldo", color: saldoColor)
        }
        .padding()
        .background(Color(.secondarySystemBackground)) // Cor do sistema para adaptabilidade
        .cornerRadius(12)
    }
    
    private func resumoItem(value: Double, label: String, color: Color) -> some View {
        VStack(alignment: .center, spacing: 4) {
            Text(formatCurrency(value))
                .font(.title3)
                .bold()
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(0.5) // Reduz a fonte se o valor for longo
                .frame(maxWidth: .infinity)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// Preview para ExpensesResumoView (opcional, mas bom para design)
#Preview {
    ExpensesResumoView(income: 1500.75, expense: 850.50)
        .padding()
        .background(Color.gray.opacity(0.1))
}
