//
//  CategoriesView.swift
//  CashUp
//
//  Created by Gustavo Souto Pereira on 13/05/25.
//

import SwiftUI

struct CategoriesView: View {
    @ObservedObject var viewModel: CategoriesViewModel
    @State private var isEditing = false
    @State private var selectedCategoria: UUID? = nil
    @State private var subcategoriaSelecionada: Subcategoria?
    var onCategorySelected: (Subcategoria) -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Divider logo abaixo do título
                Divider()
                    .background(Color.gray.opacity(0.6))
                    .frame(height: 1)
                    .padding(.bottom, 12)

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Filtro com exibição integrada
                        CategoriaFiltroView(
                            categorias: viewModel.categorias,
                            selectedCategoriaID: $selectedCategoria,
                            onSubcategoriaSelected: { sub in
                                subcategoriaSelecionada = sub

                                // Registrar o uso da subcategoria na ViewModel
                                viewModel.registrarUso(subcategoria: sub)

                                // Acionar o retorno
                                onCategorySelected(sub)
                            },
                            subcategoriasFrequentes: viewModel.subcategoriasMaisUsadas
                        )
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
            .navigationDestination(isPresented: $isEditing) {
                CategoriesViewEdit()
            }
        }
    }
}

#Preview {
    CategoriesView(viewModel: CategoriesViewModel()) { _ in }
}
