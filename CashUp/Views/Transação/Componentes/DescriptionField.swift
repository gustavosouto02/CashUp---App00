//
//  DescriptionField.swift
//  CashUp
//
//  Created by Gustavo Souto Pereira on 13/05/25.
//

import SwiftUI

struct DescriptionField: View {
    @Binding var description: String

    var body: some View {
        HStack(spacing: 12) {
            Label {
                Text("Descrição")
                    .font(.title2)
            } icon: {
                Image(systemName: "text.justify.left")
                    .resizable()
                    .frame(width: 24, height: 24)
            }
            TextField("Opcional", text: $description)
                .font(.headline)
                .padding(.vertical, 8)
        }
        Divider()
    }
}
