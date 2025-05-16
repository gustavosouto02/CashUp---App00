//
//  CategoriesViewEdit.swift
//  CashUp
//
//  Created by Gustavo Souto Pereira on 13/05/25.
//

import SwiftUI

struct CategoriesViewEdit: View {
    let categorias = CategoriasData.todas

    var body: some View {
        NavigationStack {
            List {
                ForEach(categorias) { categoria in
                    CategoriaSectionView(categoria: categoria)
                }
            }
            .navigationTitle("Editar categorias")
            .toolbar{
                ToolbarItem(placement: .topBarTrailing){
                    
                    
                    Button(action: {
                        //selecionar, editar
                    }) {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.black)
        }
    }
}

struct CategoriaSectionView: View {
    let categoria: Categoria

    var body: some View {
        Section {
            ForEach(categoria.subcategorias) { sub in
                HStack(spacing: 12) {
                    CategoriasViewIcon(systemName: sub.icon, cor: categoria.cor, size: 24)
                    Text(sub.nome)
                        .foregroundStyle(.primary)
                }
                .padding(.vertical, 4)
            }
        } header: {
            HStack(spacing: 8) {
                CategoriasViewIcon(systemName: categoria.icon, cor: categoria.cor, size: 24)
                Text(categoria.nome)
                    .font(.headline)
                    .foregroundStyle(.primary)
            }
            .padding(.vertical, 6)
            .padding(.leading, -20)
        }
    }
}

#Preview {
    CategoriesViewEdit()
}

