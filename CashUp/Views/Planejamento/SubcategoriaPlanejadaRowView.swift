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

    // MARK: - Local Binding for TextField
    // This computed property creates a Binding<String> from the Binding<Double>
    private var valorPlanejadoString: Binding<String> {
        Binding<String>(
            get: {
                // Format the Double to a String for display in the TextField
                let formatter = NumberFormatter()
                formatter.numberStyle = .decimal // Use decimal style for user input
                formatter.maximumFractionDigits = 2
                formatter.minimumFractionDigits = 2
                formatter.locale = Locale(identifier: "pt_BR") // Use Brazilian locale for comma decimal separator

                // Return formatted string, or empty string if nil
                return formatter.string(from: NSNumber(value: sub.valorPlanejado)) ?? ""
            },
            set: { newValueString in
                // Clean the input string and convert it back to Double
                let cleanedString = newValueString.replacingOccurrences(of: ",", with: ".") // Replace comma with dot for Double conversion
                                                  .filter { "0123456789.".contains($0) } // Allow only numbers and a single dot

                // Convert to Double, defaulting to 0.0 if conversion fails
                let newDoubleValue = Double(cleanedString) ?? 0.0

                // Update the original @Binding var sub.valorPlanejado
                sub.valorPlanejado = newDoubleValue
            }
        )
    }
    
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

                TextField("R$", text: valorPlanejadoString)
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
