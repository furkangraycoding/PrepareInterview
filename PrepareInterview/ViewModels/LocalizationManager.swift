//
//  LocalizationManager.swift
//  InterviewPrep
//
//  Created on 2024
//

import Foundation

struct LocalizedStrings {
    let language: AppLanguage
    
    // Navigation & General
    var appTitle: String {
        language == .turkish ? "Mülakat Hazırlık" : "Interview Prep"
    }
    
    var questions: String {
        language == .turkish ? "soru" : "questions"
    }
    
    var question: String {
        language == .turkish ? "Soru:" : "Question:"
    }
    
    var answer: String {
        language == .turkish ? "Cevap:" : "Answer:"
    }
    
    var explanation: String {
        language == .turkish ? "Açıklama:" : "Explanation:"
    }
    
    var showAnswer: String {
        language == .turkish ? "Cevabı Göster" : "Show Answer"
    }
    
    var hideAnswer: String {
        language == .turkish ? "Cevabı Gizle" : "Hide Answer"
    }
    
    var previous: String {
        language == .turkish ? "Önceki" : "Previous"
    }
    
    var next: String {
        language == .turkish ? "Sonraki" : "Next"
    }
    
    var close: String {
        language == .turkish ? "Kapat" : "Close"
    }
    
    var retry: String {
        language == .turkish ? "Tekrar Dene" : "Retry"
    }
    
    var loading: String {
        language == .turkish ? "Yükleniyor..." : "Loading..."
    }
    
    var errorLoading: String {
        language == .turkish ? "JSON dosyası yüklenemedi" : "Failed to load JSON file"
    }
    
    // Categories
    var lowLevelDesign: String {
        language == .turkish ? "Low Level Design" : "Low Level Design"
    }
    
    var highLevelDesign: String {
        language == .turkish ? "High Level Design" : "High Level Design"
    }
    
    // Difficulty levels
    func difficulty(_ level: String) -> String {
        switch level.lowercased() {
        case "kolay", "easy":
            return language == .turkish ? "Kolay" : "Easy"
        case "orta", "medium":
            return language == .turkish ? "Orta" : "Medium"
        case "zor", "hard":
            return language == .turkish ? "Zor" : "Hard"
        default:
            return level
        }
    }
}

