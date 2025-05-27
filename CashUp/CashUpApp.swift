// Arquivo: CashUp/CashUpApp.swift
// Abordagem alternativa para .modelContainer e seeding

import SwiftUI
import SwiftData

@main
struct CashUpApp: App {
    let sharedModelContainer: ModelContainer

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
            // HomeView recebe o modelContext em seu init.
            // A lógica de popular dados será movida para o .onAppear da HomeView.
            HomeView(modelContext: sharedModelContainer.mainContext)
                .preferredColorScheme(.dark)
        }
        // Usa a forma mais simples do .modelContainer quando já temos a instância.
        .modelContainer(sharedModelContainer)
    }
}
