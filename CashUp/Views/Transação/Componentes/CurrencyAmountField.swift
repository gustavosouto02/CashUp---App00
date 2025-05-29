import SwiftUI

struct CurrencyAmountField: View {
    @Binding var amount: Double
    @FocusState private var isFocused: Bool
    @State private var text: String = ""

    private let maxDigits: Int = 10 // Limite de 10 dígitos (ex: 9999999999 → R$ 99.999.999,99)

    var body: some View {
        VStack(spacing: 4) {
            TextField("", text: $text)
                .keyboardType(.numberPad)
                .focused($isFocused)
                .onAppear {
                    text = formattedAmount(amount)
                }
                .onChange(of: text) { _, newValue in
                    let digits = newValue.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
                    let limitedDigits = String(digits.prefix(maxDigits)) // Aqui está o limite
                    let value = (Double(limitedDigits) ?? 0) / 100
                    amount = value
                    text = formattedAmount(value)
                }
                .font(.system(size: 48, weight: .bold))
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .frame(width: 280, height: 70)
        }
    }

    func formattedAmount(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: NSNumber(value: value)) ?? "R$ 0,00"
    }
}
