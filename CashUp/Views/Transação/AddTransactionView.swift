//
//  AddTransactionView.swift
//  CashUp
//
//  Created by Gustavo Souto Pereira on 13/05/25.
//

import SwiftUI

struct AddTransactionView: View {
    @Environment(\.sizeCategory) var sizeCategory
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = AddTransactionViewModel()
    
    @State private var isCategoryModalPresented = false


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

    private var transactionDetailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            CategoryPicker(selectedSubcategory: $viewModel.selectedSubcategory)

            DescriptionField(description: $viewModel.description)

            DatePickerField(
                selectedDate: $viewModel.selectedDate,
                formattedDate: viewModel.formatDate(viewModel.selectedDate)
            )

            RepeatOptionPicker(
                repeatOption: $viewModel.repeatOption,
                isRepeatDialogPresented: $viewModel.isRepeatDialogPresented,
                repeatEndDate: $viewModel.repeatEndDate,
                repeatOptions: viewModel.repeatOptions,
                selectedDate: viewModel.selectedDate
            )
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
        .frame(minHeight: 120)
    }
}

#Preview {
    AddTransactionView()
        .environment(\.sizeCategory, .medium) // Simula um tamanho de categoria
}
