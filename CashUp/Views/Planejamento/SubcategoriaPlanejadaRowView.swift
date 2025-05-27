//
//  SubcategoriaPlanejadaRowView.swift
//  CashUp
//
//  Created by Gustavo Souto Pereira on 19/05/25.
//

// Arquivo: CashUp/Views/Planejamento/SubcategoriaPlanejadaRowView.swift
// Refatorado para SwiftData

import SwiftUI
import SwiftData

struct SubcategoriaPlanejadaRowView: View {
    // Agora recebe um Binding para o @Model SubcategoriaPlanejadaModel.
    // Este binding deve vir da PlanningPlanejarView, que o obtém do array de modelos do PlanningViewModel.
    // É crucial que este seja um binding para um objeto gerenciado pelo SwiftData.
    @Bindable var subPlanejadaModel: SubcategoriaPlanejadaModel
    
    let corIconeCategoriaPai: Color
    var isEditing: Bool
    var isSelected: Bool
    var toggleSelection: () -> Void
    
    // O PlanningViewModel agora fornecerá o Binding<String> para o valorPlanejado.
    // Precisamos de uma referência ao PlanningViewModel aqui ou que o binding seja passado.
    // Para simplificar, vamos assumir que PlanningPlanejarView passa o Binding<String> já formatado.
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

                // Acessa as propriedades do subcategoriaOriginal (que é SubcategoriaModel)
                CategoriasViewIcon(
                    systemName: subPlanejadaModel.subcategoriaOriginal?.icon ?? "questionmark.circle",
                    cor: corIconeCategoriaPai, // A cor vem da CategoriaModel pai
                    size: 22
                )

                Text(subPlanejadaModel.subcategoriaOriginal?.nome ?? "Subcategoria Desconhecida")
                    .font(.body)

                Spacer()

                // Usa o Binding<String> passado pela PlanningPlanejarView,
                // que por sua vez o obteve do PlanningViewModel.
                TextField("R$", text: $valorPlanejadoStringBinding)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80) // Ajuste conforme necessário
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
