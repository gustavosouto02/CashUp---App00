import SwiftUI

// MARK: - View do ícone com fundo em círculo
struct CategoriasViewIcon: View {
    let systemName: String
    let cor: Color
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(cor) // cor sólida, sem transparência
                .frame(width: size * 1.4, height: size * 1.4)
            Image(systemName: systemName)
                .font(.system(size: size * 0.6))
                .foregroundStyle(.white)
        }
    }
}

#Preview {
    CategoriasViewIcon(systemName: "dollarsign.bank.building.fill", cor: .red, size: 24)
}

// MARK: - Subcategoria
struct Subcategoria: Identifiable, Equatable, Hashable, Codable {
    let id: UUID
    let nome: String
    let icon: String

    // Agora id pode ser passado manualmente (para reutilizar)
    init(id: UUID, nome: String, icon: String) {
        self.id = id
        self.nome = nome
        self.icon = icon
    }
}

// MARK: - Categoria
struct Categoria: Identifiable, Equatable, Hashable, Codable {
    let id: UUID
    let nome: String
    let cor: CodableColor
    let icon: String
    let subcategorias: [Subcategoria]

    var color: Color { cor.color }

    // Também aceita id opcional para reutilizar
    init(id: UUID = UUID(), nome: String, cor: Color, icon: String, subcategorias: [Subcategoria]) {
        self.id = id
        self.nome = nome
        self.cor = CodableColor(color: cor)
        self.icon = icon
        self.subcategorias = subcategorias
    }
}

// MARK: - CodableColor para codificar/descodificar Color
struct CodableColor: Codable, Equatable, Hashable {
    let red: CGFloat
    let green: CGFloat
    let blue: CGFloat

    var color: Color {
        Color(red: red, green: green, blue: blue)
    }

    init(color: Color) {
        let uiColor = UIColor(color)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: nil)
        self.red = r
        self.green = g
        self.blue = b
    }
}

// MARK: - CategoriasData (Mock)
struct CategoriasData {
    static let idRenda = UUID(uuidString: "A0A0A0A0-A0A0-A0A0-A0A0-A0A0A0A0A0A0") ?? UUID()
    static let idEntretenimento = UUID(uuidString: "B1B1B1B1-B1B1-B1B1-B1B1-B1B1B1B1B1B1") ?? UUID()
    static let idDiversos = UUID(uuidString: "C2C2C2C2-C2C2-C2C2-C2C2-C2C2C2C2C2C2") ?? UUID()
    static let idComidasEBebidas = UUID(uuidString: "D3D3D3D3-D3D3-D3D3-D3D3-D3D3D3D3D3D3") ?? UUID()
    static let idHabitacao = UUID(uuidString: "E4E4E4E4-E4E4-E4E4-E4E4-E4E4E4E4E4E4") ?? UUID()
    static let idTransporte = UUID(uuidString: "F5F5F5F5-F5F5-F5F5-F5F5-F5F5F5F5F5F5") ?? UUID()
    static let idEstiloDeVida = UUID(uuidString: "G6G6G6G6-G6G6-G6G6-G6G6-G6G6G6G6G6G6") ?? UUID()

    // --- NEW: Fixed Subcategory IDs ---
    static let idSubCustosBancarios = UUID(uuidString: "S001S001-S001-S001-S001-S001S001S001") ?? UUID()
    static let idSubDesconhecido = UUID(uuidString: "S002S002-S002-S002-S002-S002S002S002") ?? UUID()
    static let idSubDiversosGerais = UUID(uuidString: "S003S003-S003-S003-S003-S003S003S003") ?? UUID()
    static let idSubRoupas = UUID(uuidString: "S004S004-S004-S004-S004-S004S004S004") ?? UUID()
    static let idSubSaude = UUID(uuidString: "S005S005-S005-S005-S005-S005S005S005") ?? UUID()

