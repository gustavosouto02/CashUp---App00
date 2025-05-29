import SwiftUI
import SwiftData

// Struct auxiliar para o sheet (permanece a mesma, pois opera sobre SubcategoriaModel)
struct SubcategoryDetailSheetDataSwiftData: Identifiable {
    let id = UUID() // Pode ser subcategoriaModel.id se for estável e único
    let subcategoriaModel: SubcategoriaModel
    let isIncome: Bool // Para passar o contexto do tipo de transação para a DetailView
}

struct ExpensesPorCategoriaListView: View {
    @ObservedObject var viewModel: ExpensesViewModel

    // Estado local para o picker, sincronizado com o da ViewModel
    @State private var localSelectedTransactionType: Int
    @State private var expandedCategories: Set<UUID> = []
    @State private var selectedSubcategoryDataForSheet: SubcategoryDetailSheetDataSwiftData? = nil

    // Inicializador para sincronizar o estado local com o da ViewModel
    init(viewModel: ExpensesViewModel) {
        self.viewModel = viewModel
        self._localSelectedTransactionType = State(initialValue: viewModel.selectedTransactionType)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            TransactionPicker(selectedTransactionType: $localSelectedTransactionType)
                .padding(.horizontal)
                .padding(.top, 8)
                .onChange(of: localSelectedTransactionType) { _, newValue in
                    // Atualiza a ViewModel quando o picker local muda
                    // Isso vai disparar loadDisplayableExpenses na ViewModel
                    viewModel.selectedTransactionType = newValue
                }

            Text(localSelectedTransactionType == 0 ? "Categorias principais de despesas" : "Categorias principais de receitas")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
                .padding(.top)

            ScrollView {
                if categoriasFiltradas.isEmpty {
                    Text(localSelectedTransactionType == 0 ? "Nenhuma despesa para listar por categoria." : "Nenhuma receita para listar por categoria.")
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
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.primary) // Garante que o texto seja visível

                                        Spacer()

                                        Text(formatCurrency(totalParaCategoria(categoriaModel)))
                                            .font(.subheadline)
                                            .foregroundStyle(.primary)

                                        Image(systemName: expandedCategories.contains(categoriaModel.id) ? "chevron.down" : "chevron.right")
                                            .foregroundStyle(.secondary)
                                    }
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
                                                        .fill(categoriaModel.color.opacity(0.7)) // Usa cor da categoria pai com opacidade
                                                        .frame(width: 10, height: 10)

                                                    Text(subModel.nome)
                                                        .font(.headline)
                                                        .foregroundColor(.primary) // Garante que o texto seja visível


                                                    Spacer()

                                                    Text(formatCurrency(totalParaSubcategoria(subModel)))
                                                        .font(.subheadline.weight(.medium)) // Fonte menor para subtotal
                                                        .foregroundStyle(.secondary)

                                                    Image(systemName: "chevron.right")
                                                        .foregroundStyle(.secondary)
                                                        .font(.caption2)
                                                }
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding(.vertical, 8)
                                                .contentShape(Rectangle())
                                            }
                                            .buttonStyle(.plain)
                                            if subModel.id != subcategoriasParaCategoria(categoriaModel).last?.id {
                                                Divider().padding(.leading, 20) // Divisor entre subcategorias
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 8) // Padding para o bloco de subcategorias
                                    .padding(.bottom, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color(.systemGray6).opacity(0.5)) // Fundo levemente diferente para subcategorias
                                            .padding(.horizontal, 8) // Ajuste para o fundo não tocar as bordas
                                    )
                                }
                            }
                            .padding(.horizontal) // Padding para cada bloco de categoria principal
                        }
                    }
                    .padding(.vertical)
                }
            }
        }
        .sheet(item: $selectedSubcategoryDataForSheet) { data in
            // A SubcategoryDetailView precisará do modelContext se fizer operações de fetch/save
            SubcategoryDetailView(
                subcategoriaModel: data.subcategoriaModel,
                isIncome: data.isIncome,
                viewModel: viewModel // Passa a ExpensesViewModel para a SubcategoryDetailView
            )
            .environment(\.modelContext, viewModel.modelContext) // Passa o modelContext
        }
        .onAppear {
            // Sincroniza o picker local com o da ViewModel na primeira aparição
            // e força um recarregamento se o estado do picker da ViewModel for diferente
            if localSelectedTransactionType != viewModel.selectedTransactionType {
                 localSelectedTransactionType = viewModel.selectedTransactionType
            }
            // viewModel.loadDisplayableExpenses() // Chamado no onAppear da ExpensesView principal ou via didSet
        }
    }

    // MARK: - Lógica de Dados (agora opera sobre DisplayableExpense via viewModel.transacoesExibidas)

    private var transacoesRelevantesParaCalculo: [DisplayableExpense] {
        // Usa a propriedade já filtrada e com recorrências da ViewModel
        // selectedTransactionType na viewModel já filtra transacoesExibidas
        viewModel.transacoesExibidas
    }

    private var categoriasFiltradas: [CategoriaModel] {
        let categoriasComNuloRemovido: [CategoriaModel] = transacoesRelevantesParaCalculo.compactMap { $0.categoria }
        let categoriasUnicas: Set<CategoriaModel> = Set(categoriasComNuloRemovido)
        
        // Ordena por total gasto na categoria, decrescente
        let categoriasOrdenadas: [CategoriaModel] = categoriasUnicas.sorted {
            totalParaCategoria($0) > totalParaCategoria($1)
        }
        return categoriasOrdenadas
    }

    func subcategoriasParaCategoria(_ categoriaModel: CategoriaModel) -> [SubcategoriaModel] {
        let transacoesDaCategoria = transacoesRelevantesParaCalculo.filter { $0.categoria?.id == categoriaModel.id }
        let subcategorias = transacoesDaCategoria.compactMap { $0.subcategoria }
        let subcategoriasUnicas = Set(subcategorias)
        
        // Ordena por total gasto na subcategoria, decrescente
        return Array(subcategoriasUnicas).sorted {
            totalParaSubcategoria($0) > totalParaSubcategoria($1)
        }
    }

    func totalParaCategoria(_ categoriaModel: CategoriaModel) -> Double {
        transacoesRelevantesParaCalculo
            .filter { $0.categoria?.id == categoriaModel.id }
            .reduce(0.0) { $0 + $1.amount }
    }

    func totalParaSubcategoria(_ subModel: SubcategoriaModel) -> Double {
        transacoesRelevantesParaCalculo
            .filter { $0.subcategoria?.id == subModel.id }
            .reduce(0.0) { $0 + $1.amount }
    }

    func toggleCategory(_ id: UUID) {
        if expandedCategories.contains(id) {
            expandedCategories.remove(id)
        } else {
            expandedCategories.insert(id)
        }
    }
}
