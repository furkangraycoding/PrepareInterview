//
//  LanguageManager.swift
//  InterviewPrep
//
//  Created on 2024
//

import Foundation
import SwiftUI

enum AppLanguage: String, CaseIterable {
    case turkish = "tr"
    case english = "en"
    
    var displayName: String {
        switch self {
        case .turkish:
            return "Türkçe"
        case .english:
            return "English"
        }
    }
    
    var flag: String {
        switch self {
        case .turkish:
            return "🇹🇷"
        case .english:
            return "🇬🇧"
        }
    }
}

class LanguageManager: ObservableObject {
    @Published var currentLanguage: AppLanguage = .turkish
    
    func toggleLanguage() {
        currentLanguage = currentLanguage == .turkish ? .english : .turkish
    }
}

