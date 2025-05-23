import SwiftUI
import Foundation // Necessário para Date, Calendar, etc.

struct PlanningRestanteView: View {
    @ObservedObject var planningViewModel: PlanningViewModel
    @ObservedObject var expensesViewModel: ExpensesViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {

            // MARK: - Meta Residual
            VStack(alignment: .leading, spacing: 16) {

                HStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.3), lineWidth: 12)

                        Circle()
                            .trim(from: 0.0, to: CGFloat(metaResidualProgress())) // Progresso real
                            .stroke(
                                LinearGradient(colors: [.green, .blue], startPoint: .top, endPoint: .bottom),
                                style: StrokeStyle(lineWidth: 12, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                        Text("\(Int(metaResidualProgress() * 100))%") // Porcentagem real
                            .font(.caption)
                            .bold()
                    }
                    .frame(width: 100, height: 100)
                    

                    VStack(alignment: .leading) {
                        Text("Restante do Planejamento")
                            .font(.subheadline)
                            .padding(.bottom, 2)

                        Text(formatCurrency(totalRestanteDoPlanejamento()))
                            .font(.title)
                            .bold()
                            .foregroundStyle(totalRestanteDoPlanejamento() < 0 ? .red : .primary)

                        Text("Total Planejado: \(formatCurrency(planningViewModel.valorTotalPlanejado(categorias: planningViewModel.getCategoriasPlanejadasForCurrentMonth())))")
                            .font(.subheadline)
                            .padding(.top, 8)
                    }

                    Spacer()
                }
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(12)
            .frame(maxWidth: .infinity)

            // MARK: - Categorias de Planejamento Detalhadas
            ForEach(planningViewModel.getCategoriasPlanejadasForCurrentMonth()) { categoriaPlanejada in
                categoriaRestanteView(categoriaPlanejada: categoriaPlanejada)
            }

            Spacer(minLength: 100)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .onAppear {
            expensesViewModel.currentMonth = planningViewModel.currentMonth
        }
        .onChange(of: planningViewModel.currentMonth) { _, newMonth in
            // Reage a mudanças no mês do planningViewModel
            expensesViewModel.currentMonth = newMonth
        }
    }

    func totalRestanteDoPlanejamento() -> Double {
        let categoriasPlanejadasMesAtual = planningViewModel.getCategoriasPlanejadasForCurrentMonth()
        let totalPlanejado = planningViewModel.valorTotalPlanejado(categorias: categoriasPlanejadasMesAtual)

        // Chama o cálculo do ExpensesViewModel
        let totalGastoEmPlanejado = expensesViewModel.calcularTotalGastoEmCategoriasPlanejadas(
            paraMes: expensesViewModel.currentMonth, // Usa o currentMonth do expensesViewModel
            categoriasPlanejadas: categoriasPlanejadasMesAtual
        )
        return totalPlanejado - totalGastoEmPlanejado
    }

    func metaResidualProgress() -> Double {
        let categoriasPlanejadasMesAtual = planningViewModel.getCategoriasPlanejadasForCurrentMonth()
        let totalPlanejado = planningViewModel.valorTotalPlanejado(categorias: categoriasPlanejadasMesAtual)
        guard totalPlanejado > 0 else { return 0.0 }

        // Chama o cálculo do ExpensesViewModel
        let totalGastoEmPlanejado = expensesViewModel.calcularTotalGastoEmCategoriasPlanejadas(
            paraMes: expensesViewModel.currentMonth, // Usa o currentMonth do expensesViewModel
            categoriasPlanejadas: categoriasPlanejadasMesAtual
        )
        // Se totalGastoEmPlanejado exceder totalPlanejado, o progresso é limitado a 1.0 (100%)
        return min(totalGastoEmPlanejado / totalPlanejado, 1.0)
    }

    @ViewBuilder
    func categoriaRestanteView(categoriaPlanejada: CategoriaPlanejada) -> some View {
        let totalPlanejadoCategoria = planningViewModel.totalCategoria(categoria: categoriaPlanejada)

        // Chama o cálculo do ExpensesViewModel
        let totalGastoCategoria = expensesViewModel.calcularTotalGastoParaCategoria(
            categoriaPlanejada,
            paraMes: expensesViewModel.currentMonth // Usa o currentMonth do expensesViewModel
        )
        let restanteCategoria = totalPlanejadoCategoria - totalGastoCategoria

        VStack(alignment: .leading, spacing: 16) {
            HStack {
                // Ícone para a categoria principal
                CategoriasViewIcon(systemName: categoriaPlanejada.categoria.icon, cor: categoriaPlanejada.categoria.color, size: 24)
                Text(categoriaPlanejada.categoria.nome)
                    .font(.headline)
                Spacer()
                Text("\(formatCurrency(restanteCategoria)) restante")
                    .foregroundStyle(restanteCategoria < 0 ? .red : .secondary)
            }

            ForEach(categoriaPlanejada.subcategoriasPlanejadas, id: \.id) { (subPlanejada: SubcategoriaPlanejada) in
                // Chama o cálculo do ExpensesViewModel
                let gastoNaSub = expensesViewModel.calcularTotalGastoParaSubcategoria(
                    subPlanejada,
                    paraMes: expensesViewModel.currentMonth // Usa o currentMonth do expensesViewModel
                )
                let limiteDaSub = subPlanejada.valorPlanejado
                let progresso = limiteDaSub > 0 ? min(gastoNaSub / limiteDaSub, 1.0) : 0.0

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        CategoriasViewIcon(systemName: subPlanejada.subcategoria.icon, cor: categoriaPlanejada.categoria.color, size: 20)
                        Text(subPlanejada.subcategoria.nome)
                            .font(.headline)
                
                        Spacer()
                        Text("\(formatCurrency(gastoNaSub)) / \(formatCurrency(limiteDaSub))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.leading)

                    ProgressView(value: progresso)
                        .accentColor(progresso >= 1 ? .red : categoriaPlanejada.categoria.color)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
        .frame(maxHeight: .infinity, alignment: .top)
    }

    func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: NSNumber(value: value)) ?? "R$ 0,00"
    }
}

#Preview {
    PlanningRestanteView(
        planningViewModel: PlanningViewModel(),
        expensesViewModel: ExpensesViewModel() // Passe uma instância aqui
    )
    // Se suas views filhas esperam EnvironmentObjects, ainda precisa injetar no preview
    .environmentObject(ExpensesViewModel())
    .environmentObject(PlanningViewModel())
}
