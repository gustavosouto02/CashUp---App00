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
                objectWillChange.send() // Notifica as Views que os dados podem ter mudado
                                        // A HomeView já observa objectWillChange do PlanningViewModel
                                        // e chama seu próprio updateCardData.
                                        // A PlanningPlanejarView usa @Query que se atualiza com o modelContext.
                                        // Se houver dados específicos que esta VM calcula e publica,
                                        // pode ser necessário chamar um método de recálculo aqui também.
            }
        }
    }

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        let now = Date()
        _currentMonth = Published(initialValue: now.startOfMonth())
        // Não é necessário chamar objectWillChange.send() aqui, pois é o init.
        // HomeViewModel chamará updateCardData no seu init, que usará os dados desta VM.
    }

    // MARK: - Gerenciamento de Categorias e Subcategorias Planejadas

    func getCategoriasPlanejadasForCurrentMonth() -> [CategoriaPlanejadaModel] {
        let monthToFetch = currentMonth.startOfMonth()
        let predicate = #Predicate<CategoriaPlanejadaModel> {
            $0.mesAno == monthToFetch
        }
        let sortDescriptors = [SortDescriptor(\CategoriaPlanejadaModel.categoriaOriginal?.nome, order: .forward)]
        
        let fetchDescriptor = FetchDescriptor<CategoriaPlanejadaModel>(predicate: predicate, sortBy: sortDescriptors)
        
        do {
            return try modelContext.fetch(fetchDescriptor)
        } catch {
            print("Erro ao buscar CategoriaPlanejadaModel para o mês: \(error)")
            return []
        }
    }

    // Função auxiliar para salvar o contexto, se você quiser chamá-la explicitamente em alguns pontos.
    // Geralmente, você pode salvar uma vez após um conjunto de operações.
    private func salvarContexto(operacao: String = "Operação Desconhecida") -> Bool {
        do {
            try modelContext.save()
            print("Contexto salvo com sucesso após: \(operacao)")
            objectWillChange.send() // Notifica que os dados mudaram
            return true
        } catch {
            print("Erro ao salvar contexto após \(operacao): \(error)")
            // TODO: Considerar um tratamento de erro mais robusto (ex: alertar o usuário)
            return false
        }
    }

    func adicionarSubcategoriaAoPlanejamento(subcategoriaModel: SubcategoriaModel,
                                            toCategoriaModel: CategoriaModel) -> Bool {
        let mesReferencia = currentMonth.startOfMonth()
        let targetCategoriaID = toCategoriaModel.id

        let predicateExistingCatPlan = #Predicate<CategoriaPlanejadaModel> { catPlan in
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

        guard let categoriaPlanejada = categoriaPlanejadaExistente else {
            print("Erro lógico: Tentando adicionar subcategoria a uma CategoriaPlanejadaModel que não existe para o mês e categoria. Use adicionarNovaCategoriaAoPlanejamento ou crie a CategoriaPlanejada primeiro.")
            return false // A CategoriaPlanejadaModel PAI deve existir.
        }

        // Verificar se a subcategoria já existe neste planejamento
        if categoriaPlanejada.subcategoriasPlanejadas?.contains(where: { $0.subcategoriaOriginal?.id == subcategoriaModel.id }) == true {
            print("Subcategoria '\(subcategoriaModel.nome)' já existe no planejamento para '\(categoriaPlanejada.nomeCategoriaOriginal)' este mês.")
            return false // Indica que não adicionou pois já existia
        }
        
        let novaSubPlanejada = SubcategoriaPlanejadaModel(
            valorPlanejado: 0.0, // Valor inicial
            subcategoriaOriginal: subcategoriaModel,
            categoriaPlanejada: categoriaPlanejada
        )
        
        // Adiciona à coleção. Se for nil, inicializa.
        if categoriaPlanejada.subcategoriasPlanejadas == nil {
            categoriaPlanejada.subcategoriasPlanejadas = []
        }
        categoriaPlanejada.subcategoriasPlanejadas?.append(novaSubPlanejada)
        // modelContext.insert(novaSubPlanejada) // Não é necessário se a relação for .cascade ou se o pai for salvo
                                              // e novaSubPlanejada for adicionada à coleção do pai.
                                              // SwiftData geralmente lida com a inserção de novos objetos em relações.
        
        print("Subcategoria '\(subcategoriaModel.nome)' adicionada ao planejamento de '\(categoriaPlanejada.nomeCategoriaOriginal)'.")
        return salvarContexto(operacao: "adicionarSubcategoriaAoPlanejamento")
    }
    
    func adicionarNovaCategoriaAoPlanejamento(categoriaModel: CategoriaModel,
                                            comSubcategoriaInicial subcategoriaModel: SubcategoriaModel) -> Bool {
        let mesReferencia = currentMonth.startOfMonth()
        let targetCategoriaID = categoriaModel.id

        let predicateExistingCatPlan = #Predicate<CategoriaPlanejadaModel> { catPlan in
            catPlan.mesAno == mesReferencia &&
            (catPlan.categoriaOriginal.flatMap { $0.id } == targetCategoriaID)
        }
        let fetchDescriptorCatPlan = FetchDescriptor(predicate: predicateExistingCatPlan)
        
        do {
            if (try modelContext.fetch(fetchDescriptorCatPlan).first) != nil {
                print("Categoria '\(categoriaModel.nome)' já possui um planejamento. Adicionando subcategoria '\(subcategoriaModel.nome)' ao planejamento existente.")
                return adicionarSubcategoriaAoPlanejamento(subcategoriaModel: subcategoriaModel, toCategoriaModel: categoriaModel)
            }
        } catch {
            print("Erro ao verificar CategoriaPlanejadaModel existente: \(error)")
            return false
        }
        
        // Cria a nova CategoriaPlanejadaModel
        let novaCategoriaPlanejada = CategoriaPlanejadaModel(mesAno: mesReferencia, categoriaOriginal: categoriaModel)
        modelContext.insert(novaCategoriaPlanejada) // Insere o pai primeiro

        // Cria e associa a SubcategoriaPlanejadaModel inicial
        let novaSubPlanejada = SubcategoriaPlanejadaModel(
            valorPlanejado: 0.0, // Valor inicial padrão
            subcategoriaOriginal: subcategoriaModel,
            categoriaPlanejada: novaCategoriaPlanejada // Associa ao pai recém-criado
        )
        // modelContext.insert(novaSubPlanejada) // Inserir se não for feito via relação cascade
                                            // ou se não for adicionado à coleção do pai *antes* do save do pai.
                                            // Adicionar à coleção é geralmente o caminho.
        
        novaCategoriaPlanejada.subcategoriasPlanejadas = [novaSubPlanejada]
        
        print("Nova categoria '\(categoriaModel.nome)' com subcategoria inicial '\(subcategoriaModel.nome)' adicionada ao planejamento.")
        return salvarContexto(operacao: "adicionarNovaCategoriaAoPlanejamento")
    }

    func removerSubcategoriasPlanejadasSelecionadas(idsSubcategoriasPlanejadas: Set<UUID>) {
        guard !idsSubcategoriasPlanejadas.isEmpty else {
            print("Nenhuma subcategoria selecionada para deleção.")
            return
        }

        var affectedParentCategorias = Set<CategoriaPlanejadaModel>()

        // 1. Buscar e marcar para deleção as SubcategoriaPlanejadaModel selecionadas
        for id in idsSubcategoriasPlanejadas {
            let predicate = #Predicate<SubcategoriaPlanejadaModel> { $0.id == id }
            // Não é necessário FetchDescriptor aqui se você só quer deletar por predicado
            // mas buscar primeiro permite pegar o pai.
            var fetchDescriptor = FetchDescriptor<SubcategoriaPlanejadaModel>(predicate: predicate)
            fetchDescriptor.fetchLimit = 1
            
            do {
                if let subParaDeletar = try modelContext.fetch(fetchDescriptor).first {
                    if let parent = subParaDeletar.categoriaPlanejada {
                        affectedParentCategorias.insert(parent)
                    }
                    modelContext.delete(subParaDeletar)
                    print("SubcategoriaPlanejadaModel com ID \(id) marcada para deleção.")
                }
            } catch {
                print("Erro ao buscar SubcategoriaPlanejadaModel (ID: \(id)) para deleção: \(error)")
            }
        }
        
        // 2. Verificar os pais afetados e deletá-los se estiverem vazios
        // É importante fazer isso *depois* de marcar todas as subcategorias filhas para deleção,
        // para que a verificação de `isEmpty` na coleção de subcategorias do pai seja precisa.
        for catPlan in affectedParentCategorias {
            // A relação `catPlan.subcategoriasPlanejadas` deve ser atualizada pelo SwiftData
            // para refletir as subcategorias que foram marcadas para deleção (ou seja, elas não
            // devem mais constar na contagem se a relação for bem gerenciada e o deleteRule for nullify/cascade).
            // Uma verificação `.isEmpty` na coleção deve ser suficiente.
            
            // Para ser mais explícito e robusto, filtramos as subcategorias que *não* estão no conjunto de IDs deletados.
            let remainingSubcategories = catPlan.subcategoriasPlanejadas?.filter { subPlan in
                !idsSubcategoriasPlanejadas.contains(subPlan.id)
            }

            if remainingSubcategories?.isEmpty ?? true {
                print("CategoriaPlanejadaModel '\(catPlan.nomeCategoriaOriginal)' ficou vazia e será deletada.")
                modelContext.delete(catPlan)
            }
        }
        
        // 3. Salvar o contexto para aplicar todas as deleções
        _ = salvarContexto(operacao: "removerSubcategoriasPlanejadasSelecionadas")
    }
    
    func zerarPlanejamentoDoMes() {
        let planejamentosDoMes = getCategoriasPlanejadasForCurrentMonth()
        if planejamentosDoMes.isEmpty {
            print("Nenhum planejamento para zerar neste mês.")
            return
        }
        for planejamento in planejamentosDoMes {
            // Deletar uma CategoriaPlanejadaModel deve, por cascata (se configurado),
            // deletar suas SubcategoriaPlanejadaModel filhas.
            // Se a regra de deleção em CategoriaPlanejadaModel para subcategoriasPlanejadas for .cascade,
            // apenas deletar o pai é suficiente. Caso contrário, delete os filhos explicitamente primeiro se necessário.
            // Assumindo que deletar o pai cuidará dos filhos ou que eles serão "órfãos" e não um problema.
            // No entanto, para zerar, deletar o pai é o objetivo.
            modelContext.delete(planejamento)
        }
        print("Todos os planejamentos para o mês \(currentMonth.formatted(.dateTime.month(.wide).year())) foram marcados para deleção.")
        _ = salvarContexto(operacao: "zerarPlanejamentoDoMes")
    }

    // MARK: - Cálculos
    func totalParaCategoriaPlanejada(_ categoriaPlanejada: CategoriaPlanejadaModel) -> Double {
        return categoriaPlanejada.subcategoriasPlanejadas?.reduce(0) { $0 + $1.valorPlanejado } ?? 0.0
    }

    func valorTotalPlanejadoParaMesAtual() -> Double {
        let categoriasDoMes = getCategoriasPlanejadasForCurrentMonth() // Busca os dados mais recentes
        return categoriasDoMes.reduce(0) { $0 + totalParaCategoriaPlanejada($1) }
    }

    func calcularPorcentagemTotal(paraCategoriaPlanejada categoria: CategoriaPlanejadaModel) -> Double {
        let totalCategoriaValue = totalParaCategoriaPlanejada(categoria)
        let totalPlanejadoMesValor = valorTotalPlanejadoParaMesAtual() // Busca o total mais recente
        guard totalPlanejadoMesValor > 0 else { return 0 }
        return (totalCategoriaValue / totalPlanejadoMesValor) * 100
    }

    func bindingParaValorPlanejado(subItem: SubcategoriaPlanejadaModel) -> Binding<String> {
        Binding<String>(
            get: {
                let formatter = NumberFormatter()
                formatter.numberStyle = .decimal
                formatter.maximumFractionDigits = 2
                formatter.minimumFractionDigits = 2 // Sempre mostra duas casas decimais
                formatter.locale = Locale(identifier: "pt_BR") // Use vírgula como separador decimal
                return formatter.string(from: NSNumber(value: subItem.valorPlanejado)) ?? "0,00"
            },
            set: { [self] novoValorString in
                let formatter = NumberFormatter()
                formatter.numberStyle = .decimal
                formatter.locale = Locale(identifier: "pt_BR") // Espera vírgula como separador decimal
                
                // Tenta converter usando o formatador que entende a localidade pt_BR
                if let numero = formatter.number(from: novoValorString) {
                    subItem.valorPlanejado = numero.doubleValue
                } else {
                    // Fallback: se o formatador falhar (ex: usuário digitou "."), tenta converter diretamente.
                    // Isso é menos ideal pois depende da localidade do dispositivo poder interpretar "."
                    let cleanedString = novoValorString.replacingOccurrences(of: ",", with: ".")
                    if let doubleValue = Double(cleanedString) {
                        subItem.valorPlanejado = doubleValue
                    } else {
                        // Mantém o valor antigo ou define como 0 se a string for inválida
                        // subItem.valorPlanejado = subItem.valorPlanejado // ou 0.0
                        print("Input inválido para valor planejado: \(novoValorString)")
                    }
                }
                // Notificar que houve mudança para que a UI e outros cálculos (como totais) atualizem.
                objectWillChange.send()
                // Considerar salvar o contexto aqui ou delegar para um botão "Salvar" explícito na UI.
                // Salvar a cada mudança de valor pode ser custoso.
                // Por ora, não salvarei aqui para evitar saves excessivos durante a digitação.
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

// Supondo que Date().startOfMonth() esteja definido em uma extensão:
// extension Date {
//    func startOfMonth(using calendar: Calendar = .current) -> Date {
//        calendar.date(from: calendar.dateComponents([.year, .month], from: self))!
//    }
// }
