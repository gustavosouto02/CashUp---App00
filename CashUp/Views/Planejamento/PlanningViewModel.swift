//
//  PlanningViewModel.swift
//  CashUp
//
//  Created by Gustavo Souto Pereira on 12/05/25.
//  Planejar e restante

import SwiftUI
import Foundation

class PlanningViewModel: ObservableObject {
    @Published var selectedTab: Int = 0
    @Published var categorias: [Categoria] = []
    @Published var selectedCategoria: Categoria?
    @Published var selectedSubcategoria: Subcategoria?
    @Published var planejamentoDoMes: [Planejamento] = [] // Planejamentos para o mês atual

    @Published var subcategoriasPlanejadas: [SubcategoriaPlanejada] = []
    @Published var categoriasPlanejadas: [CategoriaPlanejada] = [] {
        didSet {
            salvarCategoriasPlanejadas(paraMesAno: currentMesAno)
        }
    }

    @Published var currentMonth: Date = Date() {
        didSet {
            currentMesAno = dateFormatter.string(from: currentMonth)
            carregarPlanejamento(paraMesAno: currentMonth)
            carregarCategoriasPlanejadas(paraMesAno: currentMesAno)
        }
    }
    private var currentMesAno: String = ""
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return formatter
    }()

    private let categoriasPlanejadasUserDefaultsKeyPrefix = "categoriasPlanejadas-"
    private let planejamentosUserDefaultsKeyPrefix = "planejamentos-"

    init() {
        currentMesAno = dateFormatter.string(from: currentMonth)
        carregarPlanejamento(paraMesAno: currentMonth)
        carregarCategoriasPlanejadas(paraMesAno: currentMesAno)
    }

    // Salvar categorias planejadas para o mês atual no UserDefaults
    private func salvarCategoriasPlanejadas(paraMesAno mesAno: String) {
        let key = categoriasPlanejadasUserDefaultsKeyPrefix + mesAno
        if let data = try? JSONEncoder().encode(categoriasPlanejadas) {
            UserDefaults.standard.set(data, forKey: key)
            print("Categorias planejadas salvas para:", mesAno)
        } else {
            print("Erro ao salvar categorias planejadas para:", mesAno)
        }
    }
    

    // Carregar categorias planejadas para o mês atual do UserDefaults
    private func carregarCategoriasPlanejadas(paraMesAno mesAno: String) {
        let key = categoriasPlanejadasUserDefaultsKeyPrefix + mesAno
        if let data = UserDefaults.standard.data(forKey: key),
           let categorias = try? JSONDecoder().decode([CategoriaPlanejada].self, from: data) {
            self.categoriasPlanejadas = categorias
            print("Categorias planejadas carregadas para:", mesAno, categorias)
        } else {
            print("Nenhuma categoria planejada encontrada para:", mesAno)
            self.categoriasPlanejadas = [] // Garante que esteja vazio se não houver
        }
    }

    func carregarPlanejamento(paraMesAno data: Date) {
        let mesAnoString = dateFormatter.string(from: data)
        let key = planejamentosUserDefaultsKeyPrefix + mesAnoString
        if let data = UserDefaults.standard.data(forKey: key),
           let planejamentosCarregados = try? JSONDecoder().decode([Planejamento].self, from: data) {
            self.planejamentoDoMes = planejamentosCarregados
            print("Planejamentos carregados para:", mesAnoString, "Total:", planejamentosCarregados.count)
        } else {
            print("Nenhum planejamento encontrado para:", mesAnoString)
            self.planejamentoDoMes = [] // Começa com um planejamento vazio para o mês
        }
    }

    func salvarPlanejamentoDoMes() {
        let key = planejamentosUserDefaultsKeyPrefix + currentMesAno
        if let data = try? JSONEncoder().encode(planejamentoDoMes) {
            UserDefaults.standard.set(data, forKey: key)
            print("Planejamentos salvos para:", currentMesAno)
        } else {
            print("Erro ao salvar planejamentos para:", currentMesAno)
        }
    }

    func adicionarPlanejamento(data: Date, descricao: String, valorTotalPlanejado: Double) {
        let novoPlanejamento = Planejamento(data: data, descricao: descricao, valorTotalPlanejado: valorTotalPlanejado)
        planejamentoDoMes.append(novoPlanejamento)
        salvarPlanejamentoDoMes()
    }

    // Função para "zerar" o planejamento do mês atual (criar um novo array vazio)
    func zerarPlanejamentoDoMes() {
        planejamentoDoMes = []
        salvarPlanejamentoDoMes() // Salva o array vazio
        categoriasPlanejadas = []
        salvarCategoriasPlanejadas(paraMesAno: currentMesAno)
    }

    func navigateMonth(isNext: Bool) {
        let calendar = Calendar.current
        let components = DateComponents(month: isNext ? 1 : -1)
        currentMonth = calendar.date(byAdding: components, to: currentMonth) ?? currentMonth
    }
}

struct Planejamento: Identifiable, Equatable, Codable {
    let id: UUID
    let data: Date
    let mesAno: String
    let descricao: String
    var valorTotalPlanejado: Double

    init(id: UUID = UUID(), data: Date, descricao: String, valorTotalPlanejado: Double) {
        self.id = id
        self.data = data
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM"
        self.mesAno = dateFormatter.string(from: data)
        self.descricao = descricao
        self.valorTotalPlanejado = valorTotalPlanejado
    }
}


struct SubcategoriaPlanejada: Identifiable, Equatable, Codable {
    let id: UUID
    var subcategoria: Subcategoria
    var valorPlanejado: String

    init(subcategoria: Subcategoria, valorPlanejado: String) {
        self.id = UUID()
        self.subcategoria = subcategoria
        self.valorPlanejado = valorPlanejado
    }
}

struct CategoriaPlanejada: Identifiable, Equatable, Codable {
    let id: UUID
    var categoria: Categoria
    var subcategoriasPlanejadas: [SubcategoriaPlanejada]

    init(categoria: Categoria, subcategoriasPlanejadas: [SubcategoriaPlanejada]) {
        self.id = UUID()
        self.categoria = categoria
        self.subcategoriasPlanejadas = subcategoriasPlanejadas
    }
}
