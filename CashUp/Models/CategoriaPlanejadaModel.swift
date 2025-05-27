//
//  CategoriaPlanejadaModel.swift
//  CashUp
//
//  Created by Gustavo Souto Pereira on 26/05/25.
//

// Arquivo: Models/CategoriaPlanejadaModel.swift
// (Baseado em CategoriaPlanejada de CashUp/Views/Planejamento/PlanningViewModel.swift)

import SwiftData
import SwiftUI

@Model
final class CategoriaPlanejadaModel {
    @Attribute(.unique) // Pode ser útil se você quiser um planejamento único por categoria por mês
    var id: UUID
    var mesAno: Date // Para filtrar planejamentos por mês (deve ser o início do mês)

    // Relacionamento com a Categoria original (opcional, mas recomendado para integridade)
    var categoriaOriginal: CategoriaModel?

    // Relacionamento com as subcategorias planejadas
    // .cascade: se CategoriaPlanejadaModel for deletada, suas SubcategoriaPlanejadaModel também são.
    @Relationship(deleteRule: .cascade, inverse: \SubcategoriaPlanejadaModel.categoriaPlanejada)
    var subcategoriasPlanejadas: [SubcategoriaPlanejadaModel]? = []

    init(id: UUID = UUID(),
         mesAno: Date, // Requerido
         categoriaOriginal: CategoriaModel? = nil,
         subcategoriasPlanejadas: [SubcategoriaPlanejadaModel]? = []) {
        self.id = id
        self.mesAno = mesAno.startOfMonth() // Garante que é o início do mês
        self.categoriaOriginal = categoriaOriginal
        self.subcategoriasPlanejadas = subcategoriasPlanejadas
    }

    // Computed properties para conveniência, se necessário
    var nomeCategoriaOriginal: String {
        categoriaOriginal?.nome ?? "N/A"
    }
    var corCategoriaOriginal: Color {
        categoriaOriginal?.color ?? .gray
    }
    var iconCategoriaOriginal: String {
        categoriaOriginal?.icon ?? "questionmark"
    }
    var idCategoriaOriginal: UUID? {
        categoriaOriginal?.id
    }
}

extension CategoriaPlanejadaModel {
    var valorTotalPlanejado: Double {
        subcategoriasPlanejadas?.reduce(0) { $0 + $1.valorPlanejado } ?? 0
    }
}

