//
//  CategoriasViewIcon.swift
//  CashUp
//
//  Created by Gustavo Souto Pereira on 19/05/25.
//

import SwiftData
import SwiftUI

// MARK: - View do ícone com fundo em círculo
struct CategoriasViewIcon: View {
    let systemName: String
    let cor: Color
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(cor) 
                .frame(width: size * 1.4, height: size * 1.4)
            Image(systemName: systemName)
                .font(.system(size: size * 0.6))
                .foregroundStyle(.white)
        }
    }
}

#Preview {
    CategoriasViewIcon(systemName: "dollarsign.bank.building.fill", cor: .red, size: 24)
}
