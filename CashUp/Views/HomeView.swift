import SwiftUI

struct HomeView: View {
    @Environment(\.sizeCategory) var sizeCategory

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    
                    // Seletor de Mês
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 40)
                        .overlay(
                            Text("Abril 2025")
                                .font(.headline)
                                .bold()
                                .minimumScaleFactor(0.8)
                        )

                    // Cartão 1: Gráfico de gastos
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 200)
                        .overlay(
                            Text("Mini Gráfico")
                                .foregroundColor(.white)
                                .font(.body)
                        )

                    // Cartão 2: Planejamento
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Planejamento")
                            .font(.headline)
                        Text("Sobrou para gastar")
                            .font(.caption)
                            .foregroundColor(.gray)

                        HStack {
                            Text("R$ 100")
                                .font(.title2)
                                .bold()
                            Text("/ 700")
                                .font(.caption)
                        }

                        ProgressView(value: 100, total: 700)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(12)
                    .frame(minHeight: 150)

                    // Cartão 3: Despesas
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Despesas")
                            .font(.headline)
                        Text("Categorias principais")
                            .font(.caption)
                            .foregroundColor(.gray)

                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("🟪 Transporte - 50%")
                                Text("🟦 Alimentação - 30%")
                                Text("🟥 Lazer - 20%")
                            }

                            Spacer()

                            Circle()
                                .trim(from: 0.0, to: 1.0)
                                .stroke(LinearGradient(colors: [.purple, .blue, .pink], startPoint: .top, endPoint: .bottom), lineWidth: 12)
                                .frame(width: 60, height: 60)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("Visão Geral")
                .toolbar {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        Button(action: {
                            // ação do botão de info
                        }) {
                            Image(systemName: "info.circle.fill")
                                .font(.headline)
                        }

                        Button(action: {
                            // ação do botão de registrar
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "plus.circle.fill")
                                Text("Registrar")
                            }
                            .font(.headline)
                        }
                    }
                }
            }
        }
    }

#Preview {
    HomeView()
}
