//
//  CategoriaFiltroView.swift
//  CashUp
//
//  Created by Gustavo Souto Pereira on 13/05/25.
//

import SwiftUI

struct CategoriaFiltroView: View {
    var categorias: [Categoria]
    @Binding var selectedCategoria: String
    var onSubcategoriaSelected: (Subcategoria) -> Void
    
    var subcategoriasFrequentes: [Subcategoria] = []
    
    private let buttonSize: CGFloat = 70
    private let buttonCornerRadius: CGFloat = 12
    
    // Botão para filtrar categoria
    private func categoriaButton(categoria: Categoria) -> some View {
        Button(action: {
            selectedCategoria = categoria.nome
        }) {
            VStack(spacing: 4) {
                RoundedRectangle(cornerRadius: buttonCornerRadius)
                    .fill(selectedCategoria == categoria.nome ? categoria.cor.color.opacity(0.2) : Color.gray.opacity(0.15))
                    .frame(width: buttonSize, height: buttonSize)
                    .overlay(
                        Image(systemName: categoria.icon)
                            .font(.system(size: 24))
                            .foregroundStyle(selectedCategoria == categoria.nome ? categoria.cor.color : .gray)
                    )
                
                if selectedCategoria == categoria.nome {
                    Text(categoria.nome)
                        .font(.caption2)
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.center)
                        .lineLimit(1)
                        .frame(maxWidth: buttonSize)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // Card para subcategoria com ícone e nome
    private func subcategoriaCard(categoria: Categoria, sub: Subcategoria) -> some View {
        VStack(spacing: 4) {
            CategoriasViewIcon(systemName: sub.icon, cor: categoria.cor.color, size: 30)

            Text(sub.nome)
                .font(.footnote)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
                .frame(height: 30)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, minHeight: 90)
        .padding(8)
        .background(Color.white.opacity(0.001)) // área clicável
    }
    
    // Auxiliar para encontrar categoria da subcategoria
    private func categoriaPara(_ subcategoria: Subcategoria) -> Categoria? {
        for categoria in categorias {
            if categoria.subcategorias.contains(where: { $0.id == subcategoria.id }) {
                return categoria
            }
        }
        return nil
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            
            // Seção "Mais Frequentes"
            VStack(alignment: .leading, spacing: 8) {
                Text("Mais Frequentes")
                    .font(.headline)
                    .bold()
                    .padding(.horizontal, 12)
                    .padding(.top, 12)
                    .foregroundStyle(.primary)
                
                if subcategoriasFrequentes.isEmpty {
                    Text("Nenhuma subcategoria frequente ainda.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.bottom, 12)
                        .frame(maxWidth: .infinity)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(subcategoriasFrequentes) { sub in
                                let cor = categoriaPara(sub)?.cor.color ?? .gray
                                VStack(spacing: 4) {
                                    CategoriasViewIcon(systemName: sub.icon, cor: cor, size: 30)

                                    Text(sub.nome)
                                        .font(.footnote)
                                        .foregroundStyle(.primary)
                                        .multilineTextAlignment(.center)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.5)
                                        .frame(height: 30)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .frame(width: 80)
                                .onTapGesture {
                                    onSubcategoriaSelected(sub)
                                }
                            }
                        }
                        .padding(12)
                        .animation(.easeInOut, value: subcategoriasFrequentes)
                    }
                }
            }
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            .padding(.horizontal)

            
            // Filtro horizontal de categorias
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    // Categoria "Todas" para resetar filtro
                    categoriaButton(categoria: Categoria(nome: "Todas", cor: .blue, icon: "square.grid.2x2.fill", subcategorias: []))
                    
                    // Botões para todas as outras categorias
                    ForEach(categorias) { categoria in
                        categoriaButton(categoria: categoria)
                    }
                }
                .padding(.horizontal)
                .animation(.easeInOut, value: selectedCategoria)
            }
            
            // Exibição das categorias filtradas
            ForEach(categorias.filter { selectedCategoria == "Todas" || $0.nome == selectedCategoria }) { categoria in
                VStack(alignment: .leading, spacing: 8) {
                    Text(categoria.nome)
                        .font(.title3)
                        .padding(.horizontal)

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 12)], spacing: 12) {
                        ForEach(categoria.subcategorias) { sub in
                            subcategoriaCard(categoria: categoria, sub: sub)
                                .onTapGesture {
                                    onSubcategoriaSelected(sub)
                                }
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
            }
        }
    }
}

struct CategoriaFiltroView_Previews: PreviewProvider {
    struct Wrapper: View {
        @State private var categoriaSelecionada: String = "Todas"
        
        var body: some View {
            CategoriaFiltroView(
                categorias: CategoriasData.todas,
                selectedCategoria: $categoriaSelecionada,
                onSubcategoriaSelected: { sub in
                    print("Subcategoria selecionada: \(sub.nome)")
                }
            )
        }
    }
    
    static var previews: some View {
        Wrapper()
    }
}
