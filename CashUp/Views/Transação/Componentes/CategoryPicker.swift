//
//  CategoryPicker.swift
//  CashUp
//
//  Created by Gustavo Souto Pereira on 13/05/25.
//

import SwiftUI
import SwiftData

struct CategoryPicker: View {
    @Binding var selectedSubcategoryModel: SubcategoriaModel?
    @Binding var selectedCategoryModel: CategoriaModel?
    @Binding var isCategorySheetPresented: Bool

    var body: some View {
        VStack(spacing: 8) {
            Button {
                dismissKeyboard() 
                isCategorySheetPresented = true
            } label: {
                HStack {
                    if let subModel = selectedSubcategoryModel,
                       let catModel = selectedCategoryModel {
                        
                        CategoriasViewIcon(
                            systemName: subModel.icon,
                            cor: catModel.color,
                            size: 24
                        )
                        
                        Text(subModel.nome) 
                            .font(.title2)
                            .foregroundStyle(.primary)
                        
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.gray)
                    } else {
                        Image(systemName: "square.grid.2x2")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundStyle(.primary)

                        Text("Selecionar categoria")
                            .font(.title2)
                            .foregroundStyle(.primary)
                        
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.gray)
                    }
                }
                .padding(.vertical, 8)
            }
            .buttonStyle(.plain)

            Divider()
        }
    }
}

