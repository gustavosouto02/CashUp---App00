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
    @State private var selectedCategoria: String = "Todas"
    @State private var subcategoriaSelecionada: Subcategoria?
    var onCategorySelected: (String) -> Void

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
                            selectedCategoria: $selectedCategoria,
                            onSubcategoriaSelected: { sub in
                                subcategoriaSelecionada = sub

                                // Registrar o uso da subcategoria na ViewModel
                                viewModel.registrarUso(subcategoria: sub)

                                // Acionar o retorno
                                onCategorySelected(sub.nome)
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


//import SwiftUI
//
//struct CategoriesView: View {
//    @ObservedObject var viewModel: CategoriesViewModel
//    @State private var isEditing = false
//    @State private var selectedCategoria: String = "Todas"
//    @State private var subcategoriaSelecionada: Subcategoria?
//    var onCategorySelected: (String) -> Void
//
//    var categorias = CategoriasData.todas
//
//    var body: some View {
//        NavigationStack {
//            VStack(spacing: 0) {
//                // Divider logo abaixo do título
//                Divider()
//                    .background(Color.gray.opacity(0.6))
//                    .frame(height: 1)
//                    .padding(.bottom, 12)
//
//                ScrollView {
//                    VStack(alignment: .leading, spacing: 24) {
//                        // Filtro com exibição integrada
//                        CategoriaFiltroView(
//                                    categorias: viewModel.categorias,
//                                    selectedCategoria: $selectedCategoria,
//                                    onSubcategoriaSelected: { sub in
//                                        subcategoriaSelecionada = sub
//                                        
//                                        // Registrar o uso da subcategoria na ViewModel
//                                        viewModel.registrarUso(subcategoria: sub)
//                                    },
//                                    subcategoriasFrequentes: viewModel.subcategoriasMaisUsadas
//                                )
//                    }
//                }
//            }
//            .navigationTitle("Categorias")
//            .toolbar {
//                ToolbarItem(placement: .topBarTrailing) {
//                    Button(action: {
//                        isEditing = true
//                    }) {
//                        Image(systemName: "square.and.pencil")
//                    }
//                }
//            }
//            // Aqui está a navegação para a tela de edição
//            .navigationDestination(isPresented: $isEditing) {
//                CategoriesViewEdit()
//            }
//        }
//    }
//}
//
//#Preview {
//    let dummyViewModel = CategoriesViewModel()
//    CategoriesView(viewModel: dummyViewModel) { _ in }
//}



//struct CategoriesView: View {
//    @State private var isEditing = false
//    @State private var selectedCategoria: String = "Todas"
//    var onCategorySelected: (String) -> Void
//
//    var categorias = CategoriasData.todas
//
//    var body: some View {
//        NavigationStack {
//            VStack(spacing: 0) {
//                // Divider logo abaixo do título
//                Divider()
//                    .background(Color.gray.opacity(0.6))
//                    .frame(height: 1)
//                    .padding(.bottom, 12)
//
//                ScrollView {
//                    VStack(alignment: .leading, spacing: 24) {
//                        // Filtro com exibição integrada
//                        CategoriaFiltroView(categorias: categorias, selectedCategoria: $selectedCategoria, onSubcategoriaSelected: { sub in
//                            onCategorySelected(sub.nome)
//                        })
//                    }
//                }
//            }
//            .navigationTitle("Categorias")
//            .toolbar {
//                ToolbarItem(placement: .topBarTrailing) {
//                    Button(action: {
//                        isEditing = true
//                    }) {
//                        Image(systemName: "square.and.pencil")
//                    }
//                }
//            }
//            // Aqui está a navegação para a tela de edição
//            .navigationDestination(isPresented: $isEditing) {
//                CategoriesViewEdit()
//            }
//        }
//    }
//}
//
//#Preview {
//    CategoriesView { _ in }
//}
