//
//  PlanningPlanejarView.swift
//  CashUp
//
//  Created by Gustavo Souto Pereira on 12/05/25.
//

import SwiftUI

struct PlanningPlanejarView: View {
    
    @ObservedObject var viewModel: PlanningViewModel
    @State private var isCategoryModalPresented = false
    @State private var selectedSubcategory: Subcategoria? = nil
    @State private var selectedCategory: Categoria? = nil
    @State private var showingAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            
            // Despesas Planejadas Card
            despesasPlanejadasCard
            
            // Lista de Categorias Planejadas
            listaCategoriasPlanejadas
            
            // Botão Adicionar Categoria (quando vazio)
            if viewModel.categoriasPlanejadas.isEmpty {
                botaoAdicionarCategoria
            }
            
            Spacer()
            
            HStack {
                Text("Planejamento para: \n \(viewModel.currentMonth, format: .dateTime.month(.wide).year(.defaultDigits))")
                    .font(.caption2)
                Spacer()
                Button("Zerar Planejamento") {
                    showingAlert = true // Mostra o alerta ao tocar no botão
                }
                .font(.caption)
                .alert(isPresented: $showingAlert) { // Define o alerta
                    Alert(
                        title: Text("Zerar Planejamento"),
                        message: Text("Tem certeza que deseja zerar o planejamento para este mês? Esta ação é irreversível."),
                        primaryButton: .destructive(Text("Zerar")) {
                            viewModel.zerarPlanejamentoDoMes() // Ação ao confirmar
                        },
                        secondaryButton: .cancel(Text("Cancelar")) // Botão de cancelar
                    )
                }
            }
            .padding(.horizontal)
            .padding(.top)
        }
        .fullScreenCover(isPresented: $isCategoryModalPresented) {
            CategorySelectionSheet(
                selectedSubcategory: $selectedSubcategory,
                isPresented: $isCategoryModalPresented,
                selectedCategory: $selectedCategory
            )
        }
        .onChange(of: selectedSubcategory) { oldValue, newValue in
            guard let newSubcategory = newValue, let category = selectedCategory else { return }
            viewModel.adicionarSubcategoria(newSubcategory, to: category)
            selectedSubcategory = nil
        }
    }
    
    // MARK: - Resumo Despesas Planejadas
    
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
            .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(viewModel.categoriasPlanejadas) { categoria in
                    let totalCategoriaValue = viewModel.totalCategoria(categoria: categoria)
                    let porcentagemTotal = viewModel.calcularPorcentagemTotal(categoria: categoria)
                    
                    VStack(spacing: 4) {
                        HStack {
                            Text(categoria.categoria.nome)
                                .font(.subheadline)
                                .lineLimit(1)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text("\(porcentagemTotal, specifier: "%.0f")%")
                                .font(.subheadline)
                                .frame(width: 50, alignment: .trailing)
                            
                            Text("R$ \(totalCategoriaValue, specifier: "%.2f")")
                                .font(.subheadline)
                                .frame(width: 100, alignment: .trailing)
                        }
                        Divider()
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
        .frame(maxWidth: .infinity)
    }
    
    
    private var listaCategoriasPlanejadas: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(viewModel.categoriasPlanejadas) { catItem in
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        CategoriasViewIcon(systemName: catItem.categoria.icon, cor: catItem.categoria.cor, size: 24)
                        Text(catItem.categoria.nome)
                            .font(.headline)
                        Spacer()
                    }
                    Divider()
                    
                    ForEach(catItem.subcategoriasPlanejadas) { sub in
                        HStack {
                            CategoriasViewIcon(systemName: sub.subcategoria.icon, cor: catItem.categoria.cor, size: 20)
                            Text(sub.subcategoria.nome)
                            Spacer()
                            TextField(
                                "R$",
                                text: viewModel.bindingParaValorPlanejado(categoria: catItem, subcategoria: sub)
                            )
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 60)
                            .padding(6)
                            .cornerRadius(6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        }
                        Divider()
                    }
                    
                    Button(action: {
                        selectedCategory = catItem.categoria
                        isCategoryModalPresented = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                            Text("Adicionar Subcategoria")
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(12)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private var botaoAdicionarCategoria: some View {
        VStack(alignment: .leading) {
            Button(action: {
                selectedCategory = nil
                isCategoryModalPresented = true
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.blue)
                    Text("Adicionar Categoria")
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(12)
        }
    }
}
