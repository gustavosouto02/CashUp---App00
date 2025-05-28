// Arquivo: CashUp/Views/Home/HomeViewModel.swift
// Refatorado para SwiftData, melhorias sugeridas e dados para gráfico diário

import Combine
import Foundation
import SwiftData
import SwiftUI

@MainActor
class HomeViewModel: ObservableObject {
    let modelContext: ModelContext
    let planningViewModel: PlanningViewModel
    let expensesViewModel: ExpensesViewModel

    @Published var currentMonth: Date {
        didSet {
            let oldStart = oldValue.startOfMonth()
            let newStart = currentMonth.startOfMonth()
            if oldStart != newStart {
                if planningViewModel.currentMonth.startOfMonth() != newStart {
                    planningViewModel.currentMonth = newStart
                }
                if expensesViewModel.currentMonth.startOfMonth() != newStart {
                    expensesViewModel.currentMonth = newStart
                }
                updateCardData()
            }
        }
    }

    @Published var totalSpentMonth: Double = 0.0
    @Published var totalIncomeMonth: Double = 0.0 // Note: Calculation for this is not present in your updateCardData
    @Published var totalPlanejadoMes: Double = 0.0
    @Published var totalRestantePlanejadoMes: Double = 0.0
    @Published var categoriasResumo: [CategoriaResumo] = []
    @Published var categoriasPlanejadas: [CategoriaPlanejadaModel] = []

    // New property for the daily expense chart
    @Published var dailyExpenseChartData: [DailyExpenseItem] = []

    private var cancellables = Set<AnyCancellable>()

    init(modelContext: ModelContext,
         planningViewModel: PlanningViewModel,
         expensesViewModel: ExpensesViewModel) {
        self.modelContext = modelContext
        self.planningViewModel = planningViewModel
        self.expensesViewModel = expensesViewModel

        let initialMonth = Date().startOfMonth()
        _currentMonth = Published(initialValue: initialMonth)

        // Sincroniza meses iniciais
        if planningViewModel.currentMonth.startOfMonth() != initialMonth {
            planningViewModel.currentMonth = initialMonth
        }
        if expensesViewModel.currentMonth.startOfMonth() != initialMonth {
            expensesViewModel.currentMonth = initialMonth
        }

        setupBindings()
        updateCardData()
    }

