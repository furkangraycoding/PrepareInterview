import SwiftUI

@main
struct PrepareInterviewApp: App {
    @StateObject private var languageManager = LanguageManager()
    
    var body: some Scene {
        WindowGroup {
            MainMenuView()
                .environmentObject(languageManager)
        }
    }
}


