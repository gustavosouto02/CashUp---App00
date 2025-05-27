//
//  ExpenseCalculationProtocol.swift
//  CashUp
//
//  Created by Gustavo Souto Pereira on 22/05/25.
//

// Arquivo: CashUp/Sources/Extensions/Components/ExpenseCalculationProtocol.swift
import Foundation

@MainActor // Adicionado para alinhar com os ViewModels
protocol ExpenseCalculation {
    func calcularTotalGastoEmCategoriasPlanejadas(paraMes mes: Date, categoriasPlanejadas: [CategoriaPlanejadaModel]) -> Double
    func calcularTotalGastoParaCategoria(_ categoriaPlanejada: CategoriaPlanejadaModel, paraMes mes: Date) -> Double
    func calcularTotalGastoParaSubcategoria(_ subcategoriaPlanejada: SubcategoriaPlanejadaModel, paraMes mes: Date) -> Double
}
