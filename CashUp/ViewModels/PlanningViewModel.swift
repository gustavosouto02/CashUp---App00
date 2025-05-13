//
//  PlanningViewModel.swift
//  CashUp
//
//  Created by Gustavo Souto Pereira on 12/05/25.
//  Planejar e restante

import Foundation
import SwiftUI

class PlanningViewModel: ObservableObject {
    @Published var selectedTab: Int = 0
    @Published var categorias: [Categoria] = []
}
