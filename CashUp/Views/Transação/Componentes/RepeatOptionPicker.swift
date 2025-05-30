import SwiftUI

enum RepeatOption: String, CaseIterable, Identifiable, Codable {
    case nunca = "Nunca"
    case diariamente = "Diariamente"
    case semanalmente = "Semanalmente"
    case aCada10Dias = "A cada 10 dias"
    case mensalmente = "Mensalmente"
    case anualmente = "Anualmente"
    
    var id: String { self.rawValue }
}

import SwiftUI

// Enum RepeatOption (como você já tem)
// enum RepeatOption: String, CaseIterable, Identifiable, Codable { ... }

struct RepeatOptionPicker: View {
    @Binding var repeatOption: RepeatOption
    @Binding var isRepeatDialogPresented: Bool // Para o dialog de seleção de frequência
    @Binding var repeatEndDate: Date?
    var selectedDate: Date // Data da transação, para o limite inferior do DatePicker de repeatEndDate

    // NOVO: Estado para o alerta de sugestão de data final
    @State private var shouldSuggestEndDate: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Button(action: {
                    isRepeatDialogPresented = true
                }) {
                    HStack(spacing: 4) {
                        Label("Repetir", systemImage: "repeat")
                            .font(.title2) // Mantido como title2
                            .foregroundStyle(.primary)
                        Spacer()
                        Image(systemName: "chevron.left")
                            .font(.caption)
                            .foregroundStyle(.blue)
                        Text(repeatOption.rawValue)
                            .foregroundStyle(.blue)
                            .fontWeight(.semibold)
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.blue)
                    }
                }
            }
            .confirmationDialog("Escolha a frequência de repetição", isPresented: $isRepeatDialogPresented, titleVisibility: .visible) {
                ForEach(RepeatOption.allCases) { option in
                    Button(option.rawValue) {
                        let oldValue = repeatOption
                        repeatOption = option
                        if option == .nunca {
                            repeatEndDate = nil
                            shouldSuggestEndDate = false
                        } else if oldValue == .nunca && option != .nunca && repeatEndDate == nil {
                            // Se estava em "Nunca" e mudou para uma repetição real, E a data final ainda não foi definida,
                            // sugere definir a data final.
                            shouldSuggestEndDate = true
                        }else if option != .nunca && repeatEndDate != nil {
                            // Se já tem data final e escolheu uma repetição, não precisa mais sugerir.
                            shouldSuggestEndDate = false
                        }
                    }
                }
            }
            
            // DatePicker para repeatEndDate (já existente e correto)
            if repeatOption != .nunca {
                VStack(alignment: .leading, spacing: 8) { // Mantido o VStack para consistência visual
                    Divider().padding(.top, 4) // Adiciona um divisor visual
                    HStack {
                        Text("Parar repetição em") // Texto mais claro
                            .font(.headline)
                        Spacer()
                        DatePicker(
                            "Data de término",
                            selection: Binding( // Binding para lidar com o valor opcional
                                get: { repeatEndDate ?? calculateDefaultEndDate() },
                                set: { newValue in
                                    repeatEndDate = newValue
                                    shouldSuggestEndDate = false
                                }
                            ),
                            in: selectedDate..., // A data de término não pode ser anterior à data da transação
                            displayedComponents: [.date]
                        )
                        .datePickerStyle(.compact)
                        .labelsHidden()
                        .environment(\.locale, Locale(identifier: "pt_BR"))
                        .padding(shouldSuggestEndDate && repeatEndDate == nil ? 1 : 0) // Adiciona padding para o anel
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(shouldSuggestEndDate && repeatEndDate == nil ? Color.orange : Color.clear, lineWidth: 2)
                                .animation(.easeInOut, value: shouldSuggestEndDate && repeatEndDate == nil)
                        )
                    }
                    if shouldSuggestEndDate && repeatEndDate == nil {
                        Text("Opcional: defina uma data para encerrar a repetição ou ela continuará por 3 meses como padrão.")
                            .font(.caption2)
                            .foregroundColor(.orange)
                            .padding(.leading, 2) // Pequena indentação
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
                .padding(.top, 8)
                .animation(.default, value: repeatOption)
            }
        }
        .onChange(of: repeatOption) { _, newOption in
            if newOption == .nunca {
                shouldSuggestEndDate = false
            }
            if newOption != .nunca && repeatEndDate != nil {
                shouldSuggestEndDate = false
            }
        }
    }

    // Função para calcular uma data final padrão se nenhuma estiver definida (ex: 1 ano no futuro)
    private func calculateDefaultEndDate() -> Date {
        return Calendar.current.date(byAdding: .month, value: 3, to: selectedDate) ?? selectedDate
    }
}
