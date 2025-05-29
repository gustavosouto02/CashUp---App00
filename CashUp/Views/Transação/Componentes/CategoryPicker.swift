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
