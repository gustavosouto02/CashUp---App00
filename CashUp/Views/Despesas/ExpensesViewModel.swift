import Foundation

class ExpensesViewModel: ObservableObject, ExpenseCalculation { // Conforma ao protocolo

    // MARK: - Published Properties

    @Published var currentMonth: Date = Date() {
        didSet {
            carregarTodasExpenses()
        }
    }

    @Published var allExpenses: [Expense] = [] {
        didSet {
            salvarTodasExpenses()
        }
    }

    @Published var selectedTransactionType: Int = 0 {
        didSet {
            objectWillChange.send()
        }
    }

    var expensesDoMes: [Expense] {
        let calendar = Calendar.current
        let currentMonthComponents = calendar.dateComponents([.year, .month], from: currentMonth)

        return allExpenses.filter { expense in
            let expenseComponents = calendar.dateComponents([.year, .month], from: expense.date)
            return expenseComponents.year == currentMonthComponents.year && expenseComponents.month == currentMonthComponents.month
        }.sorted(by: { $0.date > $1.date })
    }

    var despesasDoMes: [Expense] {
        expensesDoMes.filter { !$0.isIncome }
    }

    var receitasDoMes: [Expense] {
        expensesDoMes.filter { $0.isIncome }
    }

    var transacoesExibidas: [Expense] {
        selectedTransactionType == 0 ? despesasDoMes : receitasDoMes
    }

    @Published var availableCategories: [Categoria] = CategoriasData.todas

    // MARK: - Private Properties

    private var currentMesAno: String {
        formatador.string(from: currentMonth)
    }

