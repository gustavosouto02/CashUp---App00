//
//  ExpensesPorCategoriaListView.swift
//  CashUp
//
//  Created by Gustavo Souto Pereira on 21/05/25.
//

import SwiftUI

struct SubcategoryDetailSheetData: Identifiable {
    let id = UUID()
    let subcategoria: Subcategoria
    let isIncome: Bool // Certifique-se de que isso está sendo passado corretamente
}

struct ExpensesPorCategoriaListView: View {
    @ObservedObject var viewModel: ExpensesViewModel
    @State private var selectedTransactionType: Int = 0 // O picker agora é gerenciado aqui
    @State private var expandedCategories: Set<UUID> = []
    @State private var selectedSubcategoryData: SubcategoryDetailSheetData? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // MARK: - Picker de tipo de transação (agora dentro do card)
            TransactionPicker(selectedTransactionType: $selectedTransactionType)
                .padding(.horizontal)
                .padding(.top, 8)

            Text(selectedTransactionType == 0 ? "Categorias principais de despesas" : "Categorias principais de receitas")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
                .padding(.top)

            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(categoriasFiltradas, id: \.id) { categoria in
                        VStack(spacing: 0) {
                            // Card da categoria principal
                            Button {
                                toggleCategory(categoria.id)
                            } label: {
                                HStack {
                                    Rectangle()
                                        .fill(categoria.color)
                                        .frame(width: 6, height: 24)
                                        .cornerRadius(3)

                                    Text(categoria.nome)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)

                                    Spacer()
                                    // Chama a função correta para o total
                                    Text(formatCurrency(totalParaCategoria(categoria)))
                                        .font(.subheadline)
                                        .foregroundStyle(.primary)

                                    Image(systemName: expandedCategories.contains(categoria.id) ? "chevron.down" : "chevron.right")
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.systemGray6))
                                )
                            }
                            .buttonStyle(.plain)

                            if expandedCategories.contains(categoria.id) {
                                VStack(spacing: 6) {
                                    // Usa as subcategorias filtradas
                                    ForEach(subcategoriasParaCategoria(categoria), id: \.id) { sub in
                                        Button {
                                            selectedSubcategoryData = SubcategoryDetailSheetData(
                                                subcategoria: sub,
                                                isIncome: selectedTransactionType == 1
                                            )
                                        } label: {
                                            HStack {
                                                Circle()
                                                    .fill(categoria.color) // Still using categoria.color for the circle
                                                    .frame(width: 10, height: 10)

                                                Text(sub.nome)
                                                    .font(.subheadline)

                                                Spacer()
                                                // Chama a função correta para o total
                                                Text(formatCurrency(totalParaSubcategoria(sub)))
                                                    .foregroundStyle(.secondary)

                                                Image(systemName: "chevron.right")
                                                    .foregroundStyle(.secondary)
                                                    .font(.caption2)
                                            }
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.horizontal)
                                            .padding(.vertical, 8)
                                            .contentShape(Rectangle())
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.horizontal, 8)
                                .padding(.bottom, 8)
                            }
                        }
                    }
                }
            }
        }
        .sheet(item: $selectedSubcategoryData) { data in
            SubcategoryDetailView(
                subcategoria: data.subcategoria,
                isIncome: data.isIncome,
                viewModel: viewModel
            )
        }
    }

    // MARK: - Lógica atualizada para usar selectedTransactionType

    var categoriasFiltradas: [Categoria] {
        let transactions = selectedTransactionType == 0 ? viewModel.despesasDoMes : viewModel.receitasDoMes
        let categorias = transactions.map { $0.category }
        return Array(Set(categorias)).sorted { $0.nome < $1.nome }
    }

    func subcategoriasParaCategoria(_ categoria: Categoria) -> [Subcategoria] {
        let transactions = selectedTransactionType == 0 ? viewModel.despesasDoMes : viewModel.receitasDoMes
        let subcategorias = transactions.filter { $0.category.id == categoria.id }.map { $0.subcategory }
        return Array(Set(subcategorias)).sorted { $0.nome < $1.nome }
    }

    func totalParaCategoria(_ categoria: Categoria) -> Double {
        let transactions = selectedTransactionType == 0 ? viewModel.despesasDoMes : viewModel.receitasDoMes
        return transactions
            .filter { $0.category.id == categoria.id }
            .map { $0.amount }
            .reduce(0, +)
    }

    func totalParaSubcategoria(_ subcategoria: Subcategoria) -> Double {
        let transactions = selectedTransactionType == 0 ? viewModel.despesasDoMes : viewModel.receitasDoMes
        return transactions
            .filter { $0.subcategory.id == subcategoria.id }
            .map { $0.amount }
            .reduce(0, +)
    }

    func toggleCategory(_ id: UUID) {
        if expandedCategories.contains(id) {
            expandedCategories.remove(id)
        } else {
            expandedCategories.insert(id)
        }
    }
}
