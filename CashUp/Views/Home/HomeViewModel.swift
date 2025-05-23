//
//  HomeViewModel.swift
//  CashUp
//
//  Created by Gustavo Souto Pereira on 09/05/25.
//  Dados da visão geral

import Combine
import Foundation
// REMOVA 'import SwiftUI' daqui, a menos que você esteja usando Color diretamente
// ou outras structs de UI do SwiftUI DENTRO DESTE ViewModel.
// Se você só usa @Published e ObservableObject, Combine e Foundation são suficientes.

class HomeViewModel: ObservableObject {
    // Declaramos como @Published aqui para que HomeView possa observar
    // e o didSet do currentMonth do HomeViewModel seja o gatilho principal.
    @Published var planningViewModel: PlanningViewModel
    @Published var expensesViewModel: ExpensesViewModel

    @Published var currentMonth: Date {
        didSet {
            // Sincroniza os ViewModels filhos APENAS se o mês mudou no HomeViewModel
            // Se eles já estão sincronizados via 'assign', esta parte pode ser redundante
            // e até causar loops. O 'assign' no setupBindings é mais robusto.
            if oldValue.startOfMonth() != currentMonth.startOfMonth() {
                planningViewModel.currentMonth = currentMonth.startOfMonth()
                expensesViewModel.currentMonth = currentMonth.startOfMonth()
            }
            updatePlanningCardData() // Recalculate when month changes
        }
    }

    @Published var miniChart: [Double] = [] // Placeholder for mini chart data
    @Published var totalSpentMonth: Double = 0 // Placeholder for total spent this month

    // Properties for the Planning Card
    @Published var totalGastoEmPlanejado: Double = 0.0
    @Published var totalPlanejado: Double = 0.0
    @Published var restanteDoPlanejamento: Double = 0.0
    @Published var metaResidualProgress: Double = 0.0

    private var cancellables: Set<AnyCancellable> = []

    init(planningViewModel: PlanningViewModel, expensesViewModel: ExpensesViewModel) {
        self.planningViewModel = planningViewModel
        self.expensesViewModel = expensesViewModel
        // Inicializa currentMonth com o início do mês atual para consistência
        self.currentMonth = Date().startOfMonth()

        // Sincroniza os ViewModels filhos com o currentMonth inicial
        self.planningViewModel.currentMonth = self.currentMonth
        self.expensesViewModel.currentMonth = self.currentMonth

        setupBindings() // Set up Combine publishers
        updatePlanningCardData() // Initial data load
    }

    private func setupBindings() {
        // Observa mudanças nas categorias planejadas e em todas as despesas
        // Quando qualquer um desses muda, recalcula os dados do cartão de planejamento.
        Publishers.CombineLatest(
            planningViewModel.$categoriasPlanejadas, // Reage quando as categorias planejadas mudam
            expensesViewModel.$allExpenses // Reage quando as despesas mudam
        )
        .debounce(for: .milliseconds(100), scheduler: RunLoop.main) // Adiciona um debounce para evitar updates excessivos
        .sink { [weak self] (_, _) in
            guard let self = self else { return }
            self.updatePlanningCardData()
        }
        .store(in: &cancellables)

        // Também precisamos observar se o currentMonth dos ViewModels filhos muda,
        // o que pode acontecer por navegação externa (como na PlanningView).
        // Assim, o HomeViewModel pode reagir e sincronizar seu próprio currentMonth
        // e depois recalcular.

        planningViewModel.$currentMonth
            .sink { [weak self] newMonth in
                guard let self = self else { return }
                // Só atualiza se for um mês diferente para evitar loops
                if self.currentMonth.startOfMonth() != newMonth.startOfMonth() {
                    self.currentMonth = newMonth.startOfMonth()
                }
            }
            .store(in: &cancellables)

        expensesViewModel.$currentMonth
            .sink { [weak self] newMonth in
                guard let self = self else { return }
                // Só atualiza se for um mês diferente para evitar loops
                if self.currentMonth.startOfMonth() != newMonth.startOfMonth() {
                    self.currentMonth = newMonth.startOfMonth()
                }
            }
            .store(in: &cancellables)
    }

    // Função principal para carregar dados para a HomeView
    // Esta função será chamada quando a HomeView aparecer ou precisar de uma atualização
    func loadHomeData(for month: Date) {
        // Define o mês atual do HomeViewModel.
        // O didSet do currentMonth irá disparar a sincronização dos VMS filhos
        // e updatePlanningCardData().
        self.currentMonth = month.startOfMonth()
        // Adicione aqui qualquer outra lógica de carregamento de dados específica da HomeView
        // que não seja diretamente relacionada ao planejamento/despesas, ex: para miniChart
    }

    private func updatePlanningCardData() {
        // Assegura que o mês usado para os cálculos é o mês atual do HomeViewModel
        let monthToCalculate = currentMonth.startOfMonth()

        let categoriasPlanejadasMesAtual = planningViewModel.getCategoriasPlanejadasForCurrentMonth() // Já filtra pelo currentMonth interno do PlanningViewModel

        // As funções de cálculo do ExpensesViewModel já esperam um 'Date' e retornam 'Double'.
        // Se houver problemas de inferência de tipo aqui, é por causa de alguma importação.
        let gastoEmPlanejado: Double = expensesViewModel.calcularTotalGastoEmCategoriasPlanejadas(
            paraMes: monthToCalculate, // Passa o mês correto para ExpensesViewModel
            categoriasPlanejadas: categoriasPlanejadasMesAtual
        )

        let planejado: Double = planningViewModel.valorTotalPlanejado(categorias: categoriasPlanejadasMesAtual)

        self.totalGastoEmPlanejado = gastoEmPlanejado
        self.totalPlanejado = planejado
        self.restanteDoPlanejamento = planejado - gastoEmPlanejado
        self.metaResidualProgress = planejado > 0 ? min(gastoEmPlanejado / planejado, 1.0) : 0.0
    }

    // Helper for currency formatting, useful in the HomeView
    func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: NSNumber(value: value)) ?? "R$ 0,00"
    }
}
