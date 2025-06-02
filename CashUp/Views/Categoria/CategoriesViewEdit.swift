//
//  CategoriesViewEdit.swift
//  CashUp
//
//  Created by Gustavo Souto Pereira on 19/05/25.
//

import SwiftUI
import SwiftData

struct CategoriesViewEdit: View {
    @Query(sort: \CategoriaModel.nome) private var categorias: [CategoriaModel]
    
    @Environment(\.modelContext) private var modelContext
    var body: some View {
        NavigationStack {
            List {
                if categorias.isEmpty {
                    Text("Nenhuma categoria encontrada. Tente adicionar algumas.")
                } else {
                    ForEach(categorias) { categoriaModel in
                        CategoriaSectionView(categoria: categoriaModel)
                        // Adicione aqui a lógica de swipe para deletar ou botões para editar
                        // Exemplo de swipe para deletar:
                        // .swipeActions {
                        //     Button("Deletar", systemImage: "trash", role: .destructive) {
                        //         // Adicionar confirmação antes de deletar
                        //         deleteCategoria(categoriaModel)
                        //     }
                        // }
                    }
                }
            }
            .navigationTitle("Editar Categorias")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    // O botão de "ellipsis.circle" pode ser usado para um menu de edição geral
                    // ou um botão "Adicionar" para novas categorias.
                    Menu {
                        Button("Adicionar Nova Categoria", systemImage: "plus.circle") {
                            // Lógica para apresentar uma view de adicionar/editar categoria
                            // addNewCategoria()
                        }
                        // Outras opções de edição em lote, se necessário
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .scrollContentBackground(.hidden)
        }
    }

    // Funções de exemplo para adicionar/deletar (implementação completa necessária)
    // func addNewCategoria() {
    //     // Apresentar um sheet ou navegação para criar uma nova CategoriaModel
    //     // let novaCategoria = CategoriaModel(nome: "Nova Categoria", icon: "square.grid.2x2", color: .gray)
    //     // modelContext.insert(novaCategoria)
    //     // try? modelContext.save()
    // }

    // func deleteCategoria(_ categoria: CategoriaModel) {
    //     modelContext.delete(categoria)
    //     // try? modelContext.save()
    // }
}

// CategoriaSectionView já está correta para aceitar CategoriaModel
// Certifique-se que ela também lida com subcategorias como [SubcategoriaModel]?
struct CategoriaSectionView: View { //
    // @Bindable para permitir edição direta se necessário no futuro, ou apenas `let` se for só display
    @Bindable var categoria: CategoriaModel

    var body: some View {
        Section {
            // O '!' em categoria.subcategorias! não é seguro. Use if let ou ?? [].
            ForEach(categoria.subcategorias ?? []) { sub in // Usa a coleção de SubcategoriaModel
                HStack(spacing: 12) {
                    CategoriasViewIcon(systemName: sub.icon, cor: categoria.color, size: 24)
                    Text(sub.nome)
                        .foregroundStyle(.primary)
                    // Adicionar botões de editar/deletar subcategoria aqui se desejado
                }
                .padding(.vertical, 4)
            }
        } header: {
            HStack(spacing: 8) {
                CategoriasViewIcon(systemName: categoria.icon, cor: categoria.color, size: 24)
                Text(categoria.nome)
                    .font(.headline)
                    .foregroundStyle(.primary)
            }
            .padding(.vertical, 6)
            .padding(.leading, -20) // Este padding negativo pode ser ajustado dependendo do estilo da lista
        }
    }
}

