import SwiftUI

struct PlanningRestanteView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {

            // MARK: - Meta Residual
            VStack(alignment: .leading, spacing: 16) {

                HStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.3), lineWidth: 12)
                        Circle()
                            .trim(from: 0.0, to: 0.75)
                            .stroke(
                                LinearGradient(colors: [.green, .blue], startPoint: .top, endPoint: .bottom),
                                style: StrokeStyle(lineWidth: 12, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                        Text("75%")
                            .font(.caption)
                            .bold()
                    }
                    .frame(width: 100, height: 100)
                    .padding(.leading, 24)
                    

                    VStack(alignment: .leading) {
                        Text("Despesas Planejadas")
                            .font(.headline)
                            .padding(.bottom, 8)
                        
                        Text("R$ 100,00")
                            .font(.title)
                            .bold()
                        
                        Text("Restante da meta")
                            .font(.subheadline)
                    }
                    .padding(.leading, 20)

                    Spacer()
                }
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(12)
            .frame(maxWidth: .infinity)

            // MARK: - Transporte
            categoriaRestanteView(
                titulo: "Transporte",
                valorRestante: 50,
                subcategorias: [
                    ("Gasolina", "fuelpump.circle.fill", 150, 200),
                    ("Manutenção", "wrench.adjustable.fill", 150, 150)
                ]
            )

            Spacer(minLength: 100) // Garante que tudo respire no final
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }

    @ViewBuilder
    func categoriaRestanteView(titulo: String, valorRestante: Double, subcategorias: [(String, String, Double, Double)]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(titulo)
                    .font(.title3)
                    .bold()
                Spacer()
                Text("R$ \(valorRestante, specifier: "%.2f") restante")
                    .foregroundColor(.secondary)
            }

            ForEach(subcategorias.indices, id: \.self) { index in
                let (nome, icone, valor, limite) = subcategorias[index]
                let progresso = min(valor / limite, 1.0)

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: icone)
                            .foregroundColor(.purple)
                            .font(.system(size: 24))
                        Text(nome)
                        Spacer()
                        Text("R$ \(valor, specifier: "%.2f") / \(limite, specifier: "%.2f")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    ProgressView(value: progresso)
                        .accentColor(progresso >= 1 ? .red : .blue)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
        .frame(maxHeight: .infinity, alignment: .top)
    }
}


#Preview {
    PlanningRestanteView()
}
