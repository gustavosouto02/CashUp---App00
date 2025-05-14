//
//  AmountField.swift
//  CashUp
//
//  Created by Gustavo Souto Pereira on 13/05/25.
//

import SwiftUI

struct AmountField: View {
    @Binding var amount: Double
    @State private var amountText: String = ""

    var body: some View {
        HStack {
            TextField("0", text: $amountText)
                .keyboardType(.decimalPad)
                .font(.system(size: 64, weight: .bold))
                .multilineTextAlignment(.center)
                .padding()
                .cornerRadius(8)
                .frame(height: 80)
                .frame(maxWidth: .infinity)
                .onChange(of: amountText) {
                    let sanitized = amountText.replacingOccurrences(of: ",", with: ".")
                    amount = Double(sanitized) ?? 0
                }
                .onAppear {
                    amountText = amount > 0 ? String(format: "%.2f", amount) : ""
                }
        }
    }
}


