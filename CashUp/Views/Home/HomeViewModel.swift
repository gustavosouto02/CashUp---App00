//
//  HomeViewModel.swift
//  CashUp
//
//  Created by Gustavo Souto Pereira on 09/05/25.
//  Dados da visão geral

import Combine
import Foundation
import SwiftUI

class HomeViewModel: ObservableObject {
    @ObservedObject var planningViewModel: PlanningViewModel
    
    @Published var currentMonth: Date{
        didSet {
            planningViewModel.currentMonth = currentMonth
            loadHomeData(for: currentMonth)
        }
    }
    
    @Published var miniChart : [Double] = []
    @Published var totalSpentMonth : Double = 0
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(planningViewModel: PlanningViewModel) {
        self.planningViewModel = planningViewModel
        self.currentMonth = Date()
        loadHomeData(for: currentMonth)
    }
    
    func loadHomeData(for month: Date){
        totalSpentMonth = 0 // logic a puxar despesas do mes
    }
    
    
}