    private func setupBindings() {
        planningViewModel.$currentMonth
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] newPlanningMonth in
                guard let self = self else { return }
                let newStart = newPlanningMonth.startOfMonth()
                if self.currentMonth.startOfMonth() != newStart {
                    self.currentMonth = newStart
                }
            }
            .store(in: &cancellables)

        expensesViewModel.$currentMonth
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] newExpensesMonth in
                guard let self = self else { return }
                let newStart = newExpensesMonth.startOfMonth()
                if self.currentMonth.startOfMonth() != newStart {
                    self.currentMonth = newStart
                }
            }
            .store(in: &cancellables)

        // Atualiza dados quando planning ou expenses mudarem
        planningViewModel.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.updateCardData() }
            .store(in: &cancellables)

        expensesViewModel.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.updateCardData() }
            .store(in: &cancellables)
    }

    var totalGastoEmCategoriasPlanejadas: Double {
        expensesViewModel.calcularTotalGastoEmCategoriasPlanejadas(
            paraMes: currentMonth,
            categoriasPlanejadas: categoriasPlanejadas
        )
    }

    func updateCardData() {
        // Assuming `expensesOnlyForCurrentMonth()` returns [ExpenseModel]
        // and these are already filtered to be only expense type transactions.
        let despesasDoMes = expensesViewModel.expensesOnlyForCurrentMonth()
        totalSpentMonth = despesasDoMes.reduce(0) { $0 + $1.amount }

        // Note: totalIncomeMonth is not being calculated here.
        // If you need it, you'll need to fetch income transactions and sum them.

        totalPlanejadoMes = planningViewModel.valorTotalPlanejadoParaMesAtual()

        let fetchedCategoriasPlanejadas = planningViewModel.getCategoriasPlanejadasForCurrentMonth()
        self.categoriasPlanejadas = fetchedCategoriasPlanejadas // Cache for computed property

        // Recalculate totalGastoEmCategoriasPlanejadas with potentially updated self.categoriasPlanejadas
        // This value is used for totalRestantePlanejadoMes
        let gastoCalculadoEmPlanejadas = expensesViewModel.calcularTotalGastoEmCategoriasPlanejadas(
            paraMes: currentMonth,
            categoriasPlanejadas: self.categoriasPlanejadas
        )
        totalRestantePlanejadoMes = totalPlanejadoMes - gastoCalculadoEmPlanejadas

        let gastosPorCategoria = Dictionary(grouping: despesasDoMes, by: { $0.categoria })

        let valoresPlanejados: [UUID: Double] = self.categoriasPlanejadas.reduce(into: [:]) { acc, plano in
            if let id = plano.categoriaOriginal?.id {
                acc[id] = plano.valorTotalPlanejado
            }
        }

        categoriasResumo = gastosPorCategoria.compactMap { (categoriaOpt, transacoes) in
            guard let categoria = categoriaOpt else { return nil }
            let total = transacoes.reduce(0) { $0 + $1.amount }
            let percentual = totalSpentMonth > 0 ? total / totalSpentMonth : 0
            let valorPlanejado = valoresPlanejados[categoria.id]
            let progresso: Double?
            if let valorPlanejado = valorPlanejado, valorPlanejado > 0 {
                progresso = min(total / valorPlanejado, 1.0)
            } else {
                progresso = nil
            }

            return CategoriaResumo(
                categoria: categoria,
                total: total,
                percentual: percentual,
                progressoPlanejado: progresso
            )
        }
        .sorted { $0.total > $1.total }

        // Add call to update daily expense chart data
        updateDailyExpenseChartData(for: currentMonth, allExpensesInMonth: despesasDoMes)
    }
    
    private func updateDailyExpenseChartData(for month: Date, allExpensesInMonth: [ExpenseModel]) {
        var dailyData: [DailyExpenseItem] = []
        let calendar = Calendar.current
        
        // Ensure `month` is the start of the month for consistency
        let startOfMonth = month.startOfMonth()
        
        guard let monthInterval = calendar.dateInterval(of: .month, for: startOfMonth),
              let daysInMonth = calendar.range(of: .day, in: .month, for: startOfMonth)?.count else {
            self.dailyExpenseChartData = []
            return
        }
        
        let firstDayOfMonthDate = monthInterval.start

        for dayOffset in 0..<daysInMonth {
            guard let currentDateForDay = calendar.date(byAdding: .day, value: dayOffset, to: firstDayOfMonthDate) else { continue }
            
            // Filter expenses for this specific day from the provided `allExpensesInMonth`
            // This assumes `allExpensesInMonth` are already confirmed to be of type "despesa".
            let expensesForSpecificDay = allExpensesInMonth.filter { expense in
                calendar.isDate(expense.date, inSameDayAs: currentDateForDay)
            }
            let totalForSpecificDay = expensesForSpecificDay.reduce(0) { $0 + $1.amount } // Use .amount as per your existing code
            
            dailyData.append(DailyExpenseItem(date: currentDateForDay,
                                              totalExpenses: totalForSpecificDay,
                                              isToday: calendar.isDateInToday(currentDateForDay)))
        }
        self.dailyExpenseChartData = dailyData
    }

    func loadHomeData(for month: Date) {
        let newMonth = month.startOfMonth()
        if currentMonth.startOfMonth() != newMonth { // Compare start of month to avoid redundant updates if time changes but month doesn't
            currentMonth = newMonth
        } else {
            updateCardData() // Refresh data even if month is the same, in case underlying data changed
        }
    }

    func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: NSNumber(value: value)) ?? "R$0,00"
    }
}

struct CategoriaResumo: Identifiable {
    var id: UUID { categoria.id } // Assumes CategoriaModel has a non-optional UUID id
    let categoria: CategoriaModel
    let total: Double
    let percentual: Double
    let progressoPlanejado: Double?
}

// In your HomeViewModel or a shared a DataTypes file
struct DailyExpenseItem: Identifiable {
    let id = UUID() // Or use the date if you ensure it's unique for the chart
    var date: Date
    var totalExpenses: Double
    var isToday: Bool = false // Optional: for styling today's bar differently
}

// Make sure you have this Date extension or similar
// extension Date {
//    func startOfMonth(using calendar: Calendar = .current) -> Date {
//        calendar.date(from: calendar.dateComponents([.year, .month], from: self))!
//    }
// }
