//
//  PlanningPlanejarView.swift
//  CashUp
//
//  Created by Gustavo Souto Pereira on 12/05/25.
//

import SwiftUI

struct PlanningPlanejarView: View {
    @Binding var gasolinaValor: String
    @Binding var uberValor: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            
            // MARK: - Despesas Planejadas Card
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
                        Text("R$ 1.200,00")
                            .font(.title2)
                            .bold()
                    }
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("🟪 Transporte - 50% - R$ 600,00")
                    Text("🟦 Alimentação - 30% - R$ 360,00")
                    Text("🟥 Lazer - 20% - R$ 240,00")
                }
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(12)
            .frame(maxWidth: .infinity)
            
            // MARK: - Lista de Categorias
            VStack(alignment: .leading, spacing: 12) {
                Text("Transporte")
                    .font(.title2)
                    .bold()
                Divider()
                
                HStack {
                    Image(systemName: "fuelpump.circle.fill")
                        .foregroundColor(.purple)
                        .font(.system(size: 24))
                    Text("Gasolina")
                    Spacer()
                    TextField("R$", text: $gasolinaValor)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 100)
                        .padding(6)
                        .cornerRadius(6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .onChange(of: gasolinaValor) {
                            gasolinaValor = gasolinaValor.filter { "0123456789,.".contains($0) }
                        }
                }
                Divider()
                
                HStack {
                    Image(systemName: "car.circle.fill")
                        .foregroundColor(.purple)
                        .font(.system(size: 24))
                    Text("Uber")
                    Spacer()
                    TextField("R$", text: $uberValor)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 100)
                        .padding(6)
                        .cornerRadius(6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .onChange(of: uberValor) {
                            uberValor = uberValor.filter { "0123456789,.".contains($0) }
                        }
                }
                Divider()
                
                Button(action: {
                    // ação para adicionar subcategoria
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                        Text("Adicionar subcategoria")
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(12)
            .frame(maxWidth: .infinity)
            
            // MARK: - Nova Categoria
            VStack(alignment: .leading, spacing: 12) {
                Button(action: {
                    // ação para adicionar categoria
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                        Text("Adicionar Nova Categoria")
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(12)
            .frame(maxWidth: .infinity)
        }
    }
}
