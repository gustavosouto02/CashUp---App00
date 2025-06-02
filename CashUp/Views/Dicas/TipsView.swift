//
//  TipsView.swift
//  CashUp
//
//  Created by Gustavo Souto Pereira on 08/05/25.
//

import SwiftUI

// Estrutura auxiliar para definir os dados de cada dica (uso local)
struct TipInfo: Identifiable {
    let id = UUID()
    let iconName: String
    let title: String
    let description: String
    let iconColor: Color
}

struct TipsView: View {
    @Environment(\.dismiss) private var dismiss
    // Dados estáticos para as dicas gerais
    let generalTips: [TipInfo] = [
        TipInfo(iconName: "takeoutbag.and.cup.and.straw.fill",
                title: "Controle os Gastos com Delivery",
                description: "Defina um limite semanal para pedidos de comida. Cozinhar em casa pode gerar uma grande economia e ser mais saudável!",
                iconColor: .teal),
        TipInfo(iconName: "rectangle.stack.badge.play.fill",
                title: "Revise Suas Assinaturas",
                description: "Cancele serviços de streaming, apps ou outras assinaturas que você não usa com frequência. Esses pequenos valores somados fazem diferença no orçamento!",
                iconColor: Color(red: 1.0, green: 0.39, blue: 0.51)),
        TipInfo(iconName: "creditcard.and.123",
                title: "Evite Compras por Impulso",
                description: "Antes de fazer uma compra não essencial, especialmente online, espere 24 horas. Muitas vezes, o desejo diminui e você evita um gasto desnecessário.",
                iconColor: .red),
        TipInfo(iconName: "graduationcap.fill",
                title: "Invista em Você",
                description: "Considere separar uma pequena parte da sua renda para cursos, livros ou atividades que agreguem ao seu desenvolvimento pessoal e profissional.",
                iconColor: .indigo)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 10) {
                            Image(systemName: "chart.pie.fill")
                                .font(.largeTitle)
                                .foregroundColor(.accentColor)
                            Text("Planeje seu Salário: A Regra 50/30/20")
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        .padding(.bottom, 8)
                        
                        Text("Uma estratégia simples e eficaz para organizar suas finanças, garantindo que você cubra suas necessidades, aproveite seus desejos e construa um futuro financeiro sólido.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Divider().padding(.vertical, 4)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            TipDetailRow(percentage: "50%",
                                         category: "Gastos Essenciais (Necessidades)",
                                         details: "Aluguel/moradia, contas (água, luz, internet), transporte para trabalho/estudo, alimentação básica em casa, saúde.",
                                         color: .green)
                            
                            TipDetailRow(percentage: "30%",
                                         category: "Gastos com Estilo de Vida (Desejos)",
                                         details: "Lazer (cinema, shows, streaming), hobbies, compras (roupas, eletrônicos não essenciais), restaurantes, viagens.",
                                         color: .blue)
                            
                            TipDetailRow(percentage: "20%",
                                         category: "Poupança e Pagamento de Dívidas",
                                         details: "Prioridade para quitar possíveis dívidas com juros altos. Depois, foque em criar sua reserva de emergência e investir para seus objetivos de longo prazo.",
                                         color: .purple)
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(15)
                    .padding(.horizontal)
                    
                    Text("Mais Dicas para seu Bolso")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                        .padding(.top, 10)
                    
                    // Cards de Dicas Gerais
                    ForEach(generalTips) { tip in
                        TipCardView(tip: tip)
                            .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding(.top, 20)
            }
            .navigationTitle("Dicas Financeiras")
            .background(Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Voltar") {
                        dismiss()
                    }
                    .foregroundStyle(.blue)
                }
            }
            .accentColor(Color(red: 0/255, green: 122/255, blue: 255/255))
        }
    }
    
    fileprivate struct TipDetailRow: View {
        let percentage: String
        let category: String
        let details: String
        let color: Color
        
        var body: some View {
            HStack(alignment: .top, spacing: 12) {
                Text(percentage)
                    .font(Font.system(.title2, design: .rounded).weight(.bold))
                    .foregroundColor(color)
                    .frame(minWidth: 65, alignment: .leading)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(category)
                        .font(Font.system(.headline, design: .rounded).weight(.semibold))
                        .foregroundColor(color)
                    Text(details)
                        .font(Font.system(.callout, design: .rounded))
                        .foregroundColor(.secondary)
                        .lineSpacing(3)
                }
            }
            .padding(.vertical, 6)
        }
    }
    
    fileprivate struct TipCardView: View {
        let tip: TipInfo
        
        var body: some View {
            HStack(alignment: .center, spacing: 15) {
                Image(systemName: tip.iconName)
                    .font(.title)
                    .foregroundColor(tip.iconColor)
                    .frame(width: 40, alignment: .center)
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(tip.title)
                        .font(Font.system(.headline, design: .rounded).weight(.semibold))
                    Text(tip.description)
                        .font(Font.system(.subheadline, design: .rounded))
                        .foregroundColor(.secondary)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
            }
            .padding(15)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(15)
        }
    }
}
