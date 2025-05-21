//
//  SubcategoryDetailView.swift
//  CashUp
//
//  Created by Gustavo Souto Pereira on 21/05/25.
//

import SwiftUI

struct SubcategoryDetailView: View {
    let subcategoria: Subcategoria
    @ObservedObject var viewModel: ExpensesViewModel
    @Environment(\.dismiss) var dismiss

    var despesas: [Expense] {
        viewModel.expensesDoMes.filter {
            $0.subcategory.id == subcategoria.id
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(despesas) { expense in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(formatDate(expense.date))
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)

                                Spacer()

                                Text(formatCurrency(expense.amount))
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }

                            if !expense.description.isEmpty {
                                Text(expense.description)
                                    .font(.footnote)
                                    .foregroundStyle(.gray)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemBackground))
                                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                        )
                        .padding(.horizontal)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                viewModel.removeExpense(expense)
                            } label: {
                                Label("Excluir", systemImage: "trash")
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle(subcategoria.nome)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Fechar") {
                        dismiss()
                    }
                }
            }
        }
    }

    func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: NSNumber(value: value)) ?? "R$ 0,00"
    }

    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

