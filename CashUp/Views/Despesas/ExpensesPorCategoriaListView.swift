import SwiftUI
import SwiftData

// Struct auxiliar para o sheet
struct SubcategoryDetailSheetDataSwiftData: Identifiable {
    let id = UUID()
    let subcategoriaModel: SubcategoriaModel
    let isIncome: Bool
}

struct ExpensesPorCategoriaListView: View {
    @ObservedObject var viewModel: ExpensesViewModel

    @State private var localSelectedTransactionType: Int = 0
    @State private var expandedCategories: Set<UUID> = []
    @State private var selectedSubcategoryDataForSheet: SubcategoryDetailSheetDataSwiftData? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            TransactionPicker(selectedTransactionType: $localSelectedTransactionType)
                .padding(.horizontal)
                .padding(.top, 8)
                .onChange(of: localSelectedTransactionType) { _, newValue in
                    viewModel.selectedTransactionType = newValue
                }

            Text(localSelectedTransactionType == 0 ? "Categorias principais de despesas" : "Categorias principais de receitas")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
                .padding(.top)

            ScrollView {
                if categoriasFiltradas.isEmpty {
                    Text("Nenhuma transação nesta categoria para o mês.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(categoriasFiltradas, id: \.id) { categoriaModel in
                            VStack(spacing: 0) {
                                Button {
                                    toggleCategory(categoriaModel.id)
                                } label: {
                                    HStack {
                                        Rectangle()
                                            .fill(categoriaModel.color)
                                            .frame(width: 6, height: 24)
                                            .cornerRadius(3)

                                        Text(categoriaModel.nome)
                                            .font(.subheadline)
                                            .fontWeight(.semibold)

                                        Spacer()

                                        Text(formatCurrency(totalParaCategoria(categoriaModel)))
                                            .font(.subheadline)
                                            .foregroundStyle(.primary)

                                        Image(systemName: expandedCategories.contains(categoriaModel.id) ? "chevron.down" : "chevron.right")
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

                                if expandedCategories.contains(categoriaModel.id) {
                                    VStack(spacing: 6) {
                                        ForEach(subcategoriasParaCategoria(categoriaModel), id: \.id) { subModel in
                                            Button {
                                                selectedSubcategoryDataForSheet = SubcategoryDetailSheetDataSwiftData(
                                                    subcategoriaModel: subModel,
                                                    isIncome: localSelectedTransactionType == 1
                                                )
                                            } label: {
                                                HStack {
                                                    Circle()
                                                        .fill(categoriaModel.color)
                                                        .frame(width: 10, height: 10)

                                                    Text(subModel.nome)
                                                        .font(.subheadline)

                                                    Spacer()

                                                    Text(formatCurrency(totalParaSubcategoria(subModel)))
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
                    .padding(.vertical)
                }
            }
        }
        .sheet(item: $selectedSubcategoryDataForSheet) { data in
            SubcategoryDetailView(
                subcategoriaModel: data.subcategoriaModel,
                isIncome: data.isIncome,
                viewModel: viewModel
            )
        }
        .onAppear {
            viewModel.selectedTransactionType = localSelectedTransactionType
        }
    }

    // MARK: - Lógica de Dados

    private var transacoesRelevantes: [ExpenseModel] {
        localSelectedTransactionType == 0
            ? viewModel.expensesOnlyForCurrentMonth()
            : viewModel.incomesOnlyForCurrentMonth()
    }

    private var categoriasFiltradas: [CategoriaModel] {
        let categoriasComNuloRemovido: [CategoriaModel] = transacoesRelevantes.compactMap { $0.categoria }
        let categoriasUnicas: Set<CategoriaModel> = Set(categoriasComNuloRemovido)
        let categoriasOrdenadas: [CategoriaModel] = categoriasUnicas.sorted { $0.nome < $1.nome }
        return categoriasOrdenadas
    }

    func subcategoriasParaCategoria(_ categoriaModel: CategoriaModel) -> [SubcategoriaModel] {
        let transacoes = transacoesRelevantes.filter { $0.categoria == categoriaModel }
        let subcategorias = transacoes.compactMap { $0.subcategoria }
        let subcategoriasUnicas = Set(subcategorias)
        return Array(subcategoriasUnicas).sorted { $0.nome < $1.nome }
    }

    func totalParaCategoria(_ categoriaModel: CategoriaModel) -> Double {
        transacoesRelevantes
            .filter { $0.categoria == categoriaModel }
            .map { $0.amount }
            .reduce(0, +)
    }

    func totalParaSubcategoria(_ subModel: SubcategoriaModel) -> Double {
        transacoesRelevantes
            .filter { $0.subcategoria == subModel }
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
