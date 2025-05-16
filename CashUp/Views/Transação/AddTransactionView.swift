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
    
    @Binding var selectedSubcategory: Subcategoria?
    @Binding var selectedCategory: Categoria?
    
    @State private var isCategoryModalPresented = false

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Seletor de Tipo de Transação
                        TransactionPicker(selectedTransactionType: $viewModel.selectedTransactionType)

                        CurrencyAmountField(amount: $viewModel.amount)
                            .frame(maxWidth: .infinity, alignment: .center)

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
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        selectedSubcategory = nil
                        selectedCategory = nil
                        viewModel.description = ""
                        viewModel.amount = 0

                        dismiss()
                    }) {
                        Text("Cancelar")
                            .foregroundColor(.red)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Action to add the transaction
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
        .sheet(isPresented: $isCategoryModalPresented) {
            CategorySelectionSheet(
                selectedSubcategory: $selectedSubcategory,
                isPresented: $isCategoryModalPresented,
                selectedCategory: $selectedCategory
            )
        }
        .onChange(of: selectedSubcategory) { _, newValue in
            if let newSub = newValue {
                viewModel.selectedSubcategory = newSub
                viewModel.selectedCategory = selectedCategory
            }
        }

    }

    private var transactionDetailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            CategoryPicker(
                selectedSubcategory: $selectedSubcategory,
                selectedCategory: $selectedCategory,
                isCategorySheetPresented: $isCategoryModalPresented
            )

            DescriptionField(description: $viewModel.description)

            DatePickerField(
                selectedDate: $viewModel.selectedDate,
                formattedDate: viewModel.formatDate(viewModel.selectedDate)
            )

            RepeatOptionPicker(
                repeatOption: $viewModel.repeatOption,
                isRepeatDialogPresented: $viewModel.isRepeatDialogPresented,
                repeatEndDate: $viewModel.repeatEndDate,
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
    PreviewWrapper()
    .environment(\.sizeCategory, .medium)
}

struct PreviewWrapper: View {
    @State private var selectedSubcategory: Subcategoria? = nil
    @State private var selectedCategory: Categoria? = nil

    var body: some View {
        AddTransactionView(
            selectedSubcategory: $selectedSubcategory,
            selectedCategory: $selectedCategory
        )
    }
}

