//
//  ExpensesViewModel.swift
//  CashUp
//
//  Created by [Seu Nome] on [Data].
//

import Foundation
import SwiftData
import SwiftUI

@MainActor
class ExpensesViewModel: ObservableObject, ExpenseCalculation {
    
    // MARK: - Properties
    
    var modelContext: ModelContext
    
    @Published var currentMonth: Date = Date().startOfMonth() {
        didSet {
            if oldValue.startOfMonth() != currentMonth.startOfMonth() {
                objectWillChange.send()
            }
        }
    }
    
    @Published var selectedTransactionType: Int = 0 {
        didSet {
            objectWillChange.send()
        }
    }
    
    var availableCategories: [CategoriaModel] {
        let sortDescriptor = SortDescriptor(\CategoriaModel.nome)
        let fetchDescriptor = FetchDescriptor<CategoriaModel>(sortBy: [sortDescriptor])
        do {
            return try modelContext.fetch(fetchDescriptor)
        } catch {
            print("Erro ao buscar CategoriaModel para availableCategories: \(error)")
            return []
        }
    }
    
    // MARK: - Init
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func configure(with newModelContext: ModelContext) {
        if self.modelContext !== newModelContext {
            self.modelContext = newModelContext
            print("ExpensesViewModel: ModelContext reconfigurado via configure().")
            objectWillChange.send()
        }
    }
    
    // MARK: - Adição e Remoção de Transações
    
