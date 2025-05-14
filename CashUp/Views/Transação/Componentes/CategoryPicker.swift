//
//  CategoryPicker.swift
//  CashUp
//
//  Created by Gustavo Souto Pereira on 13/05/25.
//

import SwiftUI

struct CategoryPicker: View {
    @State private var isCategorySheetPresented = false
    @Binding var selectedSubcategory: Subcategoria?

    var body: some View {
        VStack(spacing: 8) {
            Button {
                isCategorySheetPresented = true
            } label: {
                HStack(spacing: 12) {
                    if let sub = selectedSubcategory,
                       let categoria = categoriaPara(subcategoria: sub) {
                        CategoriasViewIcon(systemName: sub.icon, cor: categoria.cor, size: 24)
                        Text(sub.nome)
                            .font(.title2)
                            .foregroundColor(.primary)
                    } else {
                        Image(systemName: "star.fill")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.primary)

                        Text("Selecionar categoria")
                            .font(.title2)
                            .foregroundColor(.primary)
                    }

                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 8)
            }

            Divider()
        }
        .fullScreenCover(isPresented: $isCategorySheetPresented) {
            CategorySelectionSheet(
                selectedSubcategory: $selectedSubcategory,
                isPresented: $isCategorySheetPresented
            )
        }
    }

    private func categoriaPara(subcategoria: Subcategoria) -> Categoria? {
        CategoriasData.todas.first(where: {
            $0.subcategorias.contains(where: { $0.nome == subcategoria.nome })
        })
    }
}
