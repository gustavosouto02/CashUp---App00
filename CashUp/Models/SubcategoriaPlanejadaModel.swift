//
//  SubcategoriaPlanejadaModel.swift
//  CashUp
//
//  Created by Gustavo Souto Pereira on 26/05/25.
//

// Arquivo: Models/SubcategoriaPlanejadaModel.swift
// (Baseado em SubcategoriaPlanejada de CashUp/Views/Planejamento/PlanningViewModel.swift)

import SwiftData
import SwiftUI

@Model
final class SubcategoriaPlanejadaModel {
    @Attribute(.unique) // Pode ser útil se você quiser uma única entrada por subcategoria original por CategoriaPlanejadaModel
    var id: UUID
    var valorPlanejado: Double

    // Relacionamento com a Subcategoria original (opcional, mas recomendado)
    var subcategoriaOriginal: SubcategoriaModel?
    
    // Relacionamento inverso com CategoriaPlanejadaModel (MUITO IMPORTANTE)
    var categoriaPlanejada: CategoriaPlanejadaModel?

    init(id: UUID = UUID(),
         valorPlanejado: Double = 0.0,
         subcategoriaOriginal: SubcategoriaModel? = nil,
         categoriaPlanejada: CategoriaPlanejadaModel? = nil) {
        self.id = id
        self.valorPlanejado = valorPlanejado
        self.subcategoriaOriginal = subcategoriaOriginal
        self.categoriaPlanejada = categoriaPlanejada // Importante para o relacionamento inverso
    }

    // Computed properties para conveniência
    var nomeSubcategoriaOriginal: String {
        subcategoriaOriginal?.nome ?? "N/A"
    }
    var iconSubcategoriaOriginal: String {
        subcategoriaOriginal?.icon ?? "questionmark"
    }
    var idSubcategoriaOriginal: UUID? {
        subcategoriaOriginal?.id
    }
}
