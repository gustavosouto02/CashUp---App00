//
//  SubcategoriaPlanejadaRowView.swift
//  CashUp
//
//  Created by Gustavo Souto Pereira on 19/05/25.
//


import SwiftUI
import SwiftData

struct SubcategoriaPlanejadaRowView: View {

    @Bindable var subPlanejadaModel: SubcategoriaPlanejadaModel
    
    let corIconeCategoriaPai: Color
    var isEditing: Bool
    var isSelected: Bool
    var toggleSelection: () -> Void

    @Binding var valorPlanejadoStringBinding: String

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 6) {
                if isEditing {
                    Button(action: toggleSelection) {
                        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(isSelected ? .blue : .gray)
                            .imageScale(.large)
                    }
                    .buttonStyle(PlainButtonStyle())
                }

                CategoriasViewIcon(
                    systemName: subPlanejadaModel.subcategoriaOriginal?.icon ?? "questionmark.circle",
                    cor: corIconeCategoriaPai,
                    size: 22
                )

                Text(subPlanejadaModel.subcategoriaOriginal?.nome ?? "Subcategoria Desconhecida")
                    .font(.body)

                Spacer()

                TextField("R$", text: $valorPlanejadoStringBinding)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80) 
                    .padding(5)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            }
            .padding(.vertical, 10)
            .background(
                isEditing && isSelected ? Color.blue.opacity(0.1) : Color.clear
            )
            .contentShape(Rectangle())
            .onTapGesture {
                if isEditing {
                    toggleSelection()
                }
            }

            Divider()
        }
    }
}
