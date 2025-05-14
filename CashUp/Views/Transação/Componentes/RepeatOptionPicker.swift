import SwiftUI

struct RepeatOptionPicker: View {
    @Binding var repeatOption: String
    @Binding var isRepeatDialogPresented: Bool
    @Binding var repeatEndDate: Date?
    var repeatOptions: [String]
    var selectedDate: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Button(action: {
                    isRepeatDialogPresented = true
                }) {
                    HStack(spacing: 4) {
                        Label {
                            Text("Repetir")
                                .font(.title2)
                        } icon:{
                            Image(systemName: "repeat")
                                .resizable()
                                .frame(width: 24, height: 24)
                        }
                        .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.left")
                            .font(.caption)
                        Text(repeatOption)
                            .foregroundColor(.blue)
                        Image(systemName: "chevron.right")
                            .font(.caption)
                    }
                }
            }
            .confirmationDialog("Escolha a frequência de repetição", isPresented: $isRepeatDialogPresented, titleVisibility: .visible) {
                ForEach(repeatOptions, id: \.self) { option in
                    Button(option) {
                        repeatOption = option
                        if option == "Nunca" {
                            repeatEndDate = nil
                        }
                    }
                }
            }

            // DatePicker visível apenas se repetição está ativada
            if repeatOption != "Nunca" {
                VStack(alignment: .leading, spacing: 8) {
                    HStack{
                        Text("Parar em")
                            .font(.headline)
                        
                        Spacer()
                        
                        DatePicker(
                            "Data de término",
                            selection: Binding(
                                get: { repeatEndDate ?? Date() },
                                set: { newValue in
                                    repeatEndDate = newValue
                                }
                            ),
                            in: selectedDate..., // <-- Evita datas passadas
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
