//
//  CategoriesViewModel.swift
//  CashUp
//
//  Created by Gustavo Souto Pereira on 19/05/25.
//

import Foundation
import SwiftData
import SwiftUI

enum TransactionTypeFilter {
    case despesa
    case receita
}

@MainActor
class CategoriesViewModel: ObservableObject {

    var modelContext: ModelContext
    private var transactionType: TransactionTypeFilter

    var subcategoriasMaisUsadas: [SubcategoriaModel] {
        fetchSubcategoriasMaisUsadasInterno()
    }

    init(modelContext: ModelContext, transactionType: TransactionTypeFilter) {
        self.modelContext = modelContext
        self.transactionType = transactionType
    }

    func fetchTodasCategoriasModel() -> [CategoriaModel] {
        let sortDescriptor = SortDescriptor(\CategoriaModel.nome, order: .forward)
        var predicate: Predicate<CategoriaModel>?

        switch transactionType {
        case .despesa:
            let rendaID = SeedIDs.idRenda
            predicate = #Predicate<CategoriaModel> { categoria in
                categoria.id != rendaID
            }
        case .receita:
            let rendaID = SeedIDs.idRenda
            predicate = #Predicate<CategoriaModel> { categoria in
                categoria.id == rendaID
            }
        }
        
        let fetchDescriptor = FetchDescriptor<CategoriaModel>(predicate: predicate, sortBy: [sortDescriptor])
        
        do {
            return try modelContext.fetch(fetchDescriptor)
        } catch {
            print("Erro ao buscar CategoriaModel filtradas: \(error)")
            return []
        }
    }
    
    func findCategoriaModel(by id: UUID) -> CategoriaModel? {
        let predicate = #Predicate<CategoriaModel> { $0.id == id }
        var descriptor = FetchDescriptor(predicate: predicate)
        descriptor.fetchLimit = 1 // Otimização
        do {
            return try modelContext.fetch(descriptor).first
        } catch {
            print("Erro ao buscar CategoriaModel com id \(id): \(error)")
            return nil
        }
    }

    /// Busca uma SubcategoriaModel específica pelo seu ID.
    func findSubcategoriaModel(by id: UUID) -> SubcategoriaModel? {
        let predicate = #Predicate<SubcategoriaModel> { $0.id == id }
        var descriptor = FetchDescriptor(predicate: predicate)
        descriptor.fetchLimit = 1 // Otimização
        do {
            return try modelContext.fetch(descriptor).first
        } catch {
            print("Erro ao buscar SubcategoriaModel com id \(id): \(error)")
            return nil
        }
    }

    func registrarUso(subcategoriaModel: SubcategoriaModel) {
        subcategoriaModel.usageCount += 1
        print("Registrando uso para \(subcategoriaModel.nome): novo usageCount = \(subcategoriaModel.usageCount)")
        objectWillChange.send()
    }

    private func fetchSubcategoriasMaisUsadasInterno() -> [SubcategoriaModel] {
        var predicate: Predicate<SubcategoriaModel>

        switch transactionType {
        case .despesa:
            let rendaID = SeedIDs.idRenda
            predicate = #Predicate<SubcategoriaModel> { subcategoria in
                subcategoria.usageCount > 0 && subcategoria.categoria?.id != rendaID
            }
        case .receita:
            let rendaID = SeedIDs.idRenda
            predicate = #Predicate<SubcategoriaModel> { subcategoria in
                subcategoria.usageCount > 0 && subcategoria.categoria?.id == rendaID
            }
        }
        
        let sortDescriptor = SortDescriptor(\SubcategoriaModel.usageCount, order: .reverse)
        var fetchDescriptor = FetchDescriptor<SubcategoriaModel>(predicate: predicate, sortBy: [sortDescriptor])
        fetchDescriptor.fetchLimit = 6
        
        do {
            return try modelContext.fetch(fetchDescriptor)
        } catch {
            print("Erro ao buscar subcategorias mais usadas (filtradas): \(error)")
            return []
        }
    }

    func getTransactionTypeFilter() -> TransactionTypeFilter {
        return self.transactionType
    }

    func getModelContextForEditing() -> ModelContext {
        return self.modelContext
    }
}
