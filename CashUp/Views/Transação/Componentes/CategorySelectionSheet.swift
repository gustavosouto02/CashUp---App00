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

    var body: some View {
        NavigationStack {
            CategoriesView { selectedName in
                if let categoria = CategoriasData.todas.first(where: { cat in
                    cat.subcategorias.contains(where: { $0.nome == selectedName })
                }),
                let sub = categoria.subcategorias.first(where: { $0.nome == selectedName }) {
                    selectedCategory = categoria
                    selectedSubcategory = sub
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
