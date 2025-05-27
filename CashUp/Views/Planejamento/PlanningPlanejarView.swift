// Arquivo: CashUp/Views/Planejamento/PlanningPlanejarView.swift
// Refatorado para usar CategoriaModel/SubcategoriaModel consistentemente

import SwiftUI
import SwiftData

struct PlanningPlanejarView: View {
    @ObservedObject var viewModel: PlanningViewModel

    @Binding var isEditing: Bool
    @Binding var subcategoriasPlanejadasSelecionadasParaDelecao: Set<UUID>
    @State private var isCategorySheetPresented = false
    @State private var selectedSubcategoryFromSheet: SubcategoriaModel? = nil
    @State private var selectedCategoryFromSheet: CategoriaModel? = nil
    @State private var showResetConfirmation = false
    @State private var showDuplicateAlert = false

    
    @Query var categoriasPlanejadasDoMesQuery: [CategoriaPlanejadaModel]

    init(viewModel: PlanningViewModel,
         isEditing: Binding<Bool>,
         subcategoriasSelecionadas: Binding<Set<UUID>>) {
        self.viewModel = viewModel
        self._isEditing = isEditing
        self._subcategoriasPlanejadasSelecionadasParaDelecao = subcategoriasSelecionadas
        
        let monthToFilter = viewModel.currentMonth.startOfMonth()
        let predicate = #Predicate<CategoriaPlanejadaModel> {
            $0.mesAno == monthToFilter
        }
        // Ordena pelo nome da categoria original para consistência na UI
        let sortDescriptors = [SortDescriptor(\CategoriaPlanejadaModel.categoriaOriginal?.nome, order: .forward)]
        
