// Arquivo: CashUp/Views/Categoria/CategoriesView.swift
// Refatorado para receber o ViewModel configurado

import SwiftUI
import SwiftData

struct CategoriesView: View {
    // ViewModel agora é um @ObservedObject, injetado pela view pai (CategorySelectionSheet)
    @ObservedObject var viewModel: CategoriesViewModel
    // @Environment(\.modelContext) private var modelContext // Não mais necessário aqui para inicializar o VM

    @State private var isEditing = false
    @State private var selectedCategoriaModelID: UUID? = nil
    
    var onSubcategoriaModelSelected: (SubcategoriaModel) -> Void

    // Inicializador agora recebe o ViewModel já configurado
    init(viewModel: CategoriesViewModel, onSubcategoriaModelSelected: @escaping (SubcategoriaModel) -> Void) {
        self.viewModel = viewModel
        self.onSubcategoriaModelSelected = onSubcategoriaModelSelected
    }

    var body: some View {
        // let _ = Self._printChanges() // Para depuração

        NavigationStack {
            VStack(spacing: 0) {
                Divider()
                    .background(Color.gray.opacity(0.6))
                    .frame(height: 1)
                    .padding(.bottom, 12)

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        CategoriaFiltroView(
                            categorias: viewModel.fetchTodasCategoriasModel(),
                            selectedCategoriaID: $selectedCategoriaModelID,
                            onSubcategoriaSelected: { subcategoriaModel in
                                viewModel.registrarUso(subcategoriaModel: subcategoriaModel)
                                onSubcategoriaModelSelected(subcategoriaModel)
                            },
                            subcategoriasFrequentes: viewModel.subcategoriasMaisUsadas
                        )
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Categorias")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { isEditing = true }) {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
            .navigationDestination(isPresented: $isEditing) {
                CategoriesViewEdit()
                     .environmentObject(viewModel)
                     .environment(\.modelContext, viewModel.modelContext)
            }
        }

    }
}

// Preview para CategoriesView
#Preview {

    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container: ModelContainer
    do {
        container = try ModelContainer(for: Schema([CategoriaModel.self, SubcategoriaModel.self]), configurations: [config])
        let modelContext = container.mainContext
        

        let cat1 = CategoriaModel(id: UUID(), nome: "Alimentação", icon: "fork.knife", color: .orange)
        let sub1_1 = SubcategoriaModel(id: UUID(), nome: "Restaurante", icon: "takeoutbag.and.cup.and.straw.fill", categoria: cat1, usageCount: 3)
        cat1.subcategorias = [sub1_1]
        modelContext.insert(cat1)
        try modelContext.save()
        
        let categoriesVM_preview = CategoriesViewModel(modelContext: modelContext)
        
        return CategoriesView(
            viewModel: categoriesVM_preview,
            onSubcategoriaModelSelected: { subModel in
                print("Preview: SubcategoriaModel selecionada - \(subModel.nome)")
            }
        )
        .modelContainer(container) 

    } catch {
        return Text("Erro ao criar preview para CategoriesView: \(error.localizedDescription)")
    }
}
