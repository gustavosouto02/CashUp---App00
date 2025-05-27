// Arquivo: CashUp/Views/Home/HomeViewModel.swift
// Refatorado para SwiftData e melhorias sugeridas

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

    @Published var totalSpentMonth = 0.0
    @Published var totalIncomeMonth = 0.0
    @Published var totalPlanejadoMes = 0.0
    @Published var totalRestantePlanejadoMes = 0.0
    @Published var categoriasResumo: [CategoriaResumo] = []
    @Published var categoriasPlanejadas: [CategoriaPlanejadaModel] = []


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
            expensesViewModel.currentMonth = initialMonth
        }

        setupBindings()
        updateCardData()
    }

    private func setupBindings() {
        planningViewModel.$currentMonth
            .removeDuplicates()
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
            .sink { [weak self] newExpensesMonth in
                guard let self = self else { return }
                let newStart = newExpensesMonth.startOfMonth()
                if self.currentMonth.startOfMonth() != newStart {
                    self.currentMonth = newStart
                }
            }
            .store(in: &cancellables)

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
        let despesas = expensesViewModel.expensesOnlyForCurrentMonth()
        totalSpentMonth = despesas.reduce(0) { $0 + $1.amount }

        totalPlanejadoMes = planningViewModel.valorTotalPlanejadoParaMesAtual()

        let categoriasPlanejadas = planningViewModel.getCategoriasPlanejadasForCurrentMonth()

        let totalGastoEmCategoriasPlanejadas = expensesViewModel.calcularTotalGastoEmCategoriasPlanejadas(
            paraMes: currentMonth,
            categoriasPlanejadas: categoriasPlanejadas
        )

        totalRestantePlanejadoMes = totalPlanejadoMes - totalGastoEmCategoriasPlanejadas

        let gastosPorCategoria = Dictionary(grouping: despesas, by: { $0.categoria })

        let valoresPlanejados: [UUID: Double] = categoriasPlanejadas.reduce(into: [:]) { acc, plano in
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
    }

    func loadHomeData(for month: Date) {
        let newMonth = month.startOfMonth()
        if currentMonth != newMonth {
            currentMonth = newMonth
        } else {
            updateCardData()
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
    var id: UUID { categoria.id }
    let categoria: CategoriaModel
    let total: Double
    let percentual: Double
    let progressoPlanejado: Double?
}