    static let idSubAcademia = UUID(uuidString: "B6C7D8E9-F0A1-2B3C-4D5E-6F7A8B9C0D1E") ?? UUID() // This one already exists
    static let idSubAssinatura = UUID(uuidString: "S007S007-S007-S007-S007-S007S007S007") ?? UUID()
    static let idSubBoate = UUID(uuidString: "B1B6A0CA-8A63-4630-8C0B-D8029163CA03") ?? UUID() // This one already exists
    static let idSubBoliche = UUID(uuidString: "S009S009-S009-S009-S009-S009S009S009") ?? UUID()
    static let idSubCinema = UUID(uuidString: "S010S010-S010-S010-S010-S010S010S010") ?? UUID()
    static let idSubClube = UUID(uuidString: "S011S011-S011-S011-S011-S011S011S011") ?? UUID()
    static let idSubEletronicos = UUID(uuidString: "S012S012-S012-S012-S012-S012S012S012") ?? UUID()
    static let idSubEntretenimentoGeral = UUID(uuidString: "S013S013-S013-S013-S013-S013S013S013") ?? UUID()
    static let idSubEsportes = UUID(uuidString: "S014S014-S014-S014-S014-S014S014S014") ?? UUID()
    static let idSubFerias = UUID(uuidString: "S015S015-S015-S015-S015-S015S015S015") ?? UUID()
    static let idSubPassatempo = UUID(uuidString: "S016S016-S016-S016-S016-S016S016S016") ?? UUID()
    static let idSubShow = UUID(uuidString: "S017S017-S017-S017-S017-S017S017S017") ?? UUID()

    static let idSubBebidas = UUID(uuidString: "S018S018-S018-S018-S018-S018S018S018") ?? UUID()
    static let idSubCafe = UUID(uuidString: "S019S019-S019-S019-S019-S019S019S019") ?? UUID()
    static let idSubComida = UUID(uuidString: "S020S020-S020-S020-S020-S020S020S020") ?? UUID()
    static let idSubDoce = UUID(uuidString: "S021S021-S021-S021-S021-S021S021S021") ?? UUID()
    static let idSubFastFood = UUID(uuidString: "S022S022-S022-S022-S022-S022S022S022") ?? UUID()
    static let idSubMantimentos = UUID(uuidString: "S023S023-S023-S023-S023-S023S023S023") ?? UUID()
    static let idSubRestaurante = UUID(uuidString: "S024S024-S024-S024-S024-S024S024S024") ?? UUID()

    static let idSubAluguel = UUID(uuidString: "S025S025-S025-S025-S025-S025S025S025") ?? UUID()
    static let idSubArtigosLar = UUID(uuidString: "S026S026-S026-S026-S026-S026S026S026") ?? UUID()
    static let idSubAgua = UUID(uuidString: "S027S027-S027-S027-S027-S027S027S027") ?? UUID()
    static let idSubBanco = UUID(uuidString: "S028S028-S028-S028-S028-S028S028S028") ?? UUID()
    static let idSubContas = UUID(uuidString: "S029S029-S029-S029-S029-S029S029S029") ?? UUID()
    static let idSubEletricidade = UUID(uuidString: "S030S030-S030-S030-S030-S030S030S030") ?? UUID()
    static let idSubFinanciamentoHab = UUID(uuidString: "S031S031-S031-S031-S031-S031S031S031") ?? UUID()
    static let idSubHabitacaoGeral = UUID(uuidString: "S032S032-S032-S032-S032-S032S032S032") ?? UUID()
    static let idSubImpostos = UUID(uuidString: "S033S033-S033-S033-S033-S033S033S033") ?? UUID()
    static let idSubJardim = UUID(uuidString: "S034S034-S034-S034-S034-S034S034S034") ?? UUID()
    static let idSubInternet = UUID(uuidString: "S035S035-S035-S035-S035-S035S035S035") ?? UUID()
    static let idSubManutencaoHab = UUID(uuidString: "S036S036-S036-S036-S036-S036S036S036") ?? UUID()
    static let idSubServico = UUID(uuidString: "S037S037-S037-S037-S037-S037S037S037") ?? UUID()
    static let idSubSeguroHab = UUID(uuidString: "S038S038-S038-S038-S038-S038S038S038") ?? UUID()
    static let idSubTelefone = UUID(uuidString: "S039S039-S039-S039-S039-S039S039S039") ?? UUID()
    static let idSubTV = UUID(uuidString: "S040S040-S040-S040-S040-S040S040S040") ?? UUID()

