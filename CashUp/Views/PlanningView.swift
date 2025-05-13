import SwiftUI

struct PlanningView: View {
    @Environment(\.sizeCategory) var sizeCategory
    @StateObject private var viewModel = MonthSelectorViewModel()
    @StateObject private var planningViewModel = PlanningViewModel()

    @State private var gasolinaValor: String = ""
    @State private var uberValor: String = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // MARK: - Header
                    MonthSelector(
                        displayedMonth: viewModel.selectedMonth,
                        onPrevious: { viewModel.navigateMonth(isNext: false) },
                        onNext: { viewModel.navigateMonth(isNext: true) }
                    )
                    
                    Picker("Modo", selection: $planningViewModel.selectedTab){
                        Text("Planejar").tag(0)
                        Text("Restante").tag(1)
                    }
                    .pickerStyle(.segmented)
                    
                    if planningViewModel.selectedTab == 0 {
                        PlanningPlanejarView(
                            gasolinaValor: $gasolinaValor,
                            uberValor: $uberValor
                        )
                    } else {
                       PlanningRestanteView()
                    }
                }
                .padding() // <-- Padding externo para manter margem lateral igual à da HomeView
            }
            .navigationTitle("Planejamento")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        // ação do menu
                    }) {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .overlay(
                Divider()
                    .background(Color.gray.opacity(0.6))
                    .frame(height: 1)
                    .padding(.top, 2),
                alignment: .top
            )
        }
    }
}
struct CategoriaGasto {
    var nome: String
    var valor: Double
}

#Preview {
    PlanningView()
}

