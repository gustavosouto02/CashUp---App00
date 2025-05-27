//
//  CategoriaModel.swift
//  CashUp
//
//  Created by Gustavo Souto Pereira on 26/05/25.
//

import SwiftData
import SwiftUI // Para Color

@Model
final class CategoriaModel {
    @Attribute(.unique)
    var id: UUID
    var nome: String
    var icon: String

    var redComponent: Double
    var greenComponent: Double
    var blueComponent: Double
    var subcategorias: [SubcategoriaModel]?

    init(id: UUID = UUID(),
         nome: String = "",
         icon: String = "",
         color: Color = .gray,
         subcategorias: [SubcategoriaModel]? = []) {
        self.id = id
        self.nome = nome
        self.icon = icon

        let uiColor = UIColor(color)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        self.redComponent = Double(r)
        self.greenComponent = Double(g)
        self.blueComponent = Double(b)

        self.subcategorias = subcategorias
    }

    var color: Color {
        Color(red: redComponent, green: greenComponent, blue: blueComponent)
    }

}
