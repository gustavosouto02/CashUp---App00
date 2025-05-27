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

struct RepeatOptionPicker: View {
    @Binding var repeatOption: RepeatOption
    @Binding var isRepeatDialogPresented: Bool
    @Binding var repeatEndDate: Date?
    var selectedDate: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Button(action: {
                    isRepeatDialogPresented = true
                }) {
                    HStack(spacing: 4) {
                        Label("Repetir", systemImage: "repeat")
                            .font(.title2)
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
                        repeatOption = option
                        if option == .nunca {
                            repeatEndDate = nil
                        }
                    }
                }
            }
            

            if repeatOption != .nunca {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Parar em")
                            .font(.headline)
                        
                        Spacer()
                        
                        DatePicker(
                            "Data de término",
                            selection: Binding(
                                get: { repeatEndDate ?? selectedDate },
                                set: { newValue in repeatEndDate = newValue }
                            ),
                            in: selectedDate..., // Não permite datas anteriores à data selecionada
                            displayedComponents: [.date]
                        )
                        .datePickerStyle(.compact)
                        .labelsHidden()
                    }
                }
                .padding(.top, 8)
            }
        }
    }
}
