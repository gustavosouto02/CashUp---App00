//
//  CategoriaFiltroView.swift
//  CashUp
//
//  Created by Gustavo Souto Pereira on 13/05/25.
//

import SwiftUI

struct CategoriaFiltroView: View {
    var categorias: [Categoria]
    // Mudar para UUID? para permitir nil (Todas)
    @Binding var selectedCategoriaID: UUID?
    var onSubcategoriaSelected: (Subcategoria) -> Void
    
    var subcategoriasFrequentes: [Subcategoria] = []
    
    private let buttonSize: CGFloat = 70
    private let buttonCornerRadius: CGFloat = 12
    
    // Botão para filtrar categoria
    private func categoriaButton(categoria: Categoria) -> some View {
        Button(action: {
            selectedCategoriaID = categoria.id
        }) {
            VStack(spacing: 4) {
                RoundedRectangle(cornerRadius: buttonCornerRadius)
                    // Comparar pelo ID
                    .fill(selectedCategoriaID == categoria.id ? categoria.cor.color.opacity(0.2) : Color.gray.opacity(0.15))
                    .frame(width: buttonSize, height: buttonSize)
                    .overlay(
                        Image(systemName: categoria.icon)
                            .font(.system(size: 24))
                            // Comparar pelo ID
                            .foregroundStyle(selectedCategoriaID == categoria.id ? categoria.cor.color : .gray)
                    )
                
                // Comparar pelo ID
                if selectedCategoriaID == categoria.id {
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
            // A 'categoria' já é a categoria correta para esta subcategoria
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
                                // CORREÇÃO AQUI: Use CategoriasData.categoriasub(for:) para encontrar a categoria pai da subcategoria
                                let cor = CategoriasData.categoriasub(for: sub.id)?.cor.color ?? .gray
                                
                            

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
                    Button(action: {
                        selectedCategoriaID = nil // Define nil para "Todas"
                    }) {
                        VStack(spacing: 4) {
                            RoundedRectangle(cornerRadius: buttonCornerRadius)
                                // Comparar com nil para "Todas"
                                .fill(selectedCategoriaID == nil ? Color.blue.opacity(0.2) : Color.gray.opacity(0.15))
                                .frame(width: buttonSize, height: buttonSize)
                                .overlay(
                                    Image(systemName: "square.grid.2x2.fill")
                                        .font(.system(size: 24))
                                        .foregroundStyle(selectedCategoriaID == nil ? .blue : .gray)
                                )
                            
                            if selectedCategoriaID == nil {
                                Text("Todas")
                                    .font(.caption2)
                                    .foregroundStyle(.primary)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(1)
                                    .frame(maxWidth: buttonSize)
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Botões para todas as outras categorias
                    ForEach(categorias) { categoria in
                        categoriaButton(categoria: categoria)
                    }
                }
                .padding(.horizontal)
                .animation(.easeInOut, value: selectedCategoriaID) // Animação com o ID
            }
            
            // Exibição das categorias filtradas
            ForEach(categorias.filter {
                // Filtrar pelo ID, se houver um ID selecionado
                selectedCategoriaID == nil || $0.id == selectedCategoriaID
            }) { categoria in
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
        // Mudar para UUID? e inicializar com nil para "Todas"
        @State private var categoriaSelecionadaID: UUID? = nil
        
        var body: some View {
            CategoriaFiltroView(
                categorias: CategoriasData.todas,
                selectedCategoriaID: $categoriaSelecionadaID, // Passar o binding do ID
                onSubcategoriaSelected: { sub in
                    print("Subcategoria selecionada: \(sub.nome) (ID: \(sub.id))")
                    if let cat = CategoriasData.categoriasub(for: sub.id) {
                        print("Categoria pai: \(cat.nome) (ID: \(cat.id))")
                    }
                },
                // Exemplo de como popular subcategoriasFrequentes para o preview
                subcategoriasFrequentes: [
                    CategoriasData.todas[0].subcategorias[0], // "Custos Bancários"
                    CategoriasData.todas[1].subcategorias[0], // "Academia"
                    CategoriasData.todas[2].subcategorias[1]  // "Café"
                ]
            )
        }
    }
    
    static var previews: some View {
        Wrapper()
    }
}
