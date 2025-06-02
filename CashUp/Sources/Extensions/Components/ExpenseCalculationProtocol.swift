//
//  ExpenseCalculationProtocol.swift
//  CashUp
//
//  Created by Gustavo Souto Pereira on 22/05/25.
//

import Foundation

@MainActor
protocol ExpenseCalculation {
    func calcularTotalGastoEmCategoriasPlanejadas(paraMes mes: Date, categoriasPlanejadas: [CategoriaPlanejadaModel]) -> Double
    func calcularTotalGastoParaCategoria(_ categoriaPlanejada: CategoriaPlanejadaModel, paraMes mes: Date) -> Double
    func calcularTotalGastoParaSubcategoria(_ subcategoriaPlanejada: SubcategoriaPlanejadaModel, paraMes mes: Date) -> Double
}
