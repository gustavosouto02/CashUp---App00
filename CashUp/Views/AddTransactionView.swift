import SwiftUI

struct AddTransactionView: View {
    @Environment(\.sizeCategory) var sizeCategory
    @Environment(\.dismiss) private var dismiss

    @StateObject private var viewModel = AddTransactionViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Seletor de Tipo de Transação
                        TransactionPicker(selectedTransactionType: $viewModel.selectedTransactionType)

                        AmountField(amount: $viewModel.amount)

                        transactionDetailsSection
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(12)
                    .padding(.top, 16)
                }
            }
            .navigationTitle("Registrar Transação")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        // Ação para cancelar
                        dismiss()
                    }) {
                        Text("Cancelar")
                            .foregroundColor(.red)
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        // Ação para adicionar
                    }) {
                        Text("Adicionar")
                    }
                }
            }
            .overlay(
                Divider()
                    .background(Color.gray)
                    .frame(height: 1)
                    .padding(.top, 2), alignment: .top
            )
        }
    }

    // MARK: - Seção de Detalhes da Transação
    private var transactionDetailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            // Categoria
            HStack(spacing: 12) {
                Image(systemName: "star.fill")
                    .resizable()
                    .frame(width: 24, height: 24)

                Button(action: {
                    // Ação para selecionar a categoria
                }) {
                    Text(viewModel.selectedCategory)
                        .font(.title2)
                        .foregroundColor(.primary) // para seguir o estilo do sistema
                }

                Spacer()
            }
            .padding(.vertical, 8)

            Divider()

            // Descrição
            HStack(spacing: 12) {
                Label{
                    Text("Descrição")
                        .font(.title2)
                } icon: {
                    Image(systemName: "text.justify.left")
                        .resizable()
                        .frame(width: 24, height: 24)
                }
                TextField("Opcional", text: $viewModel.description)
                    .font(.headline)
                    .padding(.vertical, 8)
            }

            Divider()

            // Data
            HStack {
                Image(systemName: "calendar")
                    .resizable()
                    .frame(width: 24, height: 24)

                Text(viewModel.formatDate(viewModel.selectedDate))
                    .font(.title2)

                Spacer()
                
                DatePicker(
                    "",
                    selection: $viewModel.selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.compact) // Usa estilo mais enxuto
                .labelsHidden()            // Oculta o label para não ocupar espaço
                .frame(maxWidth: 120)      // Limita largura máxima
            }



            Divider()

            // Repetir
            HStack {
                Button(action: {
                    viewModel.isRepeatDialogPresented = true
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
                        Text(viewModel.repeatOption)
                            .foregroundColor(.blue)
                        Image(systemName: "chevron.right")
                            .font(.caption)
                    }
                }
            }
            .confirmationDialog("Escolha a frequência de repetição", isPresented: $viewModel.isRepeatDialogPresented, titleVisibility: .visible) {
                ForEach(viewModel.repeatOptions, id: \.self) { option in
                    Button(option) {
                        viewModel.setRepeatOption(option)
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
        .frame(minHeight: 120)
    }
}

// MARK: - Campo para Valor
struct AmountField: View {
    @Binding var amount: Double

    private var numberFormatter: NumberFormatter {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = 2
        f.minimumFractionDigits = 0
        return f
    }

    var body: some View {
        HStack {
            TextField("0", value: $amount, formatter: numberFormatter)
                .keyboardType(.decimalPad)
                .font(.system(size: 64, weight: .bold))
                .multilineTextAlignment(.center)
                .padding()
                .cornerRadius(8)
                .frame(height: 80)
                .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Preview
#Preview {
    AddTransactionView()
}
