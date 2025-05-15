//
//  CategoriesView.swift
//  CashUp
//
//  Created by Gustavo Souto Pereira on 13/05/25.
//

import SwiftUI

struct CategoriesView: View {
    @State private var isEditing = false
    @State private var selectedCategoria: String = "Todas"
    var onCategorySelected: (String) -> Void

    var categorias = CategoriasData.todas

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Divider logo abaixo do título
                Divider()
                    .background(Color.gray.opacity(0.6))
                    .frame(height: 1)

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Filtro com exibição integrada
                        CategoriaFiltroView(categorias: categorias, selectedCategoria: $selectedCategoria, onSubcategoriaSelected: { sub in
                            onCategorySelected(sub.nome)
                        })
                    }
                }
            }
            .navigationTitle("Categorias")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        isEditing = true
                    }) {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
            // Aqui está a navegação para a tela de edição
            .navigationDestination(isPresented: $isEditing) {
                CategoriesViewEdit()
            }
        }
    }
}

#Preview {
    CategoriesView { _ in }
}
