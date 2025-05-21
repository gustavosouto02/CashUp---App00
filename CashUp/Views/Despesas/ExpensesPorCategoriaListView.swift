//
//  ExpensesPorCategoriaListView.swift
//  CashUp
//
//  Created by Gustavo Souto Pereira on 21/05/25.
//

import SwiftUI

// NOVO: Struct auxiliar para passar dados para a SubcategoryDetailView
struct SubcategoryDetailSheetData: Identifiable {
    let id = UUID() // Adiciona um ID único para conformar a Identifiable
    let subcategoria: Subcategoria
    let categoryColor: Color
}

struct ExpensesPorCategoriaListView: View {
    @ObservedObject var viewModel: ExpensesViewModel
    @State private var expandedCategories: Set<UUID> = []
    @State private var selectedSubcategoryData: SubcategoryDetailSheetData? = nil // Alterado para o novo tipo

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Categorias principais")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
                .padding(.top)

            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(categoriasComGasto, id: \.id) { categoria in
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
                                    Text(formatCurrency(totalGastoCategoria(categoria)))
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

                            // Subcategorias (expandidas)
                            if expandedCategories.contains(categoria.id) {
                                VStack(spacing: 6) {
                                    ForEach(subcategoriasDaCategoria(categoria), id: \.id) { sub in
                                        Button {
                                            // NOVO: Criando uma instância da nova struct
                                            selectedSubcategoryData = SubcategoryDetailSheetData(subcategoria: sub, categoryColor: categoria.color)
                                        } label: {
                                            HStack {
                                                Circle()
                                                    .fill(categoria.color)
                                                    .frame(width: 10, height: 10)
                                                
                                                Text(sub.nome)
                                                    .font(.subheadline)

                                                Spacer()
                                                Text(formatCurrency(totalGastoSubcategoria(sub)))
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
            SubcategoryDetailView(subcategoria: data.subcategoria, categoryColor: data.categoryColor, viewModel: viewModel)
        }
    }

    // MARK: - Lógica

    var categoriasComGasto: [Categoria] {
        let despesas = viewModel.expensesDoMes.filter { !$0.isIncome }
        let categorias = despesas.map { $0.category }
        return Array(Set(categorias)).sorted { $0.nome < $1.nome }
    }

    func subcategoriasDaCategoria(_ categoria: Categoria) -> [Subcategoria] {
        let despesas = viewModel.expensesDoMes.filter { $0.category.id == categoria.id && !$0.isIncome }
        let subcategorias = despesas.map { $0.subcategory }
        return Array(Set(subcategorias)).sorted { $0.nome < $1.nome }
    }

    func totalGastoCategoria(_ categoria: Categoria) -> Double {
        viewModel.expensesDoMes
            .filter { $0.category.id == categoria.id && !$0.isIncome }
            .map { $0.amount }
            .reduce(0, +)
    }

    func totalGastoSubcategoria(_ subcategoria: Subcategoria) -> Double {
        viewModel.expensesDoMes
            .filter { $0.subcategory.id == subcategoria.id && !$0.isIncome }
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
