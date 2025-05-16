//
//import SwiftUI
//struct CurrencyAmountField: View {
//    @Binding var amount: Double
//    @FocusState private var isFocused: Bool
//
//    var body: some View {
//        HStack {
//            Spacer()
//            CurrencyTextField(amount: $amount)
//                .frame(width: 240, height: 80)
//                .focused($isFocused)
//                .font(.system(size: 48, weight: .bold))
//                .minimumScaleFactor(0.5)
//                .multilineTextAlignment(.center)
//                .keyboardType(.numberPad)
//            Spacer()
//        }
//    }
//}
import SwiftUI

struct CurrencyAmountField: View {
    @Binding var amount: Double
    @FocusState private var isFocused: Bool
    @State private var text: String = ""

    var body: some View {
        TextField("", text: $text)
            .keyboardType(.numberPad)
            .focused($isFocused)
            .onAppear {
                text = formattedAmount(amount)
            }
            .onChange(of: text) { _, newValue in
                let digits = newValue.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
                let value = (Double(digits) ?? 0) / 100
                amount = value
                text = formattedAmount(value)
            }
            .font(.system(size: 48, weight: .bold))
            .multilineTextAlignment(.center)
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .frame(width: 240, height: 70)
    }

    func formattedAmount(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: NSNumber(value: value)) ?? "R$ 0,00"
    }
}






