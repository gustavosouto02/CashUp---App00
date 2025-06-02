//
//  ViewExtensions.swift
//  CashUp
//
//  Created by Gustavo Souto Pereira on 19/05/25.
//

import SwiftUI

extension View {
    func hideKeyboardOnTap() -> some View {
        self.onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}
func dismissKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
}