    static let idSubCarrosAplicativo = UUID(uuidString: "S041S041-S041-S041-S041-S041S041S041") ?? UUID()
    static let idSubCustosCarro = UUID(uuidString: "S042S042-S042-S042-S042-S042S042S042") ?? UUID()
    static let idSubEstacionamento = UUID(uuidString: "S043S043-S043-S043-S043-S043S043S043") ?? UUID()
    static let idSubFinanciamentoTrans = UUID(uuidString: "S044S044-S044-S044-S044-S044S044S044") ?? UUID()
    static let idSubGasolina = UUID(uuidString: "S045S045-S045-S045-S045-S045S045S045") ?? UUID()
    static let idSubManutencaoTrans = UUID(uuidString: "S046S046-S046-S046-S046-S046S046S046") ?? UUID()
    static let idSubSeguroCarro = UUID(uuidString: "S047S047-S047-S047-S047-S047S047S047") ?? UUID()
    static let idSubTransportePublico = UUID(uuidString: "S048S048-S048-S048-S048-S048S048S048") ?? UUID()
    static let idSubTransporteGeral = UUID(uuidString: "S049S049-S049-S049-S049-S049S049S049") ?? UUID()
    static let idSubTaxi = UUID(uuidString: "S050S050-S050-S050-S050-S050S050S050") ?? UUID()

    static let idSubAnimalEstimacao = UUID(uuidString: "S051S051-S051-S051-S051-S051S051S051") ?? UUID()
    static let idSubCaridade = UUID(uuidString: "S052S052-S052-S052-S052-S052S052S052") ?? UUID()
    static let idSubCompras = UUID(uuidString: "S053S053-S053-S053-S053-S053S053S053") ?? UUID()
    static let idSubComunidade = UUID(uuidString: "S054S054-S054-S054-S054-S054S054S054") ?? UUID()
    static let idSubCreche = UUID(uuidString: "S055S055-S055-S055-S055-S055S055S055") ?? UUID()
    static let idSubDentista = UUID(uuidString: "S056S056-S056-S056-S056-S056S056S056") ?? UUID()
    static let idSubEscritorio = UUID(uuidString: "S057S057-S057-S057-S057-S057S057S057") ?? UUID()
    static let idSubEducacao = UUID(uuidString: "S058S058-S058-S058-S058-S058S058S058") ?? UUID()
    static let idSubEstiloVidaGeral = UUID(uuidString: "S059S059-S059-S059-S059-S059S059S059") ?? UUID()
    static let idSubFarmacia = UUID(uuidString: "S060S060-S060-S060-S060-S060S060S060") ?? UUID()
    static let idSubHotel = UUID(uuidString: "S061S061-S061-S061-S061-S061S061S061") ?? UUID()
    static let idSubMedico = UUID(uuidString: "S062S062-S062-S062-S062-S062S062S062") ?? UUID()
    static let idSubPresente = UUID(uuidString: "S063S063-S063-S063-S063-S063S063S063") ?? UUID()
    static let idSubTrabalho = UUID(uuidString: "S064S064-S064-S064-S064-S064S064S064") ?? UUID()
    static let idSubViagem = UUID(uuidString: "S065S065-S065-S065-S065-S065S065S065") ?? UUID()

    static let idSubInvestimentos = UUID(uuidString: "S066S066-S066-S066-S066-S066S066S066") ?? UUID()
    static let idSubJuros = UUID(uuidString: "S067S067-S067-S067-S067-S067S067S067") ?? UUID()
    static let idSubPensao = UUID(uuidString: "S068S068-S068-S068-S068-S068S068S068") ?? UUID()
    static let idSubRendaGeral = UUID(uuidString: "11111111-2222-3333-4444-555555555555") ?? UUID() // Already exists
    static let idSubSalario = UUID(uuidString: "S070S070-S070-S070-S070-S070S070S070") ?? UUID()
    static let idSubSalarioFamilia = UUID(uuidString: "S071S071-S071-S071-S071-S071S071S071") ?? UUID()


