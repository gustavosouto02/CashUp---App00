//
//  CategorySelectionSheet.swift
//  CashUp
//
//  Created by Gustavo Souto Pereira on 13/05/25.
//

import SwiftUI
import SwiftData

struct CategorySelectionSheet: View {
    @Binding var selectedSubcategoryModel: SubcategoriaModel?
    @Binding var isPresented: Bool
    @Binding var selectedCategoryModel: CategoriaModel?
    @ObservedObject var viewModel: CategoriesViewModel

    init(viewModel: CategoriesViewModel,
         selectedSubcategoryModel: Binding<SubcategoriaModel?>,
         isPresented: Binding<Bool>,
         selectedCategoryModel: Binding<CategoriaModel?>) {
        
        self.viewModel = viewModel
        self._selectedSubcategoryModel = selectedSubcategoryModel
        self._isPresented = isPresented
        self._selectedCategoryModel = selectedCategoryModel
    }

    var body: some View {
        NavigationStack {
            CategoriesView(
                viewModel: viewModel,
                onSubcategoriaModelSelected: { subcategoriaModelSelecionada in
                    selectedSubcategoryModel = subcategoriaModelSelecionada
                    selectedCategoryModel = subcategoriaModelSelecionada.categoria
                    
                    withAnimation {
                        isPresented = false
                    }
                }
            )
            .navigationTitle("Categorias")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        withAnimation {
                            isPresented = false
                        }
                    }
                }
            }
        }
    }
}
