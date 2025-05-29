// Arquivo: CashUp/Views/Categoria/CategoriesViewModel.swift
// Refatorado para SwiftData e filtro por tipo de transação

import Foundation
import SwiftData
import SwiftUI // Para @MainActor, ObservableObject

// Defina este enum em um local acessível ou dentro do ViewModel se preferir.
enum TransactionTypeFilter {
    case despesa
    case receita
    // case todas // Se precisar de um caso para todas, sem filtro de renda/despesa
}

@MainActor
class CategoriesViewModel: ObservableObject {

    var modelContext: ModelContext
    private var transactionType: TransactionTypeFilter // Armazena o tipo para filtrar

    // A propriedade subcategoriasMaisUsadas agora é uma computada que faz o fetch.
    // Se a UI precisar ser atualizada quando ela mudar (após registrarUso),
    // o objectWillChange.send() em registrarUso já deve notificar as views observadoras.
    var subcategoriasMaisUsadas: [SubcategoriaModel] {
        fetchSubcategoriasMaisUsadasInterno()
    }

    init(modelContext: ModelContext, transactionType: TransactionTypeFilter) {
        self.modelContext = modelContext
        self.transactionType = transactionType
        // A propriedade computada `subcategoriasMaisUsadas` será acessada pela View quando necessário.
        // Não é preciso chamar explicitamente fetchSubcategoriasMaisUsadas() no init,
        // a menos que você queira popular uma @Published var.
    }

    /// Retorna todas as CategoriaModel ordenadas por nome, filtradas pelo transactionType.
    func fetchTodasCategoriasModel() -> [CategoriaModel] {
        let sortDescriptor = SortDescriptor(\CategoriaModel.nome, order: .forward)
        var predicate: Predicate<CategoriaModel>?

        switch transactionType {
        case .despesa:
            let rendaID = SeedIDs.idRenda // Assegure que SeedIDs.idRenda está definido e acessível
            predicate = #Predicate<CategoriaModel> { categoria in
                categoria.id != rendaID
            }
        case .receita:
            let rendaID = SeedIDs.idRenda
            predicate = #Predicate<CategoriaModel> { categoria in
                categoria.id == rendaID
            }
        // Se tivesse .todas:
        // case .todas:
        //     predicate = nil
        }
        
        let fetchDescriptor = FetchDescriptor<CategoriaModel>(predicate: predicate, sortBy: [sortDescriptor])
        
        do {
            return try modelContext.fetch(fetchDescriptor)
        } catch {
            print("Erro ao buscar CategoriaModel filtradas: \(error)")
            return []
        }
    }
    
    /// Busca uma CategoriaModel específica pelo seu ID.
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

    /// Registra o uso de uma subcategoria, incrementando seu usageCount.
    func registrarUso(subcategoriaModel: SubcategoriaModel) {
        // O objeto subcategoriaModel passado já deve ser uma instância gerenciada pelo modelContext
        // se foi selecionado de uma lista populada por uma @Query ou FetchDescriptor deste contexto.
        subcategoriaModel.usageCount += 1
        print("Registrando uso para \(subcategoriaModel.nome): novo usageCount = \(subcategoriaModel.usageCount)")
        
        // SwiftData tentará salvar automaticamente. Um save explícito é raramente necessário aqui.
        // Se você perceber que as alterações não estão persistindo ou atualizando outras partes,
        // pode adicionar um try? modelContext.save(), mas geralmente não é preciso para simples incrementos.

        // Notifica as views que a lista de 'subcategoriasMaisUsadas' pode ter mudado.
        objectWillChange.send()
    }

    /// Função interna para buscar as subcategorias mais usadas, filtradas pelo transactionType.
    private func fetchSubcategoriasMaisUsadasInterno() -> [SubcategoriaModel] {
        var predicate: Predicate<SubcategoriaModel>

        switch transactionType {
        case .despesa:
            // Subcategorias cujo pai NÃO é a categoria Renda E que foram usadas.
            let rendaID = SeedIDs.idRenda
            predicate = #Predicate<SubcategoriaModel> { subcategoria in
                subcategoria.usageCount > 0 && subcategoria.categoria?.id != rendaID
            }
        case .receita:
            // Subcategorias cujo pai É a categoria Renda E que foram usadas.
            let rendaID = SeedIDs.idRenda
            predicate = #Predicate<SubcategoriaModel> { subcategoria in
                subcategoria.usageCount > 0 && subcategoria.categoria?.id == rendaID
            }
        // Se tivesse .todas:
        // case .todas:
        //     predicate = #Predicate<SubcategoriaModel> { $0.usageCount > 0 }
        }
        
        let sortDescriptor = SortDescriptor(\SubcategoriaModel.usageCount, order: .reverse)
        var fetchDescriptor = FetchDescriptor<SubcategoriaModel>(predicate: predicate, sortBy: [sortDescriptor])
        fetchDescriptor.fetchLimit = 6 // Limita o resultado às 6 mais usadas (ou outro número de sua escolha)
        
        do {
            return try modelContext.fetch(fetchDescriptor)
        } catch {
            print("Erro ao buscar subcategorias mais usadas (filtradas): \(error)")
            return []
        }
    }

    // Funções auxiliares que foram adicionadas à CategoriesView podem ser movidas para cá
    // se fizerem mais sentido como parte da lógica do ViewModel.
    // No entanto, se elas são puramente para a lógica de apresentação da CategoriesView, podem ficar lá.
    // Por exemplo, para passar o transactionType para CategoriaFiltroView:
    func getTransactionTypeFilter() -> TransactionTypeFilter {
        return self.transactionType
    }

    // Para passar o modelContext para CategoriesViewEdit
    func getModelContextForEditing() -> ModelContext {
        return self.modelContext
    }
}
