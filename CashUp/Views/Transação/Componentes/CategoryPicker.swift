// Arquivo: CashUp/Views/Transação/Componentes/CategoryPicker.swift
// Refatorado para SwiftData

import SwiftUI
import SwiftData

struct CategoryPicker: View {
    // Bindings agora para os modelos SwiftData
    @Binding var selectedSubcategoryModel: SubcategoriaModel?
    @Binding var selectedCategoryModel: CategoriaModel? // A categoria pai da subcategoria selecionada
    @Binding var isCategorySheetPresented: Bool

    var body: some View {
        VStack(spacing: 8) {
            Button {
                isCategorySheetPresented = true
            } label: {
                HStack(spacing: 12) {
                    // Verifica se os modelos SwiftData estão selecionados
                    if let subModel = selectedSubcategoryModel,
                       let catModel = selectedCategoryModel { // selectedCategoryModel deve ser o .categoria da subModel
                        
                        CategoriasViewIcon(
                            systemName: subModel.icon,
                            cor: catModel.color, // Usa a cor do CategoriaModel
                            size: 24
                        )
                        
                        Text(subModel.nome) // Nome da SubcategoriaModel
                            .font(.title2)
                            .foregroundStyle(.primary)
                    } else {
                        Image(systemName: "square.grid.2x2")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundStyle(.primary)

                        Text("Selecionar categoria")
                            .font(.title2)
                            .foregroundStyle(.primary)
                    }

                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.gray)
                }
                .padding(.vertical, 8)
            }
            .buttonStyle(.plain)

            Divider()
        }
    }
}

// Preview para CategoryPicker (requer configuração de ModelContainer e dados mock)
#Preview {
    // Wrapper para gerenciar os bindings para o Preview
    struct PreviewPickerWrapper: View {
        @State private var subCatModel: SubcategoriaModel? = nil
        @State private var catModel: CategoriaModel? = nil
        @State private var showSheet = false

        // Criar um container em memória e alguns dados mock para o preview
        static var previewContainer: ModelContainer = {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            do {
                let container = try ModelContainer(for: Schema([CategoriaModel.self, SubcategoriaModel.self]), configurations: [config])
                let modelContext = container.mainContext
                
                // Dados Mock para Preview
                let previewCat = CategoriaModel(nome: "Alimentação", icon: "fork.knife", color: .orange)
                let previewSub = SubcategoriaModel(nome: "Restaurante", icon: "筷子", categoria: previewCat)
                previewCat.subcategorias = [previewSub]
                modelContext.insert(previewCat)
                // modelContext.insert(previewSub) // Já inserido pela relação se cascade ou se adicionado à coleção
                
                try modelContext.save()
                return container
            } catch {
                fatalError("Falha ao criar container para preview do CategoryPicker: \(error)")
            }
        }()


        var body: some View {
            VStack {
                CategoryPicker(
                    selectedSubcategoryModel: $subCatModel,
                    selectedCategoryModel: $catModel,
                    isCategorySheetPresented: $showSheet
                )
                .padding()

                Button("Simular Seleção") {
                    // Busca os dados mock para simular uma seleção
                    let fetchDescriptorCat = FetchDescriptor<CategoriaModel>()
                    if let fetchedCats = try? PreviewPickerWrapper.previewContainer.mainContext.fetch(fetchDescriptorCat),
                       let firstCat = fetchedCats.first,
                       let firstSub = firstCat.subcategorias?.first {
                        self.catModel = firstCat
                        self.subCatModel = firstSub
                    }
                }
                .padding()
                
                Button("Limpar Seleção") {
                    self.catModel = nil
                    self.subCatModel = nil
                }
                .padding()
            }
            // O .modelContainer é importante se CategoryPicker ou suas subviews (como CategoriasViewIcon)
            // usarem @Query ou @Environment(\.modelContext) internamente, o que não é o caso aqui.
            // Mas é bom para consistência se o sheet apresentado usar.
            .modelContainer(PreviewPickerWrapper.previewContainer)
        }
    }
    
    return PreviewPickerWrapper()
}
