// Arquivo: CashUp/Views/Categoria/CategoriesViewModel.swift
// Refatorado para SwiftData

import Foundation
import SwiftData // Importar SwiftData
import SwiftUI // Para @MainActor

@MainActor // Recomendado para ViewModels que interagem com ModelContext
class CategoriesViewModel: ObservableObject {

    var modelContext: ModelContext

    // A propriedade categorias não é mais um @Published array populado de CategoriasData.
    // As views que precisam da lista de todas as categorias podem usar @Query
    // ou este ViewModel pode fornecer uma função para buscá-las.

    // A frequenciaSubcategorias e sua persistência em UserDefaults são removidas,
    // pois usageCount agora está em SubcategoriaModel.

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        // Não há mais carregamento de frequência de UserDefaults.
    }

    /// Retorna todas as CategoriaModel ordenadas por nome.
    /// Usado por views como CategoriesView ou CategorySelectionSheet para exibir a lista de categorias.
    func fetchTodasCategoriasModel() -> [CategoriaModel] {
        let sortDescriptor = SortDescriptor(\CategoriaModel.nome)
        let fetchDescriptor = FetchDescriptor<CategoriaModel>(sortBy: [sortDescriptor])
        do {
            return try modelContext.fetch(fetchDescriptor)
        } catch {
            print("Erro ao buscar todas as CategoriaModel: \(error)")
            return []
        }
    }
    
    /// Busca uma CategoriaModel específica pelo seu ID.
    func findCategoriaModel(by id: UUID) -> CategoriaModel? {
        let predicate = #Predicate<CategoriaModel> { $0.id == id }
        let descriptor = FetchDescriptor(predicate: predicate)
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
        let descriptor = FetchDescriptor(predicate: predicate)
        do {
            return try modelContext.fetch(descriptor).first
        } catch {
            print("Erro ao buscar SubcategoriaModel com id \(id): \(error)")
            return nil
        }
    }


    /// Registra o uso de uma subcategoria, incrementando seu usageCount.
    /// A subcategoriaModel passada deve ser uma instância gerenciada pelo modelContext.
    func registrarUso(subcategoriaModel: SubcategoriaModel) {
        // Verifica se o objeto está no contexto atual para evitar erros com objetos de outros contextos.
        // Se subcategoriaModel foi buscada com este modelContext, está ok.
        // Se veio de outro lugar, pode ser necessário refetch.
        // No entanto, se a instância já é gerenciada, a modificação direta é suficiente.
        
        subcategoriaModel.usageCount += 1
        print("Registrando uso para \(subcategoriaModel.nome): novo usageCount = \(subcategoriaModel.usageCount)")
        
        // SwiftData tentará salvar automaticamente.
        // Se precisar de salvamento imediato (raro para um contador):
        // do {
        //     try modelContext.save()
        // } catch {
        //     print("Erro ao salvar o modelContext após registrar uso da subcategoria: \(error)")
        // }
        
        // Dispara uma notificação para que as views que dependem de subcategoriasMaisUsadas se atualizem.
        // Se subcategoriasMaisUsadas for uma propriedade computada e não @Published,
        // as views que a usam diretamente não se atualizarão automaticamente sem objectWillChange.send().
        // No entanto, se as views usarem @Query para as subcategorias mais usadas, elas se atualizarão.
        objectWillChange.send()
    }

    /// Retorna as 6 subcategorias mais usadas.
    var subcategoriasMaisUsadas: [SubcategoriaModel] {
        // Define o predicado para buscar apenas subcategorias que foram usadas ao menos uma vez.
        let predicate = #Predicate<SubcategoriaModel> { subcategoria in
            subcategoria.usageCount > 0
        }
        // Ordena por usageCount em ordem decrescente.
        let sortDescriptor = SortDescriptor(\SubcategoriaModel.usageCount, order: .reverse)
        
        var fetchDescriptor = FetchDescriptor<SubcategoriaModel>(predicate: predicate, sortBy: [sortDescriptor])
        fetchDescriptor.fetchLimit = 6 // Limita o resultado às 6 mais usadas.
        
        do {
            return try modelContext.fetch(fetchDescriptor)
        } catch {
            print("Erro ao buscar subcategorias mais usadas: \(error)")
            return []
        }
    }
}
