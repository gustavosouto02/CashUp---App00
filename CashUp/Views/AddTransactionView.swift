//
//  AddTransactionView.swift
//  CashUp
//
//  Created by Gustavo Souto Pereira on 08/05/25.
//

import SwiftUI

struct AddTransactionView: View {
    @Environment(\.sizeCategory) var sizeCategory

    var body: some View {
        NavigationStack{
            ScrollView{
                VStack(alignment: .leading, spacing: 16){
                    
                    
                }
            }
            .navigationTitle("Registrar Transação")
            .toolbar{
                ToolbarItem(placement: .topBarLeading){
                    Button(action:{
                        // cancelar
                    }){
                        Text("Cancelar")
                            .foregroundColor(.red)
                            
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing){
                    Button(action:{
                        // cancelar
                    }){
                        Text("Adicionar")
                    }
                }
            }
        }
    }
}

#Preview {
    AddTransactionView()
}
