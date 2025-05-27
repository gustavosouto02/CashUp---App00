// Arquivo: CashUp/Sources/Extensions/Components/Categoria/CategoriaFiltroView.swift
// Refatorado para SwiftData

import SwiftUI
import SwiftData

struct CategoriaFiltroView: View {
    // Recebe os modelos SwiftData
    var categorias: [CategoriaModel]
    @Binding var selectedCategoriaID: UUID? // ID da CategoriaModel selecionada para filtro
    var onSubcategoriaSelected: (SubcategoriaModel) -> Void // Closure com SubcategoriaModel
    
    var subcategoriasFrequentes: [SubcategoriaModel] // Já vem como [SubcategoriaModel] do ViewModel
    
    private let buttonSize: CGFloat = 70
    private let buttonCornerRadius: CGFloat = 12
    
    // Botão para filtrar categoria (agora usa CategoriaModel)
    private func categoriaButton(categoriaModel: CategoriaModel) -> some View {
        Button(action: {
            selectedCategoriaID = categoriaModel.id
        }) {
            VStack(spacing: 4) {
                RoundedRectangle(cornerRadius: buttonCornerRadius)
                    .fill(selectedCategoriaID == categoriaModel.id ? categoriaModel.color.opacity(0.2) : Color.gray.opacity(0.15))
                    .frame(width: buttonSize, height: buttonSize)
                    .overlay(
                        Image(systemName: categoriaModel.icon)
                            .font(.system(size: 24))
                            .foregroundStyle(selectedCategoriaID == categoriaModel.id ? categoriaModel.color : .gray)
                    )
                
                if selectedCategoriaID == categoriaModel.id {
                    Text(categoriaModel.nome)
                        .font(.caption2)
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.center)
                        .lineLimit(1) // Garante uma linha
                        .truncationMode(.tail) // Adiciona "..." se o texto for muito longo
                        .frame(maxWidth: buttonSize)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // Card para subcategoria (agora usa CategoriaModel e SubcategoriaModel)
    private func subcategoriaCard(categoriaModel: CategoriaModel, subcategoriaModel: SubcategoriaModel) -> some View {
        VStack(spacing: 4) {
            CategoriasViewIcon(
                systemName: subcategoriaModel.icon,
                cor: categoriaModel.color, // Cor da CategoriaModel pai
                size: 30
            )

            Text(subcategoriaModel.nome)
                .font(.footnote)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(2) // Permite até duas linhas
                .minimumScaleFactor(0.7) // Reduz o tamanho da fonte se necessário
                .frame(height: 30) // Altura fixa para alinhar
                .fixedSize(horizontal: false, vertical: true) // Permite quebra de linha vertical
        }
        .frame(maxWidth: .infinity, minHeight: 90) // Garante tamanho mínimo para toque
        .padding(8)
        .background(Color.white.opacity(0.001)) // Garante que toda a área seja clicável
        .contentShape(Rectangle()) // Define a forma da área de toque
        .onTapGesture {
            onSubcategoriaSelected(subcategoriaModel)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            
            // Seção "Mais Frequentes"
            VStack(alignment: .leading, spacing: 8) {
                Text("Mais Frequentes")
                    .font(.headline.bold()) // Aplicado bold aqui
                    .padding(.horizontal, 12)
                    .padding(.top, 12)
                    .foregroundStyle(.primary)
                
                if subcategoriasFrequentes.isEmpty {
                    Text("Nenhuma subcategoria frequente ainda.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.bottom, 12)
                        .frame(maxWidth: .infinity, alignment: .center) // Centraliza o texto
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(subcategoriasFrequentes) { subModel in
                                // A cor da categoria pai é acessada através da relação
                                let corCategoriaPai = subModel.categoria?.color ?? .gray
                                
                                VStack(spacing: 4) {
                                    CategoriasViewIcon(
                                        systemName: subModel.icon,
                                        cor: corCategoriaPai,
                                        size: 30
                                    )

                                    Text(subModel.nome)
                                        .font(.footnote)
                                        .foregroundStyle(.primary)
                                        .multilineTextAlignment(.center)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.5)
                                        .frame(width: 70, height: 30) // Largura fixa para o texto, altura para alinhar
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .frame(width: 80) // Largura total do item frequente
                                .onTapGesture {
                                    onSubcategoriaSelected(subModel)
                                }
                            }
                        }
                        .padding(12)
                        .animation(.easeInOut, value: subcategoriasFrequentes.map { $0.id }) // Anima com base nos IDs
                    }
                }
            }
            .background(Color(.secondarySystemBackground)) // Cor de fundo do sistema
            .cornerRadius(12)
            .padding(.horizontal)

            
            // Filtro horizontal de categorias
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    // Botão "Todas"
                    Button(action: {
                        selectedCategoriaID = nil // Limpa o filtro
                    }) {
                        VStack(spacing: 4) {
                            RoundedRectangle(cornerRadius: buttonCornerRadius)
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
                                    .truncationMode(.tail)
                                    .frame(maxWidth: buttonSize)
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Botões para todas as outras categorias
                    ForEach(categorias) { categoriaModel in // Itera sobre [CategoriaModel]
                        categoriaButton(categoriaModel: categoriaModel)
                    }
                }
                .padding(.horizontal)
                .animation(.easeInOut, value: selectedCategoriaID)
            }
            

            let categoriasParaExibir = categorias.filter { categoriaModel in
                selectedCategoriaID == nil || categoriaModel.id == selectedCategoriaID
            }

            ForEach(categoriasParaExibir) { categoriaModel in // Itera sobre as CategoriaModel filtradas
                VStack(alignment: .leading, spacing: 8) {
                    Text(categoriaModel.nome)
                        .font(.title3.bold()) // Adicionado bold
                        .padding(.horizontal)

                    // Garante que `subcategorias` não é nil antes de tentar iterar
                    if let subcategoriasDaCategoria = categoriaModel.subcategorias, !subcategoriasDaCategoria.isEmpty {
                        // Ordena as subcategorias alfabeticamente para exibição consistente
                        let subcategoriasOrdenadas = subcategoriasDaCategoria.sorted { $0.nome < $1.nome }
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 90, maximum: 100), spacing: 12)], spacing: 12) { // Ajustado minimum/maximum
                            ForEach(subcategoriasOrdenadas) { subcategoriaModel in // Itera sobre [SubcategoriaModel]
                                subcategoriaCard(categoriaModel: categoriaModel, subcategoriaModel: subcategoriaModel)
                            }
                        }
                        .padding(.horizontal) // Adiciona padding à grid
                    } else {
                        Text("Nenhuma subcategoria encontrada para \(categoriaModel.nome).")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                            .padding(.bottom, 8) // Espaço se não houver subcategorias
                    }
                }
                .padding(.vertical) // Adiciona padding vertical à seção da categoria
                .background(Color(.secondarySystemBackground)) // Cor de fundo do sistema
                .cornerRadius(12)
                .padding(.horizontal) // Padding para o card da categoria inteira
                .padding(.bottom, 8) // Espaçamento entre cards de categoria
            }
        }
    }
}
