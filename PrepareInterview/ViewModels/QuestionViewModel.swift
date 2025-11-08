//
//  QuestionViewModel.swift
//  InterviewPrep
//
//  Created on 2024
//

import Foundation
import SwiftUI

class QuestionViewModel: ObservableObject {
    @Published var questions: [Question] = []
    @Published var currentCategory: QuestionCategory = .lowLevelDesign
    @Published var currentQuestionIndex: Int = 0
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let questionsPerCategory = 50
    
    var currentQuestion: Question? {
        guard currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }
    
    var progress: Double {
        guard !questions.isEmpty else { return 0 }
        return Double(currentQuestionIndex + 1) / Double(questions.count)
    }
    
    var canGoNext: Bool {
        currentQuestionIndex < questions.count - 1
    }
    
    var canGoPrevious: Bool {
        currentQuestionIndex > 0
    }
    
    init() {
        loadQuestions()
    }
    
    func loadQuestions() {
        isLoading = true
        errorMessage = nil
        
        guard let url = Bundle.main.url(forResource: "questions", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let questionData = try? JSONDecoder().decode(QuestionData.self, from: data) else {
            errorMessage = "JSON dosyası yüklenemedi"
            isLoading = false
            return
        }
        
        questions = questionData.lowLevelDesign
        currentCategory = .lowLevelDesign
        currentQuestionIndex = 0
        isLoading = false
    }
    
    private var cachedQuestionData: QuestionData?
    
    private func loadQuestionData() -> QuestionData? {
        if let cached = cachedQuestionData {
            return cached
        }
        
        guard let url = Bundle.main.url(forResource: "questions", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let questionData = try? JSONDecoder().decode(QuestionData.self, from: data) else {
            return nil
        }
        
        cachedQuestionData = questionData
        return questionData
    }
    
    func nextQuestion() {
        // Normal ilerleme - otomatik geçiş yok, kullanıcı menüden seçer
        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1
        }
    }
    
    func previousQuestion() {
        if currentQuestionIndex > 0 {
            currentQuestionIndex -= 1
        }
    }
    
    func goToQuestion(at index: Int) {
        guard index >= 0 && index < questions.count else { return }
        currentQuestionIndex = index
    }
    
    func switchCategory(_ category: QuestionCategory) {
        guard let questionData = loadQuestionData() else {
            return
        }
        
        switch category {
        case .lowLevelDesign:
            questions = questionData.lowLevelDesign
        case .highLevelDesign:
            questions = questionData.highLevelDesign
        }
        
        currentCategory = category
        currentQuestionIndex = 0
    }
}

