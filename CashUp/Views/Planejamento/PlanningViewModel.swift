import SwiftUI
import Foundation
import Combine

class PlanningViewModel: ObservableObject {
    // MARK: - Public Properties

    @Published var selectedTab: Int = 0
    @Published var categorias: [Categoria] = []
    @Published var selectedCategoria: Categoria?
    @Published var selectedSubcategoria: Subcategoria?

    @Published var categoriasPlanejadas: [CategoriaPlanejada] = [] {
        didSet {
            salvarCategoriasPlanejadas()
        }
    }

    @Published var planejamentoTotal: [Planejamento] = [] {
        didSet {
            filterPlanningForDisplay()
        }
    }

    @Published var planejamentoDoMesExibicao: [Planejamento] = []

    @Published var currentMonth: Date { // Remova a atribuição padrão aqui
        didSet {
            // Este didSet será chamado apenas após a inicialização completa do objeto
            // e cada vez que currentMonth for alterado.
            currentMesAno = formatador.string(from: currentMonth)
            carregarCategoriasPlanejadas()
            carregarPlanejamento()
            filterPlanningForDisplay()
        }
    }

    private let availableCategories: [Categoria] = CategoriasData.todas
    private let planningKeyPrefix = "planejamentoDoMes_"

    // MARK: - Private Properties

