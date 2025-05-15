//
//  CategoriaUtils.swift
//  CashUp
//
//  Created by Gustavo Souto Pereira on 14/05/25.
//

import SwiftUI

func categoriaPara(subcategoria: Subcategoria) -> Categoria? {
    CategoriasData.todas.first(where: {
        $0.subcategorias.contains(where: { $0.nome == subcategoria.nome })
    })
}