        _categoriasPlanejadasDoMesQuery = Query(filter: predicate, sort: sortDescriptors, animation: .default)
    }

    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    despesasPlanejadasCard
                    listaCategoriasPlanejadasView()
                    botaoAdicionarCategoriaAoPlanejamento
                    Spacer()
                    rodapePlanejamento
                }
                .padding(.vertical)
            }
            .fullScreenCover(isPresented: $isCategorySheetPresented) {
                let categoriesVM = CategoriesViewModel(modelContext: viewModel.modelContext)
                CategorySelectionSheet(
                    viewModel: categoriesVM,
                    selectedSubcategoryModel: $selectedSubcategoryFromSheet,
                    isPresented: $isCategorySheetPresented,
                    selectedCategoryModel: $selectedCategoryFromSheet,
                )
                .environment(\.modelContext, viewModel.modelContext)
            }
            .onChange(of: selectedSubcategoryFromSheet) { oldValue, newValue in
                guard let subModel = newValue else {
                    if newValue == nil { // Se desmarcado
                        selectedCategoryFromSheet = nil
                    }
                    return
                }

                let catModelParaProcessar: CategoriaModel?
                if let directCat = selectedCategoryFromSheet, directCat.id == subModel.categoria?.id {
                    catModelParaProcessar = directCat
                } else if let parentCat = subModel.categoria {
                    catModelParaProcessar = parentCat

                    DispatchQueue.main.async {
                       if self.selectedCategoryFromSheet?.id != parentCat.id {
                           self.selectedCategoryFromSheet = parentCat
                       }
                    }
                } else {
                    print("Erro Crítico: Subcategoria '\(subModel.nome)' selecionada não tem uma categoria pai associada.")
                    DispatchQueue.main.async {
                        self.selectedSubcategoryFromSheet = nil
                        self.selectedCategoryFromSheet = nil
                    }
                    return
                }
                
                guard let finalCatModel = catModelParaProcessar else {
                    print("Erro: Categoria final para processamento é nil após seleção de subcategoria.")
                     DispatchQueue.main.async {
                        self.selectedSubcategoryFromSheet = nil
                        self.selectedCategoryFromSheet = nil
                    }
                    return
                }
                
                processarSelecaoDoSheet(subcategoria: subModel, categoria: finalCatModel)
            }

            if showDuplicateAlert {
                alertDuplicado
            }
        }
        .animation(.easeInOut, value: showDuplicateAlert)
        .hideKeyboardOnTap() // Certifique-se que a extensão View.hideKeyboardOnTap() está acessível
    }
    
    private func processarSelecaoDoSheet(subcategoria: SubcategoriaModel, categoria: CategoriaModel) {
        let adicionouComSucesso: Bool
        
        // PlanningViewModel.adicionar... DEVE ser atualizado para aceitar CategoriaModel e SubcategoriaModel.
        if categoriasPlanejadasDoMesQuery.contains(where: { $0.categoriaOriginal?.id == categoria.id }) {
            adicionouComSucesso = viewModel.adicionarSubcategoriaAoPlanejamento(
                subcategoriaModel: subcategoria,
                toCategoriaModel: categoria
            )
        } else {
            adicionouComSucesso = viewModel.adicionarNovaCategoriaAoPlanejamento(
                categoriaModel: categoria,
                comSubcategoriaInicial: subcategoria
            )
        }

        if !adicionouComSucesso {
            showDuplicateAlert = true
        }
        
        // Limpa a seleção após o processamento
        DispatchQueue.main.async {
            selectedSubcategoryFromSheet = nil
            selectedCategoryFromSheet = nil
        }
    }

    private var despesasPlanejadasCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 16) {
                Circle()
                    .trim(from: 0.0, to: 1.0)
                    .stroke(
                        LinearGradient(colors: [.purple, .blue, .pink], startPoint: .top, endPoint: .bottom),
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 50, height: 50)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Despesas Planejadas")
                        .font(.headline)
                    Text(viewModel.valorTotalPlanejadoParaMesAtual(), format: .currency(code: "BRL"))
                        .font(.title2.bold())
                }
                Spacer()
            }

            ForEach(categoriasPlanejadasDoMesQuery) { categoriaPlanejadaModel in
                categoriaResumo(categoriaPlanejadaModel)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
    }

    @ViewBuilder
    private func categoriaResumo(_ categoriaPModel: CategoriaPlanejadaModel) -> some View {
        let total = viewModel.totalParaCategoriaPlanejada(categoriaPModel)
        let percentual = viewModel.calcularPorcentagemTotal(paraCategoriaPlanejada: categoriaPModel)

        VStack(spacing: 4) {
            HStack {
                RoundedRectangle(cornerRadius: 3)
                    .fill(categoriaPModel.corCategoriaOriginal)
                    .frame(width: 12, height: 12)
                    .padding(.leading, 4)

                Text(categoriaPModel.nomeCategoriaOriginal)
                    .font(.subheadline)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("\(percentual, specifier: "%.0f")%")
                    .font(.subheadline)
                    .frame(width: 50, alignment: .trailing)

                Text(total, format: .currency(code: "BRL"))
                    .font(.subheadline.weight(.medium))
                    .frame(width: 100, alignment: .trailing)
            }
            Divider().padding(.top, 4)
        }
    }

    @ViewBuilder
    private func listaCategoriasPlanejadasView() -> some View {
        if categoriasPlanejadasDoMesQuery.isEmpty && !isEditing {
             Text("Nenhuma categoria planejada para este mês.\nToque em \"Adicionar Categoria\" para começar.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding()
                .frame(maxWidth: .infinity, alignment: .center)
        } else {
            ForEach(categoriasPlanejadasDoMesQuery) { catPlanModel in
                categoriaPlanejadaView(catPlanModel)
            }
        }
    }

    @ViewBuilder
    private func categoriaPlanejadaView(_ catPlanModel: CategoriaPlanejadaModel) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                CategoriasViewIcon(
                    systemName: catPlanModel.iconCategoriaOriginal,
                    cor: catPlanModel.corCategoriaOriginal, // Esta propriedade deve ser Color
                    size: 24
                )
                Text(catPlanModel.nomeCategoriaOriginal)
                    .font(.headline)
                Spacer()
            }
            Divider()

            if let subcategorias = catPlanModel.subcategoriasPlanejadas, !subcategorias.isEmpty {
                ForEach(subcategorias.sorted(by: { $0.subcategoriaOriginal?.nome ?? "" < $1.subcategoriaOriginal?.nome ?? ""})) { subPlanModel in
                    SubcategoriaPlanejadaRowView(
                        subPlanejadaModel: subPlanModel,
                        corIconeCategoriaPai: catPlanModel.corCategoriaOriginal,
                        isEditing: isEditing,
                        isSelected: subcategoriasPlanejadasSelecionadasParaDelecao.contains(subPlanModel.id),
                        toggleSelection: {
                            if subcategoriasPlanejadasSelecionadasParaDelecao.contains(subPlanModel.id) {
                                subcategoriasPlanejadasSelecionadasParaDelecao.remove(subPlanModel.id)
                            } else {
                                subcategoriasPlanejadasSelecionadasParaDelecao.insert(subPlanModel.id)
                            }
                        },
                        valorPlanejadoStringBinding: viewModel.bindingParaValorPlanejado(subItem: subPlanModel)
                    )
                }
            } else if !isEditing {
                Text("Nenhuma subcategoria planejada aqui.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.leading)
                    .padding(.vertical, 4)
            }

            if !isEditing {
                Button(action: {
                    self.selectedCategoryFromSheet = catPlanModel.categoriaOriginal
                    self.selectedSubcategoryFromSheet = nil
                    isCategorySheetPresented = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(.blue)
                        Text("Adicionar Subcategoria")
                            .font(.footnote)
                    }
                    .padding(.top, 4)
                }
            }
        }
        .padding()
        .background(Color(.systemGray5))
        .cornerRadius(12)
        .padding(.horizontal)
    }

    private var rodapePlanejamento: some View {
        HStack {
            Text("Planejamento para:\n\(viewModel.currentMonth.formatted(.dateTime.month(.wide).year(.defaultDigits)))")
                .font(.caption2)
                .lineLimit(2)
            Spacer()
            Button("Zerar Planejamento") {
                showResetConfirmation = true
            }
            .font(.caption)
            .foregroundColor(.red)
            .alert("Confirmação", isPresented: $showResetConfirmation) {
                Button("Cancelar", role: .cancel) {}
                Button("Confirmar", role: .destructive) {
                    viewModel.zerarPlanejamentoDoMes()
                }
            } message: {
                Text("Você tem certeza que deseja zerar o planejamento deste mês? Esta ação não pode ser desfeita.")
            }
        }
        .padding(.horizontal)
        .padding(.top)
    }

    private var alertDuplicado: some View {
        VStack {
            Spacer()
            Text("Subcategoria já adicionada a este planejamento.")
                .padding()
                .background(Color.orange.opacity(0.85))
                .foregroundStyle(.white)
                .cornerRadius(10)
                .padding(.horizontal, 40)
                .transition(.move(edge: .bottom).combined(with: .opacity))
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeInOut) {
                    showDuplicateAlert = false
                }
            }
        }
    }

    private var botaoAdicionarCategoriaAoPlanejamento: some View {
        Button(action: {
            selectedCategoryFromSheet = nil
            selectedSubcategoryFromSheet = nil
            isCategorySheetPresented = true
        }) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .foregroundStyle(.blue)
                Text("Adicionar Categoria ao Planejamento")
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding()
            .background(Color(.systemGray5))
            .cornerRadius(12)
        }
        .padding(.horizontal)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container: ModelContainer
    do {
        container = try ModelContainer(for: Schema([
            CategoriaModel.self, SubcategoriaModel.self,
            CategoriaPlanejadaModel.self, SubcategoriaPlanejadaModel.self, ExpenseModel.self
        ]), configurations: [config])
        let modelContext = container.mainContext

        let catAlim = CategoriaModel(id: UUID(uuidString: "D3D3D3D3-D3D3-D3D3-D3D3-D3D3D3D3D3D3")!, nome: "Alimentação", icon: "fork.knife", color: .orange)
        let subRest = SubcategoriaModel(id: UUID(uuidString: "S024S024-S024-S024-S024-S024S024S024")!, nome: "Restaurante", icon: "fork.knife.circle", categoria: catAlim)
        catAlim.subcategorias = [subRest]
        modelContext.insert(catAlim)
        
        let planningVM = PlanningViewModel(modelContext: modelContext)
        planningVM.currentMonth = Date().startOfMonth()
        
        try modelContext.save()

        return PlanningPlanejarView(
            viewModel: planningVM,
            isEditing: .constant(false),
            subcategoriasSelecionadas: .constant([])
        )
        .modelContainer(container)

    } catch {
        return Text("Erro ao criar preview para PlanningPlanejarView: \(error.localizedDescription)")
    }
}
