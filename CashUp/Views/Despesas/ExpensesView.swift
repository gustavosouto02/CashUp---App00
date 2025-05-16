//
//  ExpensesView.swift
//  CashUp
//
//  Created by Gustavo Souto Pereira on 08/05/25.
//

import SwiftUI

struct ExpensesView: View {
    //@StateObject private var viewModel = MonthSelectorViewModel()
    @State private var selectedTransactionType: Int = 0;
    
    var body: some View {
        NavigationStack{
            ZStack{
                ScrollView{
                    VStack(alignment: .leading, spacing: 16){
//                        // MARK: - Seleção de Mês
//                        MonthSelector(
//                            displayedMonth: viewModel.selectedMonth,
//                            onPrevious: { viewModel.navigateMonth(isNext: false) },
//                            onNext: { viewModel.navigateMonth(isNext: true) }
//                        )
                        
                        // MARK: - Segmented Control
                        TransactionPicker(selectedTransactionType: $selectedTransactionType)
                    }
                }
            }
            .navigationTitle("Despesas")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing){
                    Button(action: {
                        //ação filtrar despesas
                    }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .padding()
            .overlay(
                Divider() // A linha que vai dividir a navigation stack
                    .background(Color.gray) // Cor da linha
                    .frame(height: 1) // Ajuste da espessura da linha
                    .padding(.top, 2), // Distância da linha para a toolbar
                alignment: .top
            )
        }
    }
}

#Preview {
    ExpensesView()
}
