//
//  CategoriasViewIcon.swift
//  CashUp
//
//  Created by Gustavo Souto Pereira on 13/05/25.
//

//
//  CategoriasViewIcon.swift
//  CashUp
//
//  Created by Gustavo Souto Pereira on 13/05/25.
//

import SwiftUI

struct CategoriasViewIcon: View {
    let systemName: String
    let cor: Color
    let size: CGFloat

    var body: some View {
        ZStack {
            // Círculo com padding visual
            Circle()
                .fill(cor)
                .frame(width: size * 1.4, height: size * 1.4) // Ajustando o tamanho do círculo
            // Ícone centralizado dentro do círculo, com tamanho proporcional
            Image(systemName: systemName)
                .frame(alignment: .center) // Centraliza o ícone no círculo
                .font(.system(size: size * 0.6)) // Tamanho do ícone ajustável com base no 'size'
                .foregroundColor(.white)
        }
    }
}
#Preview {
    CategoriasViewIcon(systemName: "dollarsign.bank.building.fill", cor: .red, size: 24)
}

struct Subcategoria: Identifiable {
    let id = UUID()
    let nome: String
    let icon: String
}

struct Categoria: Identifiable {
    let id = UUID()
    let nome: String
    let cor: Color
    let subcategorias: [Subcategoria]
}

