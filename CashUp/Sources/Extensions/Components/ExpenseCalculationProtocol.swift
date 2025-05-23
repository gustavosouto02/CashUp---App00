//
//  ExpenseCalculationProtocol.swift
//  CashUp
//
//  Created by Gustavo Souto Pereira on 22/05/25.
//

import Foundation

protocol ExpenseCalculation {
    func calcularTotalGastoEmCategoriasPlanejadas(paraMes mes: Date, categoriasPlanejadas: [CategoriaPlanejada]) -> Double
    func calcularTotalGastoParaCategoria(_ categoriaPlanejada: CategoriaPlanejada, paraMes mes: Date) -> Double
    func calcularTotalGastoParaSubcategoria(_ subcategoriaPlanejada: SubcategoriaPlanejada, paraMes mes: Date) -> Double
}
