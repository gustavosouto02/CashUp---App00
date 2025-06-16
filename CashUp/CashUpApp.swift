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
            ZStack {
                if isShowingWelcomeScreen {
                    WelcomeView(isShowingWelcomeScreen: $isShowingWelcomeScreen)
                        .transition(.opacity.animation(.easeInOut(duration: 0.5)))
                } else {
                    HomeView(modelContext: sharedModelContainer.mainContext)
                        .transition(.opacity.animation(.easeInOut(duration: 0.5)))
                }
            }
            .preferredColorScheme(.dark)
        }
        .modelContainer(sharedModelContainer)
    }
}
