//
//  CategoriesSheet.swift
//  CashUp
//
//  Created by Gustavo Souto Pereira on 13/05/25.
//

import SwiftUI

struct CategorySelectionSheet: View {
    @Binding var selectedSubcategory: Subcategoria?
    @Binding var isPresented: Bool
    @Binding var selectedCategory: Categoria?
    
    @StateObject private var viewModel = CategoriesViewModel()

    var body: some View {
        NavigationStack {
            CategoriesView(viewModel: viewModel) { selectedSub in
                // Agora estamos recebendo diretamente uma Subcategoria
                if let categoria = CategoriasData.todas.first(where: {
                    $0.subcategorias.contains(where: { $0.id == selectedSub.id })
                }) {
                    selectedCategory = categoria
                    selectedSubcategory = selectedSub
                }

                withAnimation {
                    isPresented = false
                }
            }
            .navigationTitle("Categorias")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
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
