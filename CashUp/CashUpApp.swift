// Arquivo: CashUp/CashUpApp.swift
// Abordagem alternativa para .modelContainer e seeding

import SwiftUI
import SwiftData

@main
struct CashUpApp: App {
    let sharedModelContainer: ModelContainer
    @State private var isShowingWelcomeScreen: Bool = true

    init() {
        let schema = Schema([
            CategoriaModel.self,
            SubcategoriaModel.self,
            ExpenseModel.self,
            CategoriaPlanejadaModel.self,
            SubcategoriaPlanejadaModel.self
        ])
        
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            sharedModelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Não foi possível criar ModelContainer: \(error.localizedDescription)")
        }
    }

    var body: some Scene {
        WindowGroup {
            // ZStack para gerenciar a transição entre a WelcomeView e a HomeView
            ZStack {
                if isShowingWelcomeScreen {
                    WelcomeView(isShowingWelcomeScreen: $isShowingWelcomeScreen)
                        // Adiciona uma transição suave de opacidade
                        .transition(.opacity.animation(.easeInOut(duration: 0.5)))
                } else {
                    HomeView(modelContext: sharedModelContainer.mainContext)
                        // Adiciona uma transição suave de opacidade
                        .transition(.opacity.animation(.easeInOut(duration: 0.5)))
                }
            }
            .preferredColorScheme(.dark) // Aplica o esquema de cores ao contêiner principal
        }
        .modelContainer(sharedModelContainer)
    }
}
