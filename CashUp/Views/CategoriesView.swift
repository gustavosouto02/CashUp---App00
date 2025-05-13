//
//  CategoriesView.swift
//  CashUp
//
//  Created by Gustavo Souto Pereira on 13/05/25.
//

import SwiftUI

struct CategoriesView: View {
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack{
            ScrollView{
                VStack(alignment: .leading, spacing: 24){
                    
                }
            }
            .navigationTitle("Categorias")
            .toolbar(){
                ToolbarItem(placement: .topBarTrailing){
                    Button(action: {
//                        NavigationLink(destination: CategoriesViewEdit()){
//
//                        }
                    }){
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
            .overlay(
                Divider()
                    .background(Color.gray.opacity(0.6))
                    .frame(height: 1)
                    .padding(.top, 2), alignment: .top
            )
            .searchable(text: $searchText)
        }
        
        //Scope Bar
    }
}

#Preview {
    CategoriesView()
}
