// Arquivo: CashUp/Views/Planejamento/PlanningViewModel.swift
// Refatorado para SwiftData e uso consistente dos @Models, com predicados corrigidos

import SwiftUI
import Foundation
import Combine
import SwiftData

@MainActor
class PlanningViewModel: ObservableObject {

    var modelContext: ModelContext

    @Published var selectedTab: Int = 0
    @Published var currentMonth: Date {
        didSet {
            if oldValue.startOfMonth() != currentMonth.startOfMonth() {
                objectWillChange.send()
            }
        }
    }

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        let now = Date()
        _currentMonth = Published(initialValue: now.startOfMonth())
    }

    // MARK: - Gerenciamento de Categorias e Subcategorias Planejadas

    func getCategoriasPlanejadasForCurrentMonth() -> [CategoriaPlanejadaModel] {
        let monthToFetch = currentMonth.startOfMonth()
        let predicate = #Predicate<CategoriaPlanejadaModel> {
            $0.mesAno == monthToFetch
        }
        // Ordena pelo nome da categoria original. Se categoriaOriginal ou nome forem nil,
        // SwiftData geralmente os trata como menores ou maiores, dependendo da implementação.
        let sortDescriptors = [SortDescriptor(\CategoriaPlanejadaModel.categoriaOriginal?.nome, order: .forward)]
        
        let fetchDescriptor = FetchDescriptor<CategoriaPlanejadaModel>(predicate: predicate, sortBy: sortDescriptors)
        
        do {
            return try modelContext.fetch(fetchDescriptor)
        } catch {
            print("Erro ao buscar CategoriaPlanejadaModel para o mês: \(error)")
            return []
        }
    }

    func adicionarSubcategoriaAoPlanejamento(subcategoriaModel: SubcategoriaModel,
                                             toCategoriaModel: CategoriaModel) -> Bool {
        let mesReferencia = currentMonth.startOfMonth()
        let targetCategoriaID = toCategoriaModel.id // Guarda o ID não opcional

        // CORREÇÃO DO PREDICADO:
        let predicateExistingCatPlan = #Predicate<CategoriaPlanejadaModel> { catPlan in
            // Compara mesAno e depois verifica se categoriaOriginal não é nil E seu id corresponde.
            catPlan.mesAno == mesReferencia &&
            (catPlan.categoriaOriginal.flatMap { $0.id } == targetCategoriaID)
        }
        let fetchDescriptorCatPlan = FetchDescriptor(predicate: predicateExistingCatPlan)
        
        var categoriaPlanejadaExistente: CategoriaPlanejadaModel?
        do {
            categoriaPlanejadaExistente = try modelContext.fetch(fetchDescriptorCatPlan).first
        } catch {
            print("Erro ao buscar CategoriaPlanejadaModel existente: \(error)")
            return false
        }

        if let categoriaPlanejada = categoriaPlanejadaExistente {
            if categoriaPlanejada.subcategoriasPlanejadas?.contains(where: { $0.subcategoriaOriginal?.id == subcategoriaModel.id }) == true {
                print("Subcategoria '\(subcategoriaModel.nome)' já existe no planejamento para esta categoria e mês.")
                return false
            } else {
                let novaSubPlanejada = SubcategoriaPlanejadaModel(subcategoriaOriginal: subcategoriaModel, categoriaPlanejada: categoriaPlanejada)
                categoriaPlanejada.subcategoriasPlanejadas?.append(novaSubPlanejada)
            }
        } else {
            print("Erro lógico: Tentando adicionar subcategoria a uma CategoriaPlanejadaModel que não existe para o mês e categoria fornecidos. Use adicionarNovaCategoriaAoPlanejamento.")
            // Se a intenção era criar uma nova CategoriaPlanejada se não existir, a lógica deveria ser diferente.
            // Por agora, retornamos false, pois o nome do método implica que toCategoriaModel já tem um planejamento.
            return false
        }
        
        func salvarContexto() -> Bool {
            do {
                try modelContext.save()
                return true
            } catch {
                print("Erro ao salvar contexto: \(error)")
                return false
            }
        }

        return true
    }
    
    func adicionarNovaCategoriaAoPlanejamento(categoriaModel: CategoriaModel,
                                            comSubcategoriaInicial subcategoriaModel: SubcategoriaModel) -> Bool {
        let mesReferencia = currentMonth.startOfMonth()
        let targetCategoriaID = categoriaModel.id // Guarda o ID não opcional

        // CORREÇÃO DO PREDICADO:
        let predicateExistingCatPlan = #Predicate<CategoriaPlanejadaModel> { catPlan in
            catPlan.mesAno == mesReferencia &&
            (catPlan.categoriaOriginal.flatMap { $0.id } == targetCategoriaID)
        }
        let fetchDescriptorCatPlan = FetchDescriptor(predicate: predicateExistingCatPlan)
        
        do {
            if let _ = try modelContext.fetch(fetchDescriptorCatPlan).first {
                print("Categoria '\(categoriaModel.nome)' já possui um planejamento para este mês. Tentando adicionar subcategoria ao planejamento existente.")
                return adicionarSubcategoriaAoPlanejamento(subcategoriaModel: subcategoriaModel, toCategoriaModel: categoriaModel)
            }
        } catch {
            print("Erro ao verificar CategoriaPlanejadaModel existente: \(error)")
            return false
        }
        
        let novaCategoriaPlanejada = CategoriaPlanejadaModel(mesAno: mesReferencia, categoriaOriginal: categoriaModel)
        let novaSubPlanejada = SubcategoriaPlanejadaModel(valorPlanejado: 0.0,
                                                        subcategoriaOriginal: subcategoriaModel,
                                                        categoriaPlanejada: novaCategoriaPlanejada)
        novaCategoriaPlanejada.subcategoriasPlanejadas = [novaSubPlanejada]
        modelContext.insert(novaCategoriaPlanejada)
        
        // Opcional: try? modelContext.save()
        return true
    }

    func removerSubcategoriasPlanejadasSelecionadas(idsSubcategoriasPlanejadas: Set<UUID>) {
        for id in idsSubcategoriasPlanejadas {
            let predicate = #Predicate<SubcategoriaPlanejadaModel> { $0.id == id }
            let fetchDescriptor = FetchDescriptor(predicate: predicate)
            do {
                if let subParaDeletar = try modelContext.fetch(fetchDescriptor).first {
                    modelContext.delete(subParaDeletar)
                }
            } catch {
                print("Erro ao buscar SubcategoriaPlanejadaModel para deleção: \(error)")
            }
        }
        
        let categoriasPlanejadasDoMes = getCategoriasPlanejadasForCurrentMonth()
        for catPlan in categoriasPlanejadasDoMes {
            if catPlan.subcategoriasPlanejadas?.isEmpty ?? true {
                modelContext.delete(catPlan)
            }
        }
    }
    
    func zerarPlanejamentoDoMes() {
        let planejamentosDoMes = getCategoriasPlanejadasForCurrentMonth()
        for planejamento in planejamentosDoMes {
            modelContext.delete(planejamento)
        }
    }

    // MARK: - Cálculos
    func totalParaCategoriaPlanejada(_ categoriaPlanejada: CategoriaPlanejadaModel) -> Double {
        return categoriaPlanejada.subcategoriasPlanejadas?.reduce(0) { $0 + $1.valorPlanejado } ?? 0.0
    }

    func valorTotalPlanejadoParaMesAtual() -> Double {
        let categoriasDoMes = getCategoriasPlanejadasForCurrentMonth()
        return categoriasDoMes.reduce(0) { $0 + totalParaCategoriaPlanejada($1) }
    }

    func calcularPorcentagemTotal(paraCategoriaPlanejada categoria: CategoriaPlanejadaModel) -> Double {
        let totalCategoriaValue = totalParaCategoriaPlanejada(categoria)
        let totalPlanejadoMes = valorTotalPlanejadoParaMesAtual()
        guard totalPlanejadoMes > 0 else { return 0 }
        return (totalCategoriaValue / totalPlanejadoMes) * 100
    }

    func bindingParaValorPlanejado(subItem: SubcategoriaPlanejadaModel) -> Binding<String> {
        Binding<String>(
            get: {
                let formatter = NumberFormatter()
                formatter.numberStyle = .decimal
                formatter.maximumFractionDigits = 2
                formatter.minimumFractionDigits = 2
                formatter.locale = Locale(identifier: "pt_BR")
                return formatter.string(from: NSNumber(value: subItem.valorPlanejado)) ?? "0,00"
            },
            set: { novoValorString in
                let formatter = NumberFormatter()
                formatter.numberStyle = .decimal
                formatter.locale = Locale(identifier: "pt_BR")
                
                if let numero = formatter.number(from: novoValorString) {
                    subItem.valorPlanejado = numero.doubleValue
                } else {
                    let cleanedString = novoValorString.replacingOccurrences(of: ",", with: ".")
                    subItem.valorPlanejado = Double(cleanedString) ?? subItem.valorPlanejado
                }
            }
        )
    }
    
    func navigateMonth(isNext: Bool) {
        let calendar = Calendar.current
        if let newDate = calendar.date(byAdding: .month, value: isNext ? 1 : -1, to: currentMonth) {
            currentMonth = newDate.startOfMonth()
        }
    }
}
