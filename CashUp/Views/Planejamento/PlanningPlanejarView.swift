import SwiftUI
import Foundation

struct PlanningPlanejarView: View {

    @ObservedObject var viewModel: PlanningViewModel
    @Binding var isEditing: Bool
    @Binding var subcategoriasSelecionadas: Set<UUID>

    @State private var isCategoryModalPresented = false
    @State private var selectedSubcategory: Subcategoria? = nil
    @State private var selectedCategory: Categoria? = nil
    @State private var showingAlert = false
    @State private var showDuplicateAlert = false

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 24) {
                despesasPlanejadasCard
                listaCategoriasPlanejadasView()
                botaoAdicionarCategoria
                Spacer()

                rodapePlanejamento
            }
            .fullScreenCover(isPresented: $isCategoryModalPresented) {
                CategorySelectionSheet(
                    selectedSubcategory: $selectedSubcategory,
                    isPresented: $isCategoryModalPresented,
                    selectedCategory: $selectedCategory
                )
            }
            .onChange(of: selectedSubcategory) { _, newValue in
                guard let novaSub = newValue, let categoria = selectedCategory else { return }
                let adicionou = viewModel.adicionarSubcategoria(novaSub, to: categoria)
                if !adicionou {
                    showDuplicateAlert = true
                }
                selectedSubcategory = nil
            }

            if showDuplicateAlert {
                alertDuplicado
            }
        }
        .animation(.easeInOut, value: showDuplicateAlert)
        .hideKeyboardOnTap()
    }

    // MARK: - Card de Resumo

    private var despesasPlanejadasCard: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(spacing: 24) {
                Circle()
                    .trim(from: 0.0, to: 1.0)
                    .stroke(
                        LinearGradient(colors: [.purple, .blue, .pink], startPoint: .top, endPoint: .bottom),
                        lineWidth: 12
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 60, height: 60)

                VStack(alignment: .leading) {
                    Text("Despesas Planejadas")
                        .font(.headline)
                    Text("R$ \(viewModel.valorTotalPlanejado(categorias: viewModel.categoriasPlanejadas), specifier: "%.2f")")
                        .font(.title2)
                        .bold()
                }
                Spacer()
            }

            ForEach(viewModel.categoriasPlanejadas) { categoria in
                categoriaResumo(categoria)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.15))
        .cornerRadius(12)
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func categoriaResumo(_ categoria: CategoriaPlanejada) -> some View {
        let total = viewModel.totalCategoria(categoria: categoria)
        let percentual = viewModel.calcularPorcentagemTotal(categoria: categoria)

        VStack(spacing: 4) {
            HStack {
                RoundedRectangle(cornerRadius: 3)
                    .fill(categoria.categoria.color) // Usa a cor da categoria mestra
                    .frame(width: 12, height: 12)
                    .padding(.leading, 4) // Ajuste o espaçamento conforme necessário

                Text(categoria.categoria.nome)
                    .font(.subheadline)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("\(percentual, specifier: "%.0f")%")
                    .font(.subheadline)
                    .frame(width: 50, alignment: .trailing)

                Text("R$ \(total, specifier: "%.2f")")
                    .font(.subheadline)
                    .frame(width: 100, alignment: .trailing)
            }
            Divider()
        }
    }

    // MARK: - Lista de Categorias Planejadas

    @ViewBuilder
    private func listaCategoriasPlanejadasView() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(viewModel.categoriasPlanejadas) { catItem in
                categoriaPlanejadaView(catItem)
            }
        }
    }

    @ViewBuilder
    private func categoriaPlanejadaView(_ catItem: CategoriaPlanejada) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                CategoriasViewIcon(systemName: catItem.categoria.icon, cor: catItem.categoria.color, size: 24)
                Text(catItem.categoria.nome)
                    .font(.headline)
                Spacer()
            }

            Divider()

            ForEach(catItem.subcategoriasPlanejadas) { sub in
                SubcategoriaPlanejadaRowView(
                    sub: bindingForSubcategoria(sub, in: catItem),
                    corIcone: catItem.categoria.color,
                    onDelete: {
                        viewModel.removerSubcategoriasSelecionadas([sub.id])
                    },
                    isEditing: isEditing,
                    isSelected: subcategoriasSelecionadas.contains(sub.id),
                    toggleSelection: {
                        if subcategoriasSelecionadas.contains(sub.id) {
                            subcategoriasSelecionadas.remove(sub.id)
                        } else {
                            subcategoriasSelecionadas.insert(sub.id)
                        }
                    }
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if !isEditing {
                Button(action: {
                    selectedCategory = catItem.categoria
                    isCategoryModalPresented = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(.blue)
                        Text("Adicionar Subcategoria")
                    }
                    .padding(.top, 4)
                    
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }

    private func bindingForSubcategoria(_ sub: SubcategoriaPlanejada, in categoria: CategoriaPlanejada) -> Binding<SubcategoriaPlanejada> {
        guard let catIndex = viewModel.categoriasPlanejadas.firstIndex(where: { $0.id == categoria.id }),
              let subIndex = viewModel.categoriasPlanejadas[catIndex].subcategoriasPlanejadas.firstIndex(where: { $0.id == sub.id }) else {
            fatalError("Índice inválido para categoria ou subcategoria")
        }
        return $viewModel.categoriasPlanejadas[catIndex].subcategoriasPlanejadas[subIndex]
    }

    // MARK: - Rodapé com botão de zerar

    private var rodapePlanejamento: some View {
        HStack {
            Text("Planejamento para:\n\(viewModel.currentMonth, format: .dateTime.month(.wide).year(.defaultDigits))")
                .font(.caption2)
            Spacer()
            Button("Zerar Planejamento") {
                showingAlert = true
            }
            .font(.caption)
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text("Zerar Planejamento"),
                    message: Text("Tem certeza que deseja zerar o planejamento para este mês? Esta ação é irreversível."),
                    primaryButton: .destructive(Text("Zerar")) {
                        viewModel.zerarPlanejamentoDoMes()
                    },
                    secondaryButton: .cancel(Text("Cancelar"))
                )
            }
        }
        .padding(.horizontal)
        .padding(.top)
    }

    // MARK: - Alerta de duplicado

    private var alertDuplicado: some View {
        VStack {
            Spacer()
            Text("Subcategoria já adicionada")
                .padding()
                .background(Color.red.opacity(0.85))
                .foregroundStyle(.white)
                .cornerRadius(10)
                .padding(.horizontal, 40)
                .transition(.move(edge: .bottom).combined(with: .opacity))
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation(.easeInOut) {
                    showDuplicateAlert = false
                }
            }
        }
    }

    // MARK: - Botão Adicionar Categoria

    private var botaoAdicionarCategoria: some View {
        Button(action: {
            selectedCategory = nil
            isCategoryModalPresented = true
        }) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .foregroundStyle(.blue)
                Text("Adicionar Categoria")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.gray.opacity(0.15))
            .cornerRadius(12)
        }
    }
}