    private let formatador: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM"
        return df
    }()

    // MARK: - Initializer

    init() {
        let now = Date()
        self.currentMonth = now // Initialize here
        carregarTodasExpenses()
    }

    // MARK: - Public Methods

    func addExpense(_ expense: Expense) {
        guard let existingCategory = availableCategories.first(where: { $0.id == expense.category.id }) else {
            print("Erro: Categoria '\(expense.category.nome)' (ID: \(expense.category.id)) não encontrada em availableCategories. Transação não adicionada.")
            return
        }

        guard let existingSubcategory = existingCategory.subcategorias.first(where: { $0.id == expense.subcategory.id }) else {
            print("Erro: Subcategoria '\(expense.subcategory.nome)' (ID: \(expense.subcategory.id)) não encontrada na categoria '\(existingCategory.nome)'. Transação não adicionada.")
            return
        }

        let newExpense = Expense(
            id: expense.id,
            amount: expense.amount,
            date: expense.date,
            category: existingCategory,
            subcategory: existingSubcategory,
            description: expense.description,
            isIncome: expense.isIncome,
            repetition: expense.repetition
        )

        allExpenses.append(newExpense)
    }

    func removeExpense(_ expense: Expense) {
        allExpenses.removeAll { $0.id == expense.id }
    }

    func totalIncome() -> Double {
        expensesDoMes
            .filter { $0.isIncome }
            .map { $0.amount }
            .reduce(0, +)
    }

    func totalExpense() -> Double {
        expensesDoMes
            .filter { !$0.isIncome }
            .map { $0.amount }
            .reduce(0, +)
    }

    func navigateMonth(isNext: Bool) {
        let calendar = Calendar.current
        if let newDate = calendar.date(byAdding: .month, value: isNext ? 1 : -1, to: currentMonth) {
            currentMonth = newDate
        }
    }

    // MARK: - Expense Calculation Functions (Conformando ao protocolo ExpenseCalculation)

    public func calcularTotalGastoEmCategoriasPlanejadas(paraMes mes: Date, categoriasPlanejadas: [CategoriaPlanejada]) -> Double {
        var totalGasto = 0.0
        let expensesDoMes = allExpenses.filter { expense in
            Calendar.current.isDate(expense.date, equalTo: mes, toGranularity: .month) && !expense.isIncome
        }
        print("--- DEBUG: calcularTotalGastoEmCategoriasPlanejadas ---")
        print("Mês de referência: \(mes.isoString())")
        print("Total de despesas do mês: \(expensesDoMes.count)")
        print("Categorias planejadas para o mês: \(categoriasPlanejadas.count)")

        for categoriaPlanejada in categoriasPlanejadas {
            print("  Analisando Categoria Planejada: \(categoriaPlanejada.categoria.nome) (ID: \(categoriaPlanejada.categoria.id))")
            for subcategoriaPlanejada in categoriaPlanejada.subcategoriasPlanejadas {
                let gastoNestaSubcategoria = expensesDoMes
                    .filter { $0.subcategory.id == subcategoriaPlanejada.subcategoria.id }
                    .map { $0.amount }
                    .reduce(0, +)
                totalGasto += gastoNestaSubcategoria
                print("    Subcategoria Planejada: \(subcategoriaPlanejada.subcategoria.nome) (ID: \(subcategoriaPlanejada.subcategoria.id)) - Gasto Detectado: \(gastoNestaSubcategoria)")
            }
        }
        print("Total Gasto Calculado em Categorias Planejadas: \(totalGasto)")
        print("--------------------------------------------------")
        return totalGasto
    }

    public func calcularTotalGastoParaCategoria(_ categoriaPlanejada: CategoriaPlanejada, paraMes mes: Date) -> Double {
        var totalGasto = 0.0
        let expensesDoMes = allExpenses.filter { expense in
            Calendar.current.isDate(expense.date, equalTo: mes, toGranularity: .month) && !expense.isIncome
        }

        for subcategoriaPlanejada in categoriaPlanejada.subcategoriasPlanejadas {
            totalGasto += expensesDoMes
                .filter { $0.subcategory.id == subcategoriaPlanejada.subcategoria.id }
                .map { $0.amount }
                .reduce(0, +)
        }
        return totalGasto
    }

    public func calcularTotalGastoParaSubcategoria(_ subcategoriaPlanejada: SubcategoriaPlanejada, paraMes mes: Date) -> Double {
        let expensesDoMes = allExpenses.filter { expense in
            Calendar.current.isDate(expense.date, equalTo: mes, toGranularity: .month) && !expense.isIncome
        }
        let gasto = expensesDoMes
            .filter { $0.subcategory.id == subcategoriaPlanejada.subcategoria.id }
            .map { $0.amount }
            .reduce(0, +)

        print("DEBUG: Gasto para \(subcategoriaPlanejada.subcategoria.nome) (ID: \(subcategoriaPlanejada.subcategoria.id)): \(gasto)")

        return gasto
    }

    // MARK: - Persistence (NOW FOR ALL EXPENSES)

    private let allExpensesKey = "allUserExpenses"

    private func salvarTodasExpenses() {
        if let data = try? JSONEncoder().encode(allExpenses) {
            UserDefaults.standard.set(data, forKey: allExpensesKey)
            print("Todas as despesas salvas. Total: \(allExpenses.count)")
        } else {
            print("Erro ao codificar e salvar todas as despesas.")
        }
    }

    private func carregarTodasExpenses() {
        if let data = UserDefaults.standard.data(forKey: allExpensesKey),
           let decodedExpenses = try? JSONDecoder().decode([Expense].self, from: data) {

            self.allExpenses = decodedExpenses.compactMap { loadedExpense in
                guard let categoryToUse = availableCategories.first(where: { $0.id == loadedExpense.category.id }) else {
                    print("Aviso: Categoria '\(loadedExpense.category.nome)' (ID: \(loadedExpense.category.id)) de despesa carregada não encontrada. Despesa ignorada.")
                    return nil
                }
                guard let subcategoryToUse = categoryToUse.subcategorias.first(where: { $0.id == loadedExpense.subcategory.id }) else {
                    print("Aviso: Subcategoria '\(loadedExpense.subcategory.nome)' (ID: \(loadedExpense.subcategory.id)) de despesa carregada não encontrada na categoria '\(categoryToUse.nome)'. Despesa ignorada.")
                    return nil
                }
                print("--- Despesa Carregada ---")
                print("Despesa ID: \(loadedExpense.id)")
                print("Subcategoria da despesa (Carregada): \(loadedExpense.subcategory.nome) - ID: \(loadedExpense.subcategory.id)")
                print("Subcategoria da despesa (Usada): \(subcategoryToUse.nome) - ID: \(subcategoryToUse.id)")
                print("-------------------------")
                return Expense(
                    id: loadedExpense.id,
                    amount: loadedExpense.amount,
                    date: loadedExpense.date,
                    category: categoryToUse,
                    subcategory: subcategoryToUse,
                    description: loadedExpense.description,
                    isIncome: loadedExpense.isIncome,
                    repetition: loadedExpense.repetition
                )
            }
            print("Todas as despesas carregadas. Total: \(self.allExpenses.count)")
        } else {
            self.allExpenses = []
            print("Nenhuma despesa para carregar ou erro na decodificação.")
        }
    }
}