    func addExpense(expenseData: ExpenseModel,
                    categoriaModel: CategoriaModel,
                    subcategoriaModel: SubcategoriaModel) {
        guard expenseData.categoria?.id == categoriaModel.id,
              expenseData.subcategoria?.id == subcategoriaModel.id else {
            print("Erro: Inconsistência entre expenseData e os modelos fornecidos.")
            return
        }

        modelContext.insert(expenseData)

        print("ExpenseModel inserido com ID: \(expenseData.id), Desc: \(expenseData.expenseDescription)")

        do {
            try modelContext.save()
            print("Contexto salvo após adicionar despesa.")
            // Avisar que mudou
            objectWillChange.send()
        } catch {
            print("Erro ao salvar contexto após adicionar despesa: \(error.localizedDescription)")
        }
    }

    
    func removeExpense(_ expenseModel: ExpenseModel) {
        modelContext.delete(expenseModel)
        do {
            try modelContext.save()
            objectWillChange.send()
        } catch {
            print("Erro ao salvar contexto após remover despesa: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Utilitários de Busca
    
    func findCategoriaModel(by id: UUID) -> CategoriaModel? {
        let predicate = #Predicate<CategoriaModel> { $0.id == id }
        let fetchDescriptor = FetchDescriptor(predicate: predicate)
        do {
            return try modelContext.fetch(fetchDescriptor).first
        } catch {
            print("Erro ao buscar CategoriaModel por ID \(id): \(error)")
            return nil
        }
    }
    
    func findSubcategoriaModel(by id: UUID) -> SubcategoriaModel? {
        let predicate = #Predicate<SubcategoriaModel> { $0.id == id }
        let fetchDescriptor = FetchDescriptor(predicate: predicate)
        do {
            return try modelContext.fetch(fetchDescriptor).first
        } catch {
            print("Erro ao buscar SubcategoriaModel por ID \(id): \(error)")
            return nil
        }
    }
    
    // MARK: - Fetch Interno
    
    private func fetchExpenses(forMonth month: Date, isIncome: Bool?) -> [ExpenseModel] {
        let calendar = Calendar.current
        guard let monthInterval = calendar.dateInterval(of: .month, for: month) else {
            return []
        }
        let startDate = monthInterval.start
        let endDate = monthInterval.end
        
        let predicate: Predicate<ExpenseModel>
        if let incomeStatus = isIncome {
            predicate = #Predicate<ExpenseModel> {
                $0.date >= startDate && $0.date < endDate && $0.isIncome == incomeStatus
            }
        } else {
            predicate = #Predicate<ExpenseModel> {
                $0.date >= startDate && $0.date < endDate
            }
        }
        
        let fetchDescriptor = FetchDescriptor<ExpenseModel>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        do {
            return try modelContext.fetch(fetchDescriptor)
        } catch {
            print("Falha ao buscar despesas para o mês \(month.formatted()): \(error)")
            return []
        }
    }
    
    // MARK: - Totais
    
    func totalIncomeForCurrentMonth() -> Double {
        fetchExpenses(forMonth: currentMonth, isIncome: true)
            .reduce(0) { $0 + $1.amount }
    }
    
    func totalExpenseForCurrentMonth() -> Double {
        fetchExpenses(forMonth: currentMonth, isIncome: false)
            .reduce(0) { $0 + $1.amount }
    }
    
    // MARK: - Transações Filtradas
    
    func transactionsForCurrentMonth() -> [ExpenseModel] {
        fetchExpenses(forMonth: currentMonth, isIncome: nil)
    }
    
    func expensesOnlyForCurrentMonth() -> [ExpenseModel] {
        fetchExpenses(forMonth: currentMonth, isIncome: false)
    }
    
    func incomesOnlyForCurrentMonth() -> [ExpenseModel] {
        fetchExpenses(forMonth: currentMonth, isIncome: true)
    }
    
    var transacoesExibidas: [ExpenseModel] {
        selectedTransactionType == 0
        ? expensesOnlyForCurrentMonth()
        : incomesOnlyForCurrentMonth()
    }
    
    // MARK: - Navegação por Mês
    
    func navigateMonth(isNext: Bool) {
        let calendar = Calendar.current
        if let newDate = calendar.date(byAdding: .month, value: isNext ? 1 : -1, to: currentMonth) {
            currentMonth = newDate.startOfMonth()
        }
    }
    
    // MARK: - ExpenseCalculation Protocol
    
    func calcularTotalGastoEmCategoriasPlanejadas(
        paraMes mes: Date,
        categoriasPlanejadas: [CategoriaPlanejadaModel]
    ) -> Double {
        let despesasDoMes = fetchExpenses(forMonth: mes, isIncome: false)
        
        // Extrai todos os IDs das subcategorias planejadas
        let subcategoriaIDs: [UUID] = categoriasPlanejadas
            .flatMap { $0.subcategoriasPlanejadas ?? [] }
            .compactMap { $0.subcategoriaOriginal?.id }
        
        // Para cada subcategoria ID, calcula o gasto
        var totalGasto: Double = 0.0
        for subId in subcategoriaIDs {
            let gastoNaSubcategoria = despesasDoMes
                .filter { $0.subcategoria?.id == subId }
                .reduce(0.0) { $0 + $1.amount }
            
            totalGasto += gastoNaSubcategoria
        }
        
        return totalGasto
    }

    
    func calcularTotalGastoParaCategoria(_ categoriaPlanejada: CategoriaPlanejadaModel, paraMes mes: Date) -> Double {
        let despesasDoMes = fetchExpenses(forMonth: mes, isIncome: false)
        return categoriaPlanejada.subcategoriasPlanejadas?
            .compactMap { $0.subcategoriaOriginal?.id }
            .reduce(0.0) { total, subId in
                total + despesasDoMes.filter { $0.subcategoria?.id == subId }
                                     .reduce(0.0) { $0 + $1.amount }
            } ?? 0.0
    }
    
    func calcularTotalGastoParaSubcategoria(_ subcategoriaPlanejada: SubcategoriaPlanejadaModel, paraMes mes: Date) -> Double {
        guard let subOriginalID = subcategoriaPlanejada.subcategoriaOriginal?.id else { return 0.0 }
        let despesasDoMes = fetchExpenses(forMonth: mes, isIncome: false)
        return despesasDoMes
            .filter { $0.subcategoria?.id == subOriginalID }
            .reduce(0.0) { $0 + $1.amount }
    }
}
