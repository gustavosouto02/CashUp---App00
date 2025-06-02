//
//  AddTransactionView.swift
//  CashUp
//
//  Created by Gustavo Souto Pereira on 27/05/25.
//

import SwiftUI
import SwiftData

struct AddTransactionView: View {
    @Environment(\.sizeCategory) var sizeCategory
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @StateObject private var addTransactionVM = AddTransactionViewModel()
    
    @State private var selectedSubcategoryModel: SubcategoriaModel? = nil
    @State private var selectedCategoryModel: CategoriaModel? = nil
    
    @EnvironmentObject var expensesViewModel: ExpensesViewModel
    
    @State private var isCategoryModalPresented = false
    @State private var showSuccessAlert = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(alignment: .center, spacing: 16) {
                        TransactionPicker(selectedTransactionType: $addTransactionVM.selectedTransactionType)
                            .padding(.horizontal)

                        CurrencyAmountField(amount: $addTransactionVM.amount)

                        transactionDetailsSection
                            .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
            }
            .hideKeyboardOnTap()
            .navigationTitle(addTransactionVM.selectedTransactionType == 0 ? "Registrar Despesa" : "Registrar Receita")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        selectedSubcategoryModel = nil
                        selectedCategoryModel = nil
                        addTransactionVM.resetFields()
                        dismiss()
                    }
                    .foregroundStyle(.red)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Adicionar") {

                        let sucesso = addTransactionVM.criarTransacaoEChamarClosure(
                            categoriaModelApp: selectedCategoryModel,
                            subcategoriaModelApp: selectedSubcategoryModel, modelContext: modelContext
                        )

                        if sucesso {
                            showSuccessAlert = true
                            selectedCategoryModel = nil
                            selectedSubcategoryModel = nil
                        } else {
                            errorMessage = "Por favor, preencha o valor e selecione uma categoria."
                            showErrorAlert = true
                        }
                    }
                    .disabled(addTransactionVM.amount <= 0 || selectedCategoryModel == nil || selectedSubcategoryModel == nil)
                }
            }
            .sheet(isPresented: $isCategoryModalPresented) {
                let categoriesVM = CategoriesViewModel(
                    modelContext: self.modelContext,
                    transactionType: addTransactionVM.selectedTransactionType == 0 ? .despesa : .receita // Passa o tipo
                )
                CategorySelectionSheet(
                    viewModel: categoriesVM,
                    selectedSubcategoryModel: $selectedSubcategoryModel,
                    isPresented: $isCategoryModalPresented,
                    selectedCategoryModel: $selectedCategoryModel
                )
            }
            .alert("Transação Registrada!", isPresented: $showSuccessAlert) {
                Button("OK") { dismiss() }
            }
            .alert("Erro", isPresented: $showErrorAlert) {
                Button("OK") {}
            } message: {
                Text(errorMessage)
            }
            .onAppear {

                addTransactionVM.onTransactionCreated = { expenseModelCriado, categoriaModelSelecionada, subcategoriaModelSelecionada in

                    expensesViewModel.addExpense(
                        expenseData: expenseModelCriado,
                        categoriaModel: categoriaModelSelecionada,
                        subcategoriaModel: subcategoriaModelSelecionada
                    )
                }
            }
        }
    }
    
    private var transactionDetailsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            CategoryPicker(
                selectedSubcategoryModel: $selectedSubcategoryModel,
                selectedCategoryModel: $selectedCategoryModel,
                isCategorySheetPresented: $isCategoryModalPresented
            )
            
            DescriptionField(expenseDescription: $addTransactionVM.expenseDescription)

            
            DatePickerField(
                selectedDate: $addTransactionVM.selectedDate,
                formattedDate: addTransactionVM.formatDate(addTransactionVM.selectedDate)
            )
            
            RepeatOptionPicker(
                repeatOption: $addTransactionVM.repeatOption,
                isRepeatDialogPresented: $addTransactionVM.isRepeatDialogPresented,
                repeatEndDate: $addTransactionVM.repeatEndDate,
                selectedDate: addTransactionVM.selectedDate
            )
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

