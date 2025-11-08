//
//  ScoreManager.swift
//  InterviewPrep
//
//  Created on 2024
//

import Foundation

class ScoreManager: ObservableObject {
    static let shared = ScoreManager()
    
    private let bestScoreKey = "bestGameScore"
    
    @Published var bestScore: Int = 0
    
    private init() {
        loadBestScore()
    }
    
    func loadBestScore() {
        bestScore = UserDefaults.standard.integer(forKey: bestScoreKey)
    }
    
    func updateBestScore(_ score: Int) {
        if score > bestScore {
            bestScore = score
            UserDefaults.standard.set(score, forKey: bestScoreKey)
        }
    }
}

