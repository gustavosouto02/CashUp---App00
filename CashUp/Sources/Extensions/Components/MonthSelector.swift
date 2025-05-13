//
//  MonthSelector.swift
//  CashUp
//
//  Created by Gustavo Souto Pereira on 12/05/25.
//

import SwiftUI

struct MonthSelector: View {
    let displayedMonth: String
    let onPrevious: () -> Void
    let onNext: () -> Void

    var body: some View {
        HStack {
            Button(action: onPrevious) {
                Image(systemName: "chevron.left")
                    .font(.title2)
            }

            Spacer()

            Text(displayedMonth)
                .font(.headline)
                .bold()
                .minimumScaleFactor(0.8)

            Spacer()

            Button(action: onNext) {
                Image(systemName: "chevron.right")
                    .font(.title2)
            }
        }
        .padding(.horizontal)
        .frame(height: 40)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
    }
}
