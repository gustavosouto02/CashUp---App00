//
//  PlanningViewModel.swift
//  CashUp
//
//  Created by Gustavo Souto Pereira on 12/05/25.
//  Planejar e restante

import SwiftUI
import Foundation

class PlanningViewModel: ObservableObject {
    // MARK: - Public Properties

    @Published var selectedTab: Int = 0
    @Published var categorias: [Categoria] = []
    @Published var selectedCategoria: Categoria?
    @Published var selectedSubcategoria: Subcategoria?
    
    @Published var categoriasPlanejadas: [CategoriaPlanejada] = [] {
        didSet { salvarCategoriasPlanejadas() }
    }

    @Published var planejamentoDoMes: [Planejamento] = []

    @Published var currentMonth: Date = Date() {
        didSet {
            currentMesAno = formatador.string(from: currentMonth)
            carregarCategoriasPlanejadas()
            carregarPlanejamento()
        }
    }

    // MARK: - Private Properties

    private var currentMesAno: String
    private let formatador: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM"
        return df
    }()

    // MARK: - Init

    init() {
        let now = Date()
        self.currentMonth = now
        self.currentMesAno = formatador.string(from: now)
        carregarCategoriasPlanejadas()
        carregarPlanejamento()
    }


    // MARK: - Métodos de Planejamento

    func adicionarPlanejamento(descricao: String, valor: Double) {
        let novo = Planejamento(data: currentMonth, descricao: descricao, valorTotalPlanejado: valor)
        planejamentoDoMes.append(novo)
        salvarPlanejamento()
    }

    func zerarPlanejamentoDoMes() {
        planejamentoDoMes = []
        categoriasPlanejadas = []
        salvarPlanejamento()
        salvarCategoriasPlanejadas()
    }

    func navigateMonth(isNext: Bool) {
        let calendar = Calendar.current
        if let newDate = calendar.date(byAdding: .month, value: isNext ? 1 : -1, to: currentMonth) {
            currentMonth = newDate
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
    
    func removerSubcategoriasSelecionadas(_ ids: Set<UUID>) {
        for (catIndex, categoria) in categoriasPlanejadas.enumerated() {
            let novasSubs = categoria.subcategoriasPlanejadas.filter { !ids.contains($0.id) }
            categoriasPlanejadas[catIndex].subcategoriasPlanejadas = novasSubs
        }

        // Remove categorias sem subcategorias
        categoriasPlanejadas.removeAll { $0.subcategoriasPlanejadas.isEmpty }
    }



    // MARK: - UserDefaults (Planejamento do Mês)

    private func salvarPlanejamento() {
        let key = "planejamentos-\(currentMesAno)"
        if let data = try? JSONEncoder().encode(planejamentoDoMes) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private func carregarPlanejamento() {
        let key = "planejamentos-\(currentMesAno)"
        if let data = UserDefaults.standard.data(forKey: key),
           let carregados = try? JSONDecoder().decode([Planejamento].self, from: data) {
            planejamentoDoMes = carregados
        } else {
            planejamentoDoMes = []
        }
    }
    
    
}

// MARK: - Structs de Dados

struct Planejamento: Identifiable, Codable, Equatable {
    let id: UUID
    let data: Date
    let mesAno: String
    let descricao: String
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
    var subcategoria: Subcategoria
    var valorPlanejado: String

    init(subcategoria: Subcategoria, valorPlanejado: String) {
        self.id = UUID()
        self.subcategoria = subcategoria
        self.valorPlanejado = valorPlanejado
    }
}

struct CategoriaPlanejada: Identifiable, Codable, Equatable {
    let id: UUID
    var categoria: Categoria
    var subcategoriasPlanejadas: [SubcategoriaPlanejada]

    init(categoria: Categoria, subcategoriasPlanejadas: [SubcategoriaPlanejada]) {
        self.id = UUID()
        self.categoria = categoria
        self.subcategoriasPlanejadas = subcategoriasPlanejadas
    }
}
