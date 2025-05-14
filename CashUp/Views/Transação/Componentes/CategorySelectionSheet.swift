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

    var body: some View {
        NavigationStack {
            CategoriesView { selectedName in
                if let sub = CategoriasData.todas
                    .flatMap({ $0.subcategorias })
                    .first(where: { $0.nome == selectedName }) {
                    selectedSubcategory = sub
                }
                isPresented = false
            }
            .navigationTitle("Categorias")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancelar") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

