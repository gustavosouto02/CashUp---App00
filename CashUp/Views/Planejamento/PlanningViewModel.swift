//
//  PlanningViewModel.swift
//  CashUp
//
//  Created by Gustavo Souto Pereira on 12/05/25.
//  Planejar e restante

import Foundation
import SwiftUI

class PlanningViewModel: ObservableObject {
    @Published var selectedTab: Int = 0
    @Published var categorias: [Categoria] = []
    @Published var selectedCategoria: Categoria?
    @Published var selectedSubcategoria: Subcategoria?
    @Published var subcategoriasPlanejadas: [SubcategoriaPlanejada] = []
    @Published var categoriasPlanejadas: [CategoriaPlanejada] = []
}

struct SubcategoriaPlanejada: Identifiable, Equatable{
    let id = UUID()
    var subcategoria: Subcategoria
    var valorPlanejado: String
}

struct CategoriaPlanejada: Identifiable, Equatable{
    let id = UUID()
    var categoria: Categoria
    var subcategoriasPlanejadas: [SubcategoriaPlanejada]
}
