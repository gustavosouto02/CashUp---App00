//
//  SubcategoriaModel.swift
//  CashUp
//
//  Created by Gustavo Souto Pereira on 26/05/25.
//

// Arquivo: Models/SubcategoriaModel.swift
// (Baseado em Subcategoria de CashUp/Sources/Extensions/Components/Categoria/CategoriasViewIcon.swift)

import SwiftData
import SwiftUI

@Model
final class SubcategoriaModel {
    @Attribute(.unique) // Garante que o ID seja único
    var id: UUID
    
    var nome: String
    var icon: String
    var usageCount: Int = 0 // Para substituir frequenciaSubcategorias do CategoriesViewModel
    
    // Relacionamento: A qual CategoriaModel esta subcategoria pertence
    @Relationship(inverse: \CategoriaModel.subcategorias)
    var categoria: CategoriaModel?
    
    init(id: UUID = UUID(),
         nome: String = "",
         icon: String = "",
         categoria: CategoriaModel? = nil,
         usageCount: Int = 0) {
        
        self.id = id
        self.nome = nome
        self.icon = icon
        self.categoria = categoria
        self.usageCount = usageCount
    }
}
