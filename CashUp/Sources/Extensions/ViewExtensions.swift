// Arquivo: CashUp/Sources/Extensions/ViewExtensions.swift
// (Ou qualquer outro local que faça sentido para suas extensões globais)

import SwiftUI

extension View {
    func hideKeyboardOnTap() -> some View {
        self.onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}
