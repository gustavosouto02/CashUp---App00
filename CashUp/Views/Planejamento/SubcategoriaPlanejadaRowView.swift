//
//  SubcategoriaPlanejadaRowView.swift
//  CashUp
//
//  Created by Gustavo Souto Pereira on 19/05/25.
//

import SwiftUI

struct SubcategoriaPlanejadaRowView: View {
    @Binding var sub: SubcategoriaPlanejada
    let corIcone: Color
    let onDelete: () -> Void
    var isEditing: Bool
    var isSelected: Bool
    var toggleSelection: () -> Void = {}

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 6) {
                if isEditing {
                    Button(action: toggleSelection) {
                        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(isSelected ? .blue : .gray)
                            .imageScale(.large)
                    }
                    .buttonStyle(PlainButtonStyle()) // remove efeito padrão de botão
                }

                CategoriasViewIcon(systemName: sub.subcategoria.icon, cor: corIcone, size: 22)

                Text(sub.subcategoria.nome)
                    .font(.body)

                Spacer()

                TextField("R$", text: $sub.valorPlanejado)
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
            .contentShape(Rectangle()) // permite tap em toda a área da linha
            .onTapGesture {
                if isEditing {
                    toggleSelection()
                }
            }

            Divider()
        }
    }
}

