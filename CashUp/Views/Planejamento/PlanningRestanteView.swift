// Arquivo: CashUp/Views/Planejamento/PlanningRestanteView.swift
// Refatorado para SwiftData

import SwiftUI
import SwiftData

struct PlanningRestanteView: View {
    @ObservedObject var planningViewModel: PlanningViewModel // ViewModel refatorado
    @ObservedObject var expensesViewModel: ExpensesViewModel // ViewModel refatorado

    // Os dados de planejamento agora vêm de uma função no PlanningViewModel
    // que retorna [CategoriaPlanejadaModel].
    private var categoriasPlanejadasDoMes: [CategoriaPlanejadaModel] {
        planningViewModel.getCategoriasPlanejadasForCurrentMonth()
    }

    var body: some View {
        ScrollView { // Adicionado ScrollView para conteúdo que pode exceder
            VStack(alignment: .leading, spacing: 24) {

                // MARK: - Meta Residual
                metaResidualCard()

                // MARK: - Categorias de Planejamento Detalhadas
                if categoriasPlanejadasDoMes.isEmpty {
                    Text("Nenhum planejamento definido para este mês.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    ForEach(categoriasPlanejadasDoMes) { categoriaPlanejadaModel in
                        // Passa CategoriaPlanejadaModel para a subview
                        categoriaRestanteView(categoriaPModel: categoriaPlanejadaModel)
                    }
                }
                Spacer(minLength: 24) // Adicionado Spacer para garantir espaço no final
            }
            .padding() // Adicionado padding ao VStack principal
        }
        // A sincronização de currentMonth entre PlanningViewModel e ExpensesViewModel
        // deve ser gerenciada pela View pai (PlanningView).
    }

    @ViewBuilder
    private func metaResidualCard() -> some View {
        // Usa a função do PlanningViewModel que já opera com os modelos SwiftData
        let totalPlanejado = planningViewModel.valorTotalPlanejadoParaMesAtual()
        
        // A função em ExpensesViewModel agora espera [CategoriaPlanejadaModel]
        let totalGastoEmPlanejado = expensesViewModel.calcularTotalGastoEmCategoriasPlanejadas(
            paraMes: planningViewModel.currentMonth, // Usa o currentMonth do planningViewModel
            categoriasPlanejadas: categoriasPlanejadasDoMes // Passa o array de CategoriaPlanejadaModel
        )
        
        let restante = totalPlanejado - totalGastoEmPlanejado
        let progresso = totalPlanejado > 0 ? min(abs(totalGastoEmPlanejado / totalPlanejado), 1.0) : 0.0
        // Corrigido para abs(totalGastoEmPlanejado / totalPlanejado) para garantir que o progresso não seja negativo
        // e para mudar a cor do gradiente se o restante for negativo.
        
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 10)

                    Circle()
                        .trim(from: 0.0, to: CGFloat(progresso))
                        .stroke(
                            LinearGradient(
                                colors: restante < 0 ? [.orange, .red] : [.green, .blue], // Muda cor se estourou
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            style: StrokeStyle(lineWidth: 10, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                    Text("\(Int(progresso * 100))%")
                        .font(.caption.bold())
                }
                .frame(width: 80, height: 80)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Restante do Planejamento")
                        .font(.subheadline)
                        .padding(.bottom, 2)

                    Text(formatCurrency(restante)) //
                        .font(.title.bold())
                        .foregroundStyle(restante < 0 ? .red : .primary)

                    Text("Total Planejado: \(formatCurrency(totalPlanejado))") //
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.top, 4)
                }
                Spacer()
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    func categoriaRestanteView(categoriaPModel: CategoriaPlanejadaModel) -> some View {
        // Total planejado para esta CategoriaPlanejadaModel
        let totalPlanejadoCategoria = planningViewModel.totalParaCategoriaPlanejada(categoriaPModel)

        // Total gasto nesta CategoriaPlanejadaModel
        // A função em ExpensesViewModel agora espera CategoriaPlanejadaModel
        let totalGastoCategoria = expensesViewModel.calcularTotalGastoParaCategoria(
            categoriaPModel,
            paraMes: planningViewModel.currentMonth // Usa o currentMonth do planningViewModel
        )
        let restanteCategoria = totalPlanejadoCategoria - totalGastoCategoria

        VStack(alignment: .leading, spacing: 12) {
            HStack {
                CategoriasViewIcon( //
                    systemName: categoriaPModel.iconCategoriaOriginal,
                    cor: categoriaPModel.corCategoriaOriginal,
                    size: 22
                )
                Text(categoriaPModel.nomeCategoriaOriginal)
                    .font(.headline)
                Spacer()
                Text("\(formatCurrency(restanteCategoria)) restante") //
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(restanteCategoria < 0 ? .red : .secondary)
            }

            // Itera sobre as SubcategoriaPlanejadaModel
            if let subcategoriasPlanejadas = categoriaPModel.subcategoriasPlanejadas, !subcategoriasPlanejadas.isEmpty {
                ForEach(subcategoriasPlanejadas.sorted(by: { $0.subcategoriaOriginal?.nome ?? "" < $1.subcategoriaOriginal?.nome ?? "" })) { subPlanModel in
                    // Gasto na SubcategoriaPlanejadaModel
                    // A função em ExpensesViewModel agora espera SubcategoriaPlanejadaModel
                    let gastoNaSub = expensesViewModel.calcularTotalGastoParaSubcategoria(
                        subPlanModel,
                        paraMes: planningViewModel.currentMonth // Usa o currentMonth do planningViewModel
                    )
                    let limiteDaSub = subPlanModel.valorPlanejado
                    let progressoSub = limiteDaSub > 0 ? min(abs(gastoNaSub / limiteDaSub), 1.0) : 0.0
                    // Corrigido para abs() para garantir que progresso não seja negativo

                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            CategoriasViewIcon( //
                                systemName: subPlanModel.iconSubcategoriaOriginal,
                                cor: categoriaPModel.corCategoriaOriginal, // Cor da categoria pai
                                size: 18
                            )
                            Text(subPlanModel.nomeSubcategoriaOriginal)
                                .font(.subheadline)
                    
                            Spacer()
                            Text("\(formatCurrency(gastoNaSub)) / \(formatCurrency(limiteDaSub))") //
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.leading, 8)

                        ProgressView(value: progressoSub)
                            .tint(gastoNaSub > limiteDaSub ? .red : categoriaPModel.corCategoriaOriginal) // Vermelho se estourou
                            .padding(.leading, 8)
                    }
                    .padding(.bottom, 4)
                }
            } else {
                Text("Nenhuma subcategoria planejada.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.leading)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .frame(maxWidth: .infinity, alignment: .top)
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "pt_BR") //
        return formatter.string(from: NSNumber(value: value)) ?? "R$0,00"
    }
}
