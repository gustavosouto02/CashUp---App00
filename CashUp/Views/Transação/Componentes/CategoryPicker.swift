//
//  CategoryPicker.swift
//  CashUp
//
//  Created by Gustavo Souto Pereira on 13/05/25.
//

import SwiftUI

struct CategoryPicker: View {
    @Binding var selectedSubcategory: Subcategoria?
    @Binding var selectedCategory: Categoria?
    @Binding var isCategorySheetPresented: Bool

    var body: some View {
        VStack(spacing: 8) {
            Button {
                isCategorySheetPresented = true
            } label: {
                HStack(spacing: 12) {
                    if let sub = selectedSubcategory,
                       let cat = selectedCategory {
                        CategoriasViewIcon(systemName: sub.icon, cor: cat.color, size: 24)
                        Text(sub.nome)
                            .font(.title2)
                            .foregroundStyle(.primary)
                    } else {
                        Image(systemName: "square.grid.2x2")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundStyle(.primary)

                        Text("Selecionar categoria")
                            .font(.title2)
                            .foregroundStyle(.primary)
                    }

                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.gray)
                }
                .padding(.vertical, 8)
            }
            .buttonStyle(.plain)

            Divider()
        }
    }
    
}



