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
    
    // Isso é como a view espera receber o ExpensesViewModel: do ambiente
    @EnvironmentObject var expensesViewModel: ExpensesViewModel
    
    @State private var isCategoryModalPresented = false
    @State private var showSuccessAlert = false
    
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
            .hideKeyboardOnTap()
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
                            .foregroundStyle(.red)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Adicionar") {
                        let sucesso = viewModel.criarTransacao(
                            categoria: selectedCategory,
                            subcategoria: selectedSubcategory,
                            expensesViewModel: expensesViewModel // Passa a instância do EnvironmentObject
                        )

                        if sucesso {
                            showSuccessAlert = true
                            selectedCategory = nil
                            selectedSubcategory = nil
                        }
                    }
                    .disabled(viewModel.amount <= 0 || selectedCategory == nil || selectedSubcategory == nil)
                }
            }
            .sheet(isPresented: $isCategoryModalPresented) {
                CategorySelectionSheet(
                    selectedSubcategory: $selectedSubcategory,
                    isPresented: $isCategoryModalPresented,
                    selectedCategory: $selectedCategory
                )
            }
            .alert("Transação registrada", isPresented: $showSuccessAlert) {
                Button("OK") {
                    dismiss()
                }
            }
        }
    }
    
    // 🔧 Seção de detalhes da transação
    private var transactionDetailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            CategoryPicker(
                selectedSubcategory: $selectedSubcategory,
                selectedCategory: $selectedCategory,
                isCategorySheetPresented: $isCategoryModalPresented
            )
            
            DescriptionField(description: $viewModel.description) // Agora opcional
            
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


// MARK: - Preview
#Preview {
    PreviewWrapper()
        .environment(\.sizeCategory, .medium)
}

struct PreviewWrapper: View {
    @State private var selectedSubcategory: Subcategoria? = nil
    @State private var selectedCategory: Categoria? = nil
    
    // Crie a instância do ViewModel que será fornecida ao ambiente
    @StateObject private var expensesViewModelForPreview = ExpensesViewModel()
    
    var body: some View {
        // Agora, use o modificador .environmentObject para injetar o ViewModel
        AddTransactionView(
            selectedSubcategory: $selectedSubcategory,
            selectedCategory: $selectedCategory
            // Remova o parâmetro 'expensesViewModel' daqui!
        )
        .environmentObject(expensesViewModelForPreview) // <--- FORMA CORRETA DE INJETAR
    }
}

// MARK: - Utility
extension View {
    func hideKeyboardOnTap() -> some View {
        self.onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}
