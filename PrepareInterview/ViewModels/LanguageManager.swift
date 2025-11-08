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
    case spanish = "es"
    case french = "fr"
    case russian = "ru"
    case chinese = "zh"
    
    var displayName: String {
        switch self {
        case .turkish:
            return "Türkçe"
        case .english:
            return "English"
        case .spanish:
            return "Español"
        case .french:
            return "Français"
        case .russian:
            return "Русский"
        case .chinese:
            return "中文"
        }
    }
    
    var flag: String {
        switch self {
        case .turkish:
            return "🇹🇷"
        case .english:
            return "🇬🇧"
        case .spanish:
            return "🇪🇸"
        case .french:
            return "🇫🇷"
        case .russian:
            return "🇷🇺"
        case .chinese:
            return "🇨🇳"
        }
    }
    
    var googleTranslateCode: String {
        return self.rawValue
    }
}

class LanguageManager: ObservableObject {
    @Published var currentLanguage: AppLanguage = .turkish
    
    private let languageKey = "selectedLanguage"
    
    init() {
        loadSavedLanguage()
    }
    
    func setLanguage(_ language: AppLanguage) {
        currentLanguage = language
        saveLanguage()
    }
    
    func toggleLanguage() {
        currentLanguage = currentLanguage == .turkish ? .english : .turkish
        saveLanguage()
    }
    
    private func saveLanguage() {
        UserDefaults.standard.set(currentLanguage.rawValue, forKey: languageKey)
    }
    
    private func loadSavedLanguage() {
        if let savedLanguageRaw = UserDefaults.standard.string(forKey: languageKey),
           let savedLanguage = AppLanguage(rawValue: savedLanguageRaw) {
            currentLanguage = savedLanguage
        }
    }
}