    private var currentMesAno: String // Agora sem atribuição inicial
    private let formatador: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM"
        return df
    }()

    // MARK: - Init

    init() {
        let now = Date()
        let initialMonth = now.startOfMonth() // Calcule o mês inicial

        // 1. Inicialize currentMonth diretamente usando o Published wrapper.
        // O didSet não será chamado durante esta inicialização.
        _currentMonth = Published(wrappedValue: initialMonth)

        // 2. Inicialize currentMesAno a partir do valor que você usou para currentMonth.
        // Isso garante que currentMesAno seja inicializado ANTES de qualquer uso de 'self'
        // que envolva a própria propriedade `currentMonth` ou seu didSet.
        self.currentMesAno = formatador.string(from: initialMonth)

        // 3. Agora que todas as propriedades armazenadas estão inicializadas,
        // você pode chamar métodos que dependem de 'self' ou acessar outras propriedades.
        carregarCategoriasPlanejadas()
        carregarPlanejamento()
        filterPlanningForDisplay()
    }

    // MARK: - Métodos de Planejamento

    func adicionarPlanejamento(descricao: String, valor: Double) {
        let novo = Planejamento(data: currentMonth, descricao: descricao, valorTotalPlanejado: valor)
        planejamentoTotal.append(novo)
        // filterPlanningForDisplay() e salvarPlanejamento() são chamados pelo didSet de planejamentoTotal
        // não precisa chamar aqui também
    }

    func zerarPlanejamentoDoMes() {
        planejamentoTotal = []
        categoriasPlanejadas = []
        salvarPlanejamento()
        salvarCategoriasPlanejadas()
        // filterPlanningForDisplay() é chamado pelo didSet de planejamentoTotal
    }

    func navigateMonth(isNext: Bool) {
        let calendar = Calendar.current
        if let newDate = calendar.date(byAdding: .month, value: isNext ? 1 : -1, to: currentMonth) {
            currentMonth = newDate.startOfMonth() // didSet de currentMonth fará o resto
        }
    }

    // MARK: - Gerenciamento de Categorias Planejadas

    func getCategoriasPlanejadasForCurrentMonth() -> [CategoriaPlanejada] {
        return categoriasPlanejadas.filter {
            Calendar.current.isDate($0.mesAno, equalTo: currentMonth, toGranularity: .month)
        }
    }

    func adicionarSubcategoria(_ sub: Subcategoria, to categoria: Categoria) -> Bool {
        if let index = categoriasPlanejadas.firstIndex(where: {
            Calendar.current.isDate($0.mesAno, equalTo: currentMonth, toGranularity: .month) && $0.categoria.id == categoria.id
        }) {
            if categoriasPlanejadas[index].subcategoriasPlanejadas.contains(where: { $0.subcategoria.id == sub.id }) {
                print("Subcategoria '\(sub.nome)' já existe no planejamento para este mês.")
                return false
            } else {
                var categoriaToUpdate = categoriasPlanejadas[index]
                let novaSubPlanejada = SubcategoriaPlanejada(subcategoria: sub, valorPlanejado: 0.0)
                categoriaToUpdate.subcategoriasPlanejadas.append(novaSubPlanejada)
                categoriasPlanejadas[index] = categoriaToUpdate
                return true
            }
        } else {
            let novaCategoria = CategoriaPlanejada(
                categoria: categoria,
                subcategoriasPlanejadas: [SubcategoriaPlanejada(subcategoria: sub, valorPlanejado: 0.0)],
                mesAno: currentMonth.startOfMonth()
            )
            categoriasPlanejadas.append(novaCategoria)
            return true
        }
    }

    func removerSubcategoriasSelecionadas(_ ids: Set<UUID>) {
        for (catIndex, categoria) in categoriasPlanejadas.enumerated() {
            let novasSubs = categoria.subcategoriasPlanejadas.filter { !ids.contains($0.id) }
            categoriasPlanejadas[catIndex].subcategoriasPlanejadas = novasSubs
        }
        categoriasPlanejadas.removeAll { $0.subcategoriasPlanejadas.isEmpty }
    }

    // MARK: - Atualização de Valor Planejado
    func atualizarValorPlanejado(
        paraCategoria catItem: CategoriaPlanejada,
        subItem: SubcategoriaPlanejada,
        comNovoValor novoValorString: String
    ) {
        if let catIndex = categoriasPlanejadas.firstIndex(where: { $0.id == catItem.id }),
           let subIndex = categoriasPlanejadas[catIndex].subcategoriasPlanejadas.firstIndex(where: { $0.id == subItem.id }) {

            let cleanedValueString = novoValorString.replacingOccurrences(of: ",", with: ".")
                                                    .filter { "0123456789.".contains($0) }

            let novoValorDouble = Double(cleanedValueString) ?? 0.0
            categoriasPlanejadas[catIndex].subcategoriasPlanejadas[subIndex].valorPlanejado = novoValorDouble
        }
    }

    // MARK: - Cálculos
    func totalCategoria(categoria: CategoriaPlanejada) -> Double {
        categoria.subcategoriasPlanejadas
            .map { $0.valorPlanejado }
            .reduce(0, +)
    }

    func valorTotalPlanejado(categorias: [CategoriaPlanejada]) -> Double {
        return categorias.filter {
            Calendar.current.isDate($0.mesAno, equalTo: currentMonth, toGranularity: .month)
        }
        .map { totalCategoria(categoria: $0) }
        .reduce(0, +)
    }

    func calcularPorcentagemTotal(categoria: CategoriaPlanejada) -> Double {
        let totalCategoriaValue = totalCategoria(categoria: categoria)
        let totalPlanejado = valorTotalPlanejado(categorias: getCategoriasPlanejadasForCurrentMonth())
        guard totalPlanejado > 0 else { return 0 }
        return (totalCategoriaValue / totalPlanejado) * 100
    }

    func bindingParaValorPlanejado(
        categoria: CategoriaPlanejada,
        subcategoria: SubcategoriaPlanejada
    ) -> Binding<String> {
        Binding<String>(
            get: {
                let formatter = NumberFormatter()
                formatter.numberStyle = .decimal
                formatter.maximumFractionDigits = 2
                formatter.minimumFractionDigits = 2
                formatter.locale = Locale(identifier: "pt_BR")
                return formatter.string(from: NSNumber(value: subcategoria.valorPlanejado)) ?? ""
            },
            set: { [self] novoValorString in
                atualizarValorPlanejado(
                    paraCategoria: categoria,
                    subItem: subcategoria,
                    comNovoValor: novoValorString
                )
            }
        )
    }

    // MARK: - Filter for Display
    private func filterPlanningForDisplay() {
        self.planejamentoDoMesExibicao = self.planejamentoTotal.filter {
            Calendar.current.isDate($0.data, equalTo: self.currentMonth, toGranularity: .month)
        }
    }

    // MARK: - UserDefaults (Categorias Planejadas)
    private func salvarCategoriasPlanejadas() {
        let key = "categoriasPlanejadas-\(currentMesAno)"
        if let data = try? JSONEncoder().encode(categoriasPlanejadas) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private func carregarCategoriasPlanejadas() {
        let key = "categoriasPlanejadas-\(currentMesAno)"
        if let data = UserDefaults.standard.data(forKey: key),
           let carregadas = try? JSONDecoder().decode([CategoriaPlanejada].self, from: data) {
            categoriasPlanejadas = carregadas
        } else {
            categoriasPlanejadas = []
        }
    }

    // MARK: - UserDefaults (Planejamento Geral)
    private func salvarPlanejamento() {
        let key = "planejamentosTotal"
        if let data = try? JSONEncoder().encode(planejamentoTotal) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private func carregarPlanejamento() {
        let key = "planejamentosTotal"
        if let data = UserDefaults.standard.data(forKey: key),
           let carregados = try? JSONDecoder().decode([Planejamento].self, from: data) {
            planejamentoTotal = carregados
        } else {
            planejamentoTotal = []
        }
    }
}

// MARK: - Structs de Dados (Mantenha as structs separadas para organização)

struct Planejamento: Identifiable, Codable, Equatable {
    let id: UUID
    let data: Date
    let descricao: String
    let mesAno: String
    var valorTotalPlanejado: Double

    init(id: UUID = UUID(), data: Date, descricao: String, valorTotalPlanejado: Double) {
        self.id = id
        self.data = data
        self.descricao = descricao
        self.valorTotalPlanejado = valorTotalPlanejado
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        self.mesAno = formatter.string(from: data)
    }
}

struct SubcategoriaPlanejada: Identifiable, Codable, Equatable {
    let id: UUID
    var subcategoria: Subcategoria // Certifique-se que Subcategoria é Codable
    var valorPlanejado: Double

    init(subcategoria: Subcategoria, valorPlanejado: Double) {
        self.id = UUID()
        self.subcategoria = subcategoria
        self.valorPlanejado = valorPlanejado
    }
}

struct CategoriaPlanejada: Identifiable, Codable, Equatable {
    let id: UUID
    var categoria: Categoria // Certifique-se que Categoria é Codable
    var subcategoriasPlanejadas: [SubcategoriaPlanejada]
    var mesAno: Date

    init(id: UUID = UUID(), categoria: Categoria, subcategoriasPlanejadas: [SubcategoriaPlanejada], mesAno: Date) {
        self.id = id
        self.categoria = categoria
        self.subcategoriasPlanejadas = subcategoriasPlanejadas
        self.mesAno = mesAno
    }
}
