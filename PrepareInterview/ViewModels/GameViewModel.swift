//
//  GameViewModel.swift
//  InterviewPrep
//
//  Created on 2024
//

import Foundation
import SwiftUI

class GameViewModel: ObservableObject {
    @Published var questions: [GameQuestion] = []
    @Published var currentQuestion: GameQuestion?
    @Published var currentQuestionIndex: Int = 0
    @Published var score: Int = 0
    @Published var selectedAnswer: String?
    @Published var showResult: Bool = false
    @Published var isCorrect: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var gameStarted: Bool = false
    @Published var gameEnded: Bool = false
    
    private var shuffledQuestions: [GameQuestion] = []
    private let scoreManager = ScoreManager.shared
    
    func loadQuestions() {
        isLoading = true
        errorMessage = nil
        
        guard let url = Bundle.main.url(forResource: "general_questions", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let questions = try? JSONDecoder().decode([GameQuestion].self, from: data) else {
            errorMessage = "Sorular yüklenemedi"
            isLoading = false
            return
        }
        
        self.questions = questions
        isLoading = false
    }
    
    func startGame() {
        guard !questions.isEmpty else { return }
        
        shuffledQuestions = questions.shuffled()
        currentQuestionIndex = 0
        score = 0
        gameStarted = true
        gameEnded = false
        selectedAnswer = nil
        showResult = false
        
        if !shuffledQuestions.isEmpty {
            currentQuestion = shuffledQuestions[0]
        }
    }
    
    func selectAnswer(_ answer: String) {
        guard let question = currentQuestion, selectedAnswer == nil else { return }
        
        selectedAnswer = answer
        // Compare with original answer (not translated)
        isCorrect = answer == question.answer
        showResult = true
        
        if isCorrect {
            score += 10
        }
        
        // 3.5 saniye sonra bir sonraki soruya geç
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            self.nextQuestion()
        }
    }
    
    private func nextQuestion() {
        selectedAnswer = nil
        showResult = false
        
        if currentQuestionIndex < shuffledQuestions.count - 1 {
            currentQuestionIndex += 1
            currentQuestion = shuffledQuestions[currentQuestionIndex]
        } else {
            endGame()
        }
    }
    
    func endGame() {
        gameEnded = true
        gameStarted = false
        scoreManager.updateBestScore(score)
    }
    
    func resetGame() {
        gameStarted = false
        gameEnded = false
        currentQuestionIndex = 0
        score = 0
        selectedAnswer = nil
        showResult = false
        currentQuestion = nil
    }
    
    func getNextQuestion() -> GameQuestion? {
        let nextIndex = currentQuestionIndex + 1
        guard nextIndex < shuffledQuestions.count else {
            return nil
        }
        return shuffledQuestions[nextIndex]
    }
}

