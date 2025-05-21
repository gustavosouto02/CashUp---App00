//
//  ExpensesListView.swift
//  CashUp
//
//  Created by Gustavo Souto Pereira on 19/05/25.
//

import SwiftUI

struct ExpensesListView: View {
    @ObservedObject var viewModel: ExpensesViewModel
    
    var body: some View {
        List {
            ForEach(groupedExpenses.keys.sorted(by: >), id: \.self) { date in
                Section(
                    header:
                        HStack {
                            Text(formattedDate(date))
                                .font(.headline)
                                .foregroundStyle(.secondary)
                            
                            Spacer()
                            
                            Text(formatCurrency(totalForDay(date)))
                                .font(.headline.bold())
                                .foregroundStyle(totalForDay(date) >= 0 ? .green : .red)
                        }
                        .padding(.vertical, 2)
                ) {
                    ForEach(groupedExpenses[date] ?? []) { expense in
                        ExpenseRow(expense: expense)
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color(.systemGray6))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                    }
                    .onDelete { offsets in
                        deleteExpense(at: offsets, for: date)
                    }
                }
            }
        }
        .listStyle(.plain)
        .padding(.bottom, 8)
    }
    
    // MARK: Agrupamento e Cálculos
    
    var groupedExpenses: [Date: [Expense]] {
        let calendar = Calendar.current
        return Dictionary(grouping: viewModel.expensesDoMes) {
            calendar.startOfDay(for: $0.date)
        }
    }
    
    func totalForDay(_ date: Date) -> Double {
        groupedExpenses[date]?.reduce(0) {
            $0 + ($1.isIncome ? $1.amount : -$1.amount)
        } ?? 0
    }
    
    func deleteExpense(at offsets: IndexSet, for date: Date) {
        guard let expensesForDate = groupedExpenses[date] else { return }
        let toDelete = offsets.map { expensesForDate[$0] }
        toDelete.forEach { viewModel.removeExpense($0) }
    }
    
    func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: NSNumber(value: value)) ?? "R$ 0,00"
    }
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "EEEE, d"
        return formatter.string(from: date).capitalized
    }
}

struct ExpenseRow: View {
    let expense: Expense
    
    var body: some View {
        HStack(spacing: 12) {
            CategoriasViewIcon(
                systemName: expense.subcategory.icon,
                cor: expense.category.color,
                size: 20
            )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(expense.category.nome)
                    .font(.headline)
                
                HStack(spacing: 4){
                    Text(expense.subcategory.nome)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    if !expense.description.isEmpty {
                        Text(": \(expense.description)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Spacer()
            
            Text(formatCurrency(expense.amount))
                .foregroundStyle(.secondary)
                .fontWeight(.bold)
        }
        .padding(.vertical, 6)
    }
    
    func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: NSNumber(value: value)) ?? "R$ 0,00"
    }
}