// MARK: - Lista de Categorias
struct CategoriasData {
    static let todas: [Categoria] = [
        Categoria(
            nome: "Diversos",
            cor: Color(red: 0.65, green: 0.45, blue: 0.25),
            subcategorias: [
                Subcategoria(nome: "Custos Bancários", icon: "dollarsign.bank.building.fill"),
                Subcategoria(nome: "Desconhecido", icon: "questionmark.app.fill"),
                Subcategoria(nome: "Diversos", icon: "archivebox.fill"),
                Subcategoria(nome: "Roupas", icon: "tshirt"),
                Subcategoria(nome: "Saúde", icon: "heart.fill")
            ]
        ),
        Categoria(
            nome: "Entretenimento",
            cor: Color(red: 1.0, green: 0.39, blue: 0.51), // FF6482
            subcategorias: [
                Subcategoria(nome: "Academia", icon: "dumbbell.fill"),
                Subcategoria(nome: "Assinatura", icon: "rectangle.stack.badge.play.fill"),
                Subcategoria(nome: "Boate", icon: "party.popper.fill"),
                Subcategoria(nome: "Boliche", icon: "figure.bowling"),
                Subcategoria(nome: "Cinema", icon: "movieclapper.fill"),
                Subcategoria(nome: "Clube", icon: "beach.umbrella.fill"),
                Subcategoria(nome: "Eletrônicos", icon: "ipad"),
                Subcategoria(nome: "Entretenimento", icon: "gamecontroller"),
                Subcategoria(nome: "Esportes", icon: "soccerball.inverse"),
                Subcategoria(nome: "Férias", icon: "airplane.departure"),
                Subcategoria(nome: "Passatempo", icon: "book.fill"),
                Subcategoria(nome: "Show", icon: "music.microphone")
            ]
        ),
        Categoria(
            nome: "Comidas e Bebidas",
            cor: .teal,
            subcategorias: [
                Subcategoria(nome: "Bebidas", icon: "wineglass.fill"),
                Subcategoria(nome: "Café", icon: "cup.and.heat.waves.fill"),
                Subcategoria(nome: "Comida", icon: "carrot.fill"),
                Subcategoria(nome: "Doce", icon: "birthday.cake"),
                Subcategoria(nome: "FastFood", icon: "takeoutbag.and.cup.and.straw"),
                Subcategoria(nome: "Mantimentos", icon: "cart.fill"),
                Subcategoria(nome: "Restaurante", icon: "fork.knife.circle")
            ]
        ),
        Categoria(
            nome: "Habitação",
            cor: .orange,
            subcategorias: [
                Subcategoria(nome: "Aluguel", icon: "house.fill"),
                Subcategoria(nome: "Artigos para o lar", icon: "sofa.fill"),
                Subcategoria(nome: "Água", icon: "drop"),
                Subcategoria(nome: "Banco", icon: "building.columns"),
                Subcategoria(nome: "Contas", icon: "doc.plaintext"),
                Subcategoria(nome: "Eletricidade", icon: "bolt.fill"),
                Subcategoria(nome: "Financiamento", icon: "creditcard"),
                Subcategoria(nome: "Habitação", icon: "house.lodge.fill"),
                Subcategoria(nome: "Impostos", icon: "percent"),
                Subcategoria(nome: "Jardim", icon: "leaf"),
                Subcategoria(nome: "Internet", icon: "wifi"),
                Subcategoria(nome: "Manutenção", icon: "wrench.and.screwdriver"),
                Subcategoria(nome: "Serviço", icon: "person.2.badge.gearshape.fill"),
                Subcategoria(nome: "Seguro", icon: "shield"),
                Subcategoria(nome: "Telefone", icon: "phone.fill"),
                Subcategoria(nome: "TV", icon: "tv.fill")
            ]
        ),
        Categoria(
            nome: "Transporte",
            cor: Color(red: 0.75, green: 0.35, blue: 0.98), // BF5AF2
            subcategorias: [
                Subcategoria(nome: "Carros de Aplicativo", icon: "car.2.fill"),
                Subcategoria(nome: "Custos do Carro", icon: "car.circle.fill"),
                Subcategoria(nome: "Estacionamento", icon: "parkingsign.circle.fill"),
                Subcategoria(nome: "Financiamento", icon: "creditcard"),
                Subcategoria(nome: "Gasolina", icon: "fuelpump.fill"),
                Subcategoria(nome: "Manutenção", icon: "car.badge.gearshape.fill"),
                Subcategoria(nome: "Seguro do Carro", icon: "car.side.lock.fill"),
                Subcategoria(nome: "Transporte Público", icon: "bus"),
                Subcategoria(nome: "Transporte", icon: "tram"),
                Subcategoria(nome: "Táxi", icon: "car.top.arrowtriangle.rear.left")
            ]
        ),
        Categoria(
            nome: "Estilo de Vida",
            cor: Color(red: 0.85, green: 0.33, blue: 0.31), // DA544F
            subcategorias: [
                Subcategoria(nome: "Animal Estimação", icon: "pawprint.fill"),
                Subcategoria(nome: "Caridade", icon: "hands.clap.fill"),
                Subcategoria(nome: "Compras", icon: "bag.fill"),
                Subcategoria(nome: "Comunidade", icon: "person.3.fill"),
                Subcategoria(nome: "Creche", icon: "figure.and.child.holdinghands"),
                Subcategoria(nome: "Dentista", icon: "cross.case"),
                Subcategoria(nome: "Escritório", icon: "folder.fill"),
                Subcategoria(nome: "Educação", icon: "book.closed.fill"),
                Subcategoria(nome: "Estilo de Vida", icon: "figure.dance"),
                Subcategoria(nome: "Farmácia", icon: "pills.fill"),
                Subcategoria(nome: "Hotel", icon: "bed.double.fill"),
                Subcategoria(nome: "Médico", icon: "stethoscope.circle.fill"),
                Subcategoria(nome: "Presente", icon: "gift.fill"),
                Subcategoria(nome: "Trabalho", icon: "briefcase.fill"),
                Subcategoria(nome: "Viagem", icon: "airplane")
            ]
        ),
        Categoria(
            nome: "Renda",
            cor: Color(hue: 135/360, saturation: 0.8, brightness: 0.7), // 30D158
            subcategorias: [
                Subcategoria(nome: "Investimentos", icon: "chart.line.uptrend.xyaxis"),
                Subcategoria(nome: "Juros", icon: "percent"),
                Subcategoria(nome: "Pensão", icon: "person.2.fill"),
                Subcategoria(nome: "Renda", icon: "arrow.down.to.line.circle.fill"),
                Subcategoria(nome: "Salário", icon: "banknote"),
                Subcategoria(nome: "Salário Família", icon: "house.and.flag.fill")
            ]
        )
    ]
}
