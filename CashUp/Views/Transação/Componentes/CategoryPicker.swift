//
//  CategoryPicker.swift
//  CashUp
//
//  Created by Gustavo Souto Pereira on 13/05/25.
//

import SwiftUI

struct CategoryPicker: View {
    @State private var isCategorySheetPresented = false
    
    @Binding var selectedCategory: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "star.fill")
                .resizable()
                .frame(width: 24, height: 24)
            
            Button(action: {
                isCategorySheetPresented = true
            }) {
                Text(selectedCategory)
                    .font(.title2)
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
        .padding(.vertical, 2)
        Divider()
        
        .sheet(isPresented: $isCategorySheetPresented) {
            CategoriesView { category in
                selectedCategory = category
                isCategorySheetPresented = false
            }
        }
        
    }
}