    static let todas: [Categoria] = [
        Categoria(
            id: idDiversos,
            nome: "Diversos",
            cor: Color(red: 0.65, green: 0.45, blue: 0.25),
            icon: "puzzlepiece",
            subcategorias: [
                Subcategoria(id: idSubCustosBancarios, nome: "Custos Bancários", icon: "dollarsign.bank.building.fill"),
                Subcategoria(id: idSubDesconhecido, nome: "Desconhecido", icon: "questionmark.app.fill"),
                Subcategoria(id: idSubDiversosGerais, nome: "Diversos", icon: "archivebox.fill"),
                Subcategoria(id: idSubRoupas, nome: "Roupas", icon: "tshirt"),
                Subcategoria(id: idSubSaude, nome: "Saúde", icon: "heart.fill")
            ]
        ),
        Categoria(
            id: idEntretenimento,
            nome: "Entretenimento",
            cor: Color(red: 1.0, green: 0.39, blue: 0.51),
            icon: "gamecontroller",
            subcategorias: [
                Subcategoria(id: idSubAcademia, nome: "Academia", icon: "dumbbell.fill"),
                Subcategoria(id: idSubAssinatura, nome: "Assinatura", icon: "rectangle.stack.badge.play.fill"),
                Subcategoria(id: idSubBoate, nome: "Boate", icon: "party.popper.fill"), // Make sure this is using the correct fixed UUID
                Subcategoria(id: idSubBoliche, nome: "Boliche", icon: "figure.bowling"),
                Subcategoria(id: idSubCinema, nome: "Cinema", icon: "movieclapper.fill"),
                Subcategoria(id: idSubClube, nome: "Clube", icon: "beach.umbrella.fill"),
                Subcategoria(id: idSubEletronicos, nome: "Eletrônicos", icon: "ipad"),
                Subcategoria(id: idSubEntretenimentoGeral, nome: "Entretenimento", icon: "gamecontroller"),
                Subcategoria(id: idSubEsportes, nome: "Esportes", icon: "soccerball.inverse"),
                Subcategoria(id: idSubFerias, nome: "Férias", icon: "airplane.departure"),
                Subcategoria(id: idSubPassatempo, nome: "Passatempo", icon: "book.fill"),
                Subcategoria(id: idSubShow, nome: "Show", icon: "music.microphone")
            ]
        ),
        Categoria(
            id: idComidasEBebidas,
            nome: "Comidas e Bebidas",
            cor: .teal,
            icon: "fork.knife",
            subcategorias: [
                Subcategoria(id: idSubBebidas, nome: "Bebidas", icon: "wineglass.fill"),
                Subcategoria(id: idSubCafe, nome: "Café", icon: "cup.and.heat.waves.fill"),
                Subcategoria(id: idSubComida, nome: "Comida", icon: "carrot.fill"),
                Subcategoria(id: idSubDoce, nome: "Doce", icon: "birthday.cake"),
                Subcategoria(id: idSubFastFood, nome: "FastFood", icon: "takeoutbag.and.cup.and.straw"),
                Subcategoria(id: idSubMantimentos, nome: "Mantimentos", icon: "cart.fill"),
                Subcategoria(id: idSubRestaurante, nome: "Restaurante", icon: "fork.knife.circle")
            ]
        ),
        Categoria(
            id: idHabitacao,
            nome: "Habitação",
            cor: .orange,
            icon: "house",
            subcategorias: [
                Subcategoria(id: idSubAluguel, nome: "Aluguel", icon: "house.fill"),
                Subcategoria(id: idSubArtigosLar, nome: "Artigos para o lar", icon: "sofa.fill"),
                Subcategoria(id: idSubAgua, nome: "Água", icon: "drop"),
                Subcategoria(id: idSubBanco, nome: "Banco", icon: "building.columns"),
                Subcategoria(id: idSubContas, nome: "Contas", icon: "doc.plaintext"),
                Subcategoria(id: idSubEletricidade, nome: "Eletricidade", icon: "bolt.fill"),
                Subcategoria(id: idSubFinanciamentoHab, nome: "Financiamento", icon: "creditcard"),
                Subcategoria(id: idSubHabitacaoGeral, nome: "Habitação", icon: "house.lodge.fill"),
                Subcategoria(id: idSubImpostos, nome: "Impostos", icon: "percent"),
                Subcategoria(id: idSubJardim, nome: "Jardim", icon: "leaf"),
                Subcategoria(id: idSubInternet, nome: "Internet", icon: "wifi"),
                Subcategoria(id: idSubManutencaoHab, nome: "Manutenção", icon: "wrench.and.screwdriver"),
                Subcategoria(id: idSubServico, nome: "Serviço", icon: "person.2.badge.gearshape.fill"),
                Subcategoria(id: idSubSeguroHab, nome: "Seguro", icon: "shield"),
                Subcategoria(id: idSubTelefone, nome: "Telefone", icon: "phone.fill"),
                Subcategoria(id: idSubTV, nome: "TV", icon: "tv.fill")
            ]
        ),
        Categoria(
            id: idTransporte,
            nome: "Transporte",
            cor: Color(red: 0.75, green: 0.35, blue: 0.98),
            icon: "car",
            subcategorias: [
                Subcategoria(id: idSubCarrosAplicativo, nome: "Carros de Aplicativo", icon: "car.2.fill"),
                Subcategoria(id: idSubCustosCarro, nome: "Custos do Carro", icon: "car.circle.fill"),
                Subcategoria(id: idSubEstacionamento, nome: "Estacionamento", icon: "parkingsign.circle.fill"),
                Subcategoria(id: idSubFinanciamentoTrans, nome: "Financiamento", icon: "creditcard"),
                Subcategoria(id: idSubGasolina, nome: "Gasolina", icon: "fuelpump.fill"),
                Subcategoria(id: idSubManutencaoTrans, nome: "Manutenção", icon: "car.badge.gearshape.fill"),
                Subcategoria(id: idSubSeguroCarro, nome: "Seguro do Carro", icon: "car.side.lock.fill"),
                Subcategoria(id: idSubTransportePublico, nome: "Transporte Público", icon: "bus"),
                Subcategoria(id: idSubTransporteGeral, nome: "Transporte", icon: "tram"),
                Subcategoria(id: idSubTaxi, nome: "Táxi", icon: "car.top.arrowtriangle.rear.left")
            ]
        ),
        Categoria(
            id: idEstiloDeVida,
            nome: "Estilo de Vida",
            cor: Color(red: 0.85, green: 0.33, blue: 0.31),
            icon: "figure.wave",
            subcategorias: [
                Subcategoria(id: idSubAnimalEstimacao, nome: "Animal Estimação", icon: "pawprint.fill"),
                Subcategoria(id: idSubCaridade, nome: "Caridade", icon: "hands.clap.fill"),
                Subcategoria(id: idSubCompras, nome: "Compras", icon: "bag.fill"),
                Subcategoria(id: idSubComunidade, nome: "Comunidade", icon: "person.3.fill"),
                Subcategoria(id: idSubCreche, nome: "Creche", icon: "figure.and.child.holdinghands"),
                Subcategoria(id: idSubDentista, nome: "Dentista", icon: "cross.case"),
                Subcategoria(id: idSubEscritorio, nome: "Escritório", icon: "folder.fill"),
                Subcategoria(id: idSubEducacao, nome: "Educação", icon: "book.closed.fill"),
                Subcategoria(id: idSubEstiloVidaGeral, nome: "Estilo de Vida", icon: "figure.dance"),
                Subcategoria(id: idSubFarmacia, nome: "Farmácia", icon: "pills.fill"),
                Subcategoria(id: idSubHotel, nome: "Hotel", icon: "bed.double.fill"),
                Subcategoria(id: idSubMedico, nome: "Médico", icon: "stethoscope.circle.fill"),
                Subcategoria(id: idSubPresente, nome: "Presente", icon: "gift.fill"),
                Subcategoria(id: idSubTrabalho, nome: "Trabalho", icon: "briefcase.fill"),
                Subcategoria(id: idSubViagem, nome: "Viagem", icon: "airplane")
            ]
        ),
        Categoria(
            id: idRenda,
            nome: "Renda",
            cor: Color(hue: 135/360, saturation: 0.8, brightness: 0.7),
            icon: "dollarsign",
            subcategorias: [
                Subcategoria(id: idSubInvestimentos, nome: "Investimentos", icon: "chart.line.uptrend.xyaxis"),
                Subcategoria(id: idSubJuros, nome: "Juros", icon: "percent"),
                Subcategoria(id: idSubPensao, nome: "Pensão", icon: "person.2.fill"),
                Subcategoria(id: idSubRendaGeral, nome: "Renda", icon: "arrow.down.to.line.circle.fill"),
                Subcategoria(id: idSubSalario, nome: "Salário", icon: "banknote"),
                Subcategoria(id: idSubSalarioFamilia, nome: "Salário Família", icon: "house.and.flag.fill")
            ]
        )
    ]

    // Funções auxiliares para buscar por ID
    static func categoria(for id: UUID) -> Categoria? {
        return todas.first(where: { $0.id == id })
    }

    static func subcategoria(for id: UUID) -> Subcategoria? {
        for categoria in todas {
            if let sub = categoria.subcategorias.first(where: { $0.id == id }) {
                return sub
            }
        }
        return nil
    }

    static func categoriasub(for subcategoriaID: UUID) -> Categoria? {
        for categoria in todas {
            if categoria.subcategorias.contains(where: { $0.id == subcategoriaID }) {
                return categoria
            }
        }
        return nil
    }
}
