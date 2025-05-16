//
//  PlanningHelpers.swift
//  CashUp
//
//  Created by Gustavo Souto Pereira on 14/05/25.
//

import SwiftUI

extension PlanningViewModel {
    
    // MARK: - Adição de Subcategorias
    func adicionarSubcategoria(_ sub: Subcategoria, to categoria: Categoria) {
        if let index = categoriasPlanejadas.firstIndex(where: { $0.categoria.nome == categoria.nome }) {
            categoriasPlanejadas[index].subcategoriasPlanejadas.append(
                SubcategoriaPlanejada(subcategoria: sub, valorPlanejado: "")
            )
        } else {
            let novaCategoria = CategoriaPlanejada(
                categoria: categoria,
                subcategoriasPlanejadas: [SubcategoriaPlanejada(subcategoria: sub, valorPlanejado: "")]
            )
            categoriasPlanejadas.append(novaCategoria)
        }
    }

    // MARK: - Atualização de Valor Planejado
    func atualizarValorPlanejado(
        paraCategoria catItem: CategoriaPlanejada,
        subItem: SubcategoriaPlanejada,
        comNovoValor novoValor: String
    ) {
        if let catIndex = categoriasPlanejadas.firstIndex(where: { $0.id == catItem.id }),
           let subIndex = categoriasPlanejadas[catIndex].subcategoriasPlanejadas.firstIndex(where: { $0.id == subItem.id }) {
            categoriasPlanejadas[catIndex].subcategoriasPlanejadas[subIndex].valorPlanejado = novoValor.filter { "0123456789,.".contains($0) }
        }
    }

    
    // MARK: - Cálculos
    func totalCategoria(categoria: CategoriaPlanejada) -> Double {
        categoria.subcategoriasPlanejadas
            .map { Double($0.valorPlanejado.filter { "0123456789,.".contains($0) }) ?? 0 }
            .reduce(0, +)
    }

    func valorTotalPlanejado(categorias: [CategoriaPlanejada]) -> Double {
        categorias
            .map { totalCategoria(categoria: $0) }
            .reduce(0, +)
    }

    func calcularPorcentagemTotal(categoria: CategoriaPlanejada) -> Double {
        let totalCategoriaValue = totalCategoria(categoria: categoria)
        let totalPlanejado = valorTotalPlanejado(categorias: categoriasPlanejadas)
        guard totalPlanejado > 0 else { return 0 }
        return (totalCategoriaValue / totalPlanejado) * 100
    }
    
    // Cria um Binding para o valor planejado de uma subcategoria dentro de uma categoria
    func bindingParaValorPlanejado(
        categoria: CategoriaPlanejada,
        subcategoria: SubcategoriaPlanejada
    ) -> Binding<String> {
        Binding<String>(
            get: {
                subcategoria.valorPlanejado
            },
            set: { [self] novoValor in
                atualizarValorPlanejado(
                    paraCategoria: categoria,
                    subItem: subcategoria,
                    comNovoValor: novoValor
                )
            }
        )
    }
}
