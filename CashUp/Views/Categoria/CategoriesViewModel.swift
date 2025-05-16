//
//  CategoriesViewModel.swift
//  CashUp
//
//  Created by Gustavo Souto Pereira on 09/05/25.
// Lista e filtros de categoria

import Foundation
import SwiftUI

class CategoriesViewModel: ObservableObject {
    @Published var categorias: [Categoria] = CategoriasData.todas
    @Published private(set) var frequenciaSubcategorias: [UUID: Int] = [:]
    
    private let userDefaultsKey = "frequenciaSubcategorias"

    init() {
        carregarFrequencia()
    }

    // Salvar frequência no UserDefaults
    private func salvarFrequencia() {
        let data = try? JSONEncoder().encode(frequenciaSubcategorias)
        UserDefaults.standard.set(data, forKey: userDefaultsKey)
    }

    // Carregar frequência do UserDefaults
    private func carregarFrequencia() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let frequencia = try? JSONDecoder().decode([UUID: Int].self, from: data) {
            self.frequenciaSubcategorias = frequencia
            print("Frequência carregada:", frequencia) // ← AQUI
        } else {
            print("Nenhuma frequência encontrada.")
        }
    }


    // Quando o usuário usa uma subcategoria
    func registrarUso(subcategoria: Subcategoria) {
        frequenciaSubcategorias[subcategoria.id, default: 0] += 1
        print("Registrando uso para \(subcategoria.nome):", frequenciaSubcategorias[subcategoria.id] ?? 0)
        salvarFrequencia()
    }

    var subcategoriasMaisUsadas: [Subcategoria] {
        let todasSubcategorias = categorias.flatMap { $0.subcategorias }

        return todasSubcategorias
            .filter { frequenciaSubcategorias[$0.id, default: 0] > 0 } // <- adicionado
            .sorted {
                let freqA = frequenciaSubcategorias[$0.id] ?? 0
                let freqB = frequenciaSubcategorias[$1.id] ?? 0
                return freqA > freqB
            }
            .prefix(6)
            .map { $0 }
    }
}


