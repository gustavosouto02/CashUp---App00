// Arquivo: CashUp/Views/Home/HomeViewModel.swift
// Ajustado para consumir DisplayableExpense da ExpensesViewModel refatorada

import Combine
import Foundation
import SwiftData
import SwiftUI

@MainActor
class HomeViewModel: ObservableObject {
    let modelContext: ModelContext
    let planningViewModel: PlanningViewModel
    let expensesViewModel: ExpensesViewModel // Agora fornece DisplayableExpense

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
                // A mudança de currentMonth na expensesViewModel já deve chamar seu loadDisplayableExpenses.
                // A HomeViewModel é notificada pelo objectWillChange da expensesViewModel.
                updateCardData()
            }
        }
    }

    @Published var totalSpentMonth: Double = 0.0
    @Published var totalIncomeMonth: Double = 0.0
    @Published var totalPlanejadoMes: Double = 0.0
    @Published var totalRestantePlanejadoMes: Double = 0.0
    @Published var categoriasResumo: [CategoriaResumo] = []
    @Published var categoriasPlanejadas: [CategoriaPlanejadaModel] = []
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

        if planningViewModel.currentMonth.startOfMonth() != initialMonth {
            planningViewModel.currentMonth = initialMonth
        }
        if expensesViewModel.currentMonth.startOfMonth() != initialMonth {
            // Isso garantirá que a expensesViewModel carregue os dados para o mês inicial correto.
            expensesViewModel.currentMonth = initialMonth
        }

        setupBindings()
        updateCardData() // Carga inicial dos dados dos cards da Home
    }

    private func setupBindings() {
        // Se currentMonth em PlanningViewModel ou ExpensesViewModel mudar,
        // atualiza o currentMonth da HomeViewModel (que então chama updateCardData).
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

        // Quando os dados internos de PlanningViewModel ou ExpensesViewModel mudarem
        // (ex: nova despesa adicionada, novo planejamento), recalcula os dados dos cards da Home.
        planningViewModel.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.updateCardData() }
            .store(in: &cancellables)

        expensesViewModel.objectWillChange // Isso será acionado quando transacoesExibidas mudar na ExpensesViewModel
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.updateCardData() }
            .store(in: &cancellables)
    }

    // Este computed property já usa o expensesViewModel, que agora está correto.
    var totalGastoEmCategoriasPlanejadas: Double {
        expensesViewModel.calcularTotalGastoEmCategoriasPlanejadas(
            paraMes: currentMonth, // Passar o mês é redundante se expensesViewModel já está no mês certo
            categoriasPlanejadas: self.categoriasPlanejadas
        )
    }

    func updateCardData() {
        // 1. Buscar despesas e receitas (AGORA COMO [DisplayableExpense]) da ExpensesViewModel.
        //    Essas funções na ExpensesViewModel já devem retornar a lista completa incluindo recorrências.
        let despesasDoMesDisplayable = expensesViewModel.expensesOnlyForCurrentMonth()
        let receitasDoMesDisplayable = expensesViewModel.incomesOnlyForCurrentMonth()

        // 2. Calcular totais usando os DisplayableExpense.
        totalSpentMonth = despesasDoMesDisplayable.reduce(0) { $0 + $1.amount }
        totalIncomeMonth = receitasDoMesDisplayable.reduce(0) { $0 + $1.amount }

        // 3. Lógica de Planejamento.
        totalPlanejadoMes = planningViewModel.valorTotalPlanejadoParaMesAtual()
        let fetchedCategoriasPlanejadas = planningViewModel.getCategoriasPlanejadasForCurrentMonth()
        self.categoriasPlanejadas = fetchedCategoriasPlanejadas

        // `calcularTotalGastoEmCategoriasPlanejadas` na ExpensesViewModel já usa expensesOnlyForCurrentMonth()
        // que retorna DisplayableExpense, então está correto.
        let gastoCalculadoEmPlanejadas = expensesViewModel.calcularTotalGastoEmCategoriasPlanejadas(
            paraMes: currentMonth, // O parâmetro 'mes' aqui pode ser redundante se a VM já está no currentMonth
            categoriasPlanejadas: self.categoriasPlanejadas
        )
        totalRestantePlanejadoMes = totalPlanejadoMes - gastoCalculadoEmPlanejadas

        // 4. Gerar Resumo de Categorias de DESPESAS (usando DisplayableExpense).
        let gastosPorCategoriaDisplayable = Dictionary(grouping: despesasDoMesDisplayable, by: { $0.categoria })

        let valoresPlanejados: [UUID: Double] = self.categoriasPlanejadas.reduce(into: [:]) { acc, plano in
            if let id = plano.categoriaOriginal?.id {
                acc[id] = plano.valorTotalPlanejado
            }
        }

        categoriasResumo = gastosPorCategoriaDisplayable.compactMap { (categoriaOpt, transacoesDisplayable) in
            guard let categoria = categoriaOpt else { return nil } // CategoriaModel de DisplayableExpense
            let totalCategoria = transacoesDisplayable.reduce(0) { $0 + $1.amount }
            let percentual = totalSpentMonth > 0 ? totalCategoria / totalSpentMonth : 0 // totalSpentMonth já inclui recorrentes
            
            let valorPlanejadoParaCategoria = valoresPlanejados[categoria.id]
            let progresso: Double?
            if let vp = valorPlanejadoParaCategoria, vp > 0 {
                progresso = min(totalCategoria / vp, 1.0)
            } else {
                progresso = nil
            }

            return CategoriaResumo(
                categoria: categoria,
                total: totalCategoria,
                percentual: percentual,
                progressoPlanejado: progresso
            )
        }
        .sorted { $0.total > $1.total }

        // 5. Atualizar dados para o gráfico de despesas DIÁRIAS (miniChartCard)
        //    Passando [DisplayableExpense] para a função que espera este tipo.
        updateDailyExpenseChartData(for: currentMonth, allDisplayableExpensesInMonth: despesasDoMesDisplayable)
    }
    
    // Função adaptada para receber [DisplayableExpense]
    private func updateDailyExpenseChartData(for month: Date, allDisplayableExpensesInMonth: [DisplayableExpense]) {
        var dailyData: [DailyExpenseItem] = []
        let calendar = Calendar.current
        
        let startOfMonth = month.startOfMonth()
        
        guard let monthInterval = calendar.dateInterval(of: .month, for: startOfMonth),
              let daysInMonth = calendar.range(of: .day, in: .month, for: startOfMonth)?.count else {
            self.dailyExpenseChartData = []
            return
        }
        
        let firstDayOfMonthDate = monthInterval.start

        for dayOffset in 0..<daysInMonth {
            guard let currentDateForDay = calendar.date(byAdding: .day, value: dayOffset, to: firstDayOfMonthDate) else { continue }
            
            // Filtra DisplayableExpense para este dia específico
            let expensesForSpecificDay = allDisplayableExpensesInMonth.filter { displayableExpense in
                // Certifique-se que está filtrando apenas despesas se allDisplayableExpensesInMonth contiver ambos
                // No nosso caso, já passamos despesasDoMesDisplayable que são só despesas.
                calendar.isDate(displayableExpense.date, inSameDayAs: currentDateForDay)
            }
            let totalForSpecificDay = expensesForSpecificDay.reduce(0) { $0 + $1.amount }
            
            dailyData.append(DailyExpenseItem(date: currentDateForDay,
                                              totalExpenses: totalForSpecificDay,
                                              isToday: calendar.isDateInToday(currentDateForDay)))
        }
        self.dailyExpenseChartData = dailyData
    }

    func loadHomeData(for month: Date) {
        let newMonth = month.startOfMonth()
        if currentMonth.startOfMonth() != newMonth {
            currentMonth = newMonth // didSet chamará updateCardData
        } else {
            updateCardData() // Força atualização se o mês for o mesmo mas os dados podem ter mudado
        }
    }

    // Função auxiliar de formatação, pode permanecer como está.
    func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: NSNumber(value: value)) ?? "R$0,00"
    }
}

// Struct CategoriaResumo (permanece a mesma)
struct CategoriaResumo: Identifiable {
    var id: UUID { categoria.id }
    let categoria: CategoriaModel
    let total: Double
    let percentual: Double
    let progressoPlanejado: Double?
}

// Struct DailyExpenseItem (permanece a mesma)
struct DailyExpenseItem: Identifiable {
    let id = UUID()
    var date: Date
    var totalExpenses: Double
    var isToday: Bool = false
}

// Certifique-se de que sua extensão Date().startOfMonth() está definida.
// extension Date {
//    func startOfMonth(using calendar: Calendar = .current) -> Date {
//        calendar.date(from: calendar.dateComponents([.year, .month], from: self))!
//    }
// }
