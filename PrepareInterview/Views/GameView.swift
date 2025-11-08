//
//  GameView.swift
//  InterviewPrep
//
//  Created on 2024
//

import SwiftUI

struct GameView: View {
    @StateObject private var viewModel = GameViewModel()
    @StateObject private var scoreManager = ScoreManager.shared
    @EnvironmentObject var languageManager: LanguageManager
    
    var localized: LocalizedStrings {
        LocalizedStrings(language: languageManager.currentLanguage)
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Enhanced Gradient Background
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.12),
                    Color.purple.opacity(0.08),
                    Color.pink.opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            if viewModel.isLoading {
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text(localized.loading)
                        .foregroundColor(.secondary)
                }
            } else if let error = viewModel.errorMessage {
                ErrorView(message: error) {
                    viewModel.loadQuestions()
                }
            } else if viewModel.gameEnded {
                GameEndView(
                    score: viewModel.score,
                    bestScore: scoreManager.bestScore,
                    onPlayAgain: {
                        viewModel.resetGame()
                    }
                )
            } else if !viewModel.gameStarted {
                GameStartView(
                    bestScore: scoreManager.bestScore,
                    onStart: {
                        viewModel.startGame()
                    }
                )
            } else {
                GamePlayView(viewModel: viewModel)
            }
        }
        .onAppear {
            if viewModel.questions.isEmpty {
                viewModel.loadQuestions()
            }
        }
    }
}

struct GameStartView: View {
    let bestScore: Int
    let onStart: () -> Void
    @EnvironmentObject var languageManager: LanguageManager
    
    var localized: LocalizedStrings {
        LocalizedStrings(language: languageManager.currentLanguage)
    }
    
    var body: some View {
        VStack(spacing: 32) {
            // Game Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                
                Image(systemName: "gamecontroller.fill")
                    .font(.system(size: 60, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.blue, Color.purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            VStack(spacing: 16) {
                Text(localized.gameTitle)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.blue, Color.purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Text(localized.gameDescription)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            // Best Score
            if bestScore > 0 {
                HStack(spacing: 12) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.yellow)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(localized.bestScore)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.secondary)
                        
                        Text("\(bestScore) \(localized.points)")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.primary)
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                )
            }
            
            // Start Button
            Button(action: onStart) {
                HStack(spacing: 12) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 20, weight: .bold))
                    Text(localized.startGame)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(
                    LinearGradient(
                        colors: [Color.blue, Color.purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(20)
                .shadow(color: Color.blue.opacity(0.4), radius: 15, x: 0, y: 8)
            }
            .padding(.horizontal, 40)
            .padding(.top, 20)
        }
        .padding(32)
    }
}

struct GamePlayView: View {
    @ObservedObject var viewModel: GameViewModel
    @EnvironmentObject var languageManager: LanguageManager
    @State private var translatedQuestion: GameQuestion?
    @State private var nextTranslatedQuestion: GameQuestion?
    @State private var isTranslating = false
    
    private let translationService = TranslationService.shared
    
    var localized: LocalizedStrings {
        LocalizedStrings(language: languageManager.currentLanguage)
    }
    
    var displayQuestion: GameQuestion? {
        if let question = viewModel.currentQuestion {
            if languageManager.currentLanguage != .turkish, let translated = translatedQuestion {
                return translated
            }
            return question
        }
        return nil
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Score and Progress Header
                VStack(spacing: 16) {
                    HStack {
                        // Score
                        HStack(spacing: 8) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.yellow)
                            Text("\(viewModel.score)")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            Text(localized.points)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        // Progress
                        HStack(spacing: 8) {
                            Text("\(viewModel.currentQuestionIndex + 1) / \(viewModel.questions.count)")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    
                    // Progress Bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 10)
                            
                            RoundedRectangle(cornerRadius: 8)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.blue, Color.purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * CGFloat(viewModel.currentQuestionIndex + 1) / CGFloat(viewModel.questions.count), height: 10)
                        }
                    }
                    .frame(height: 10)
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 24)
                .background(
                    Color(.systemBackground)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                )
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Question Card
                        if let question = displayQuestion {
                            VStack(alignment: .leading, spacing: 20) {
                                // Topic Badge
                                HStack {
                                    Text(question.topic)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(
                                            Capsule()
                                                .fill(
                                                    LinearGradient(
                                                        colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.7)],
                                                        startPoint: .leading,
                                                        endPoint: .trailing
                                                    )
                                                )
                                        )
                                    
                                    Spacer()
                                }
                                
                                // Question Text
                                Text(question.question)
                                    .font(.system(size: 22, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)
                                    .lineSpacing(6)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(28)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 8)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(
                                        LinearGradient(
                                            colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.2)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1.5
                                    )
                            )
                            .padding(.horizontal, 20)
                            .padding(.top, 24)
                            
                            // Answer Options
                            VStack(spacing: 16) {
                                if let originalQuestion = viewModel.currentQuestion {
                                    ForEach(Array(question.options.enumerated()), id: \.offset) { index, translatedOption in
                                        let originalOption = index < originalQuestion.options.count ? originalQuestion.options[index] : translatedOption
                                        
                                        AnswerButton(
                                            text: translatedOption,
                                            isSelected: viewModel.selectedAnswer == originalOption,
                                            isCorrect: originalOption == originalQuestion.answer,
                                            showResult: viewModel.showResult,
                                            onTap: {
                                                viewModel.selectAnswer(originalOption)
                                            }
                                        )
                                    }
                                } else {
                                    ForEach(question.options, id: \.self) { option in
                                        AnswerButton(
                                            text: option,
                                            isSelected: viewModel.selectedAnswer == option,
                                            isCorrect: option == question.answer,
                                            showResult: viewModel.showResult,
                                            onTap: {
                                                viewModel.selectAnswer(option)
                                            }
                                        )
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
                        }
                    }
                    .padding(.bottom, 40)
                }
                .blur(radius: isTranslating ? 8 : 0)
                .disabled(isTranslating)
            }
            
            // Translation Loading Overlay
            if isTranslating {
                ZStack {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 24) {
                        ZStack {
                            Circle()
                                .fill(Color(.systemBackground))
                                .frame(width: 100, height: 100)
                                .shadow(color: Color.black.opacity(0.3), radius: 25, x: 0, y: 10)
                            
                            ProgressView()
                                .scaleEffect(1.8)
                                .tint(.blue)
                        }
                        
                        Text("Translating...")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .padding(.horizontal, 28)
                            .padding(.vertical, 14)
                            .background(
                                Capsule()
                                    .fill(Color(.systemBackground))
                                    .shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: 5)
                            )
                    }
                }
                .transition(.opacity)
                .zIndex(1000)
            }
        }
        .onChange(of: viewModel.showResult) { showResult in
            // When answer is shown, start preloading next question
            if showResult {
                preloadNextQuestion()
            }
        }
        .onChange(of: viewModel.currentQuestion) { _ in
            // Use preloaded translation if available
            if let preloaded = nextTranslatedQuestion {
                translatedQuestion = preloaded
                nextTranslatedQuestion = nil
                isTranslating = false
            } else {
                translateQuestion()
            }
            // Preload next question
            preloadNextQuestion()
        }
        .onChange(of: languageManager.currentLanguage) { _ in
            translateQuestion()
            preloadNextQuestion()
        }
        .onAppear {
            translateQuestion()
            preloadNextQuestion()
        }
    }
    
    private func translateQuestion() {
        guard let question = viewModel.currentQuestion else {
            translatedQuestion = nil
            return
        }
        
        guard languageManager.currentLanguage != .turkish else {
            translatedQuestion = nil
            isTranslating = false
            return
        }
        
        // Check if we already have a translation for this exact question
        let targetLanguage = languageManager.currentLanguage
        let normalizedQuestion = question.question.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check if we already translated this question (avoid retranslating)
        if let existing = translatedQuestion, existing.question == normalizedQuestion {
            return
        }
        
        isTranslating = true
        
        Task {
            // Translate question, topic, options, and answer
            // TranslationService already handles caching internally
            async let questionTask = translationService.translateFromTurkish(question.question, to: targetLanguage)
            async let topicTask = translationService.translateFromTurkish(question.topic, to: targetLanguage)
            async let optionsTask = translateArray(question.options, to: targetLanguage)
            async let answerTask = translationService.translateFromTurkish(question.answer, to: targetLanguage)
            
            let (translatedQuestionText, translatedTopic, translatedOptions, translatedAnswer) = await (questionTask, topicTask, optionsTask, answerTask)
            
            await MainActor.run {
                // Create translated question
                translatedQuestion = GameQuestion(
                    topic: translatedTopic.isEmpty ? question.topic : translatedTopic,
                    question: translatedQuestionText.isEmpty ? question.question : translatedQuestionText,
                    options: translatedOptions.isEmpty ? question.options : translatedOptions,
                    answer: translatedAnswer.isEmpty ? question.answer : translatedAnswer
                )
                
                isTranslating = false
            }
        }
    }
    
    private func preloadNextQuestion() {
        guard let nextQuestion = viewModel.getNextQuestion() else {
            nextTranslatedQuestion = nil
            return
        }
        
        guard languageManager.currentLanguage != .turkish else {
            nextTranslatedQuestion = nil
            return
        }
        
        // Check if already preloaded
        if let existing = nextTranslatedQuestion, existing.question == nextQuestion.question {
            return
        }
        
        // Preload translation in background
        Task {
            let targetLanguage = languageManager.currentLanguage
            
            // Translate question, topic, options, and answer
            async let questionTask = translationService.translateFromTurkish(nextQuestion.question, to: targetLanguage)
            async let topicTask = translationService.translateFromTurkish(nextQuestion.topic, to: targetLanguage)
            async let optionsTask = translateArray(nextQuestion.options, to: targetLanguage)
            async let answerTask = translationService.translateFromTurkish(nextQuestion.answer, to: targetLanguage)
            
            let (translatedQuestionText, translatedTopic, translatedOptions, translatedAnswer) = await (questionTask, topicTask, optionsTask, answerTask)
            
            await MainActor.run {
                // Create translated question
                nextTranslatedQuestion = GameQuestion(
                    topic: translatedTopic.isEmpty ? nextQuestion.topic : translatedTopic,
                    question: translatedQuestionText.isEmpty ? nextQuestion.question : translatedQuestionText,
                    options: translatedOptions.isEmpty ? nextQuestion.options : translatedOptions,
                    answer: translatedAnswer.isEmpty ? nextQuestion.answer : translatedAnswer
                )
            }
        }
    }
    
    private func translateArray(_ items: [String], to targetLanguage: AppLanguage) async -> [String] {
        var translatedItems: [String] = []
        for item in items {
            let translated = await translationService.translateFromTurkish(item, to: targetLanguage)
            translatedItems.append(translated.isEmpty ? item : translated)
        }
        return translatedItems
    }
}

struct AnswerButton: View {
    let text: String
    let isSelected: Bool
    let isCorrect: Bool
    let showResult: Bool
    let onTap: () -> Void
    
    private var textColor: Color {
        if showResult && (isCorrect || (isSelected && !isCorrect)) {
            return .white
        }
        return .primary
    }
    
    private var shouldShowResult: Bool {
        showResult && (isCorrect || (isSelected && !isCorrect))
    }
    
    private var backgroundGradient: LinearGradient {
        if shouldShowResult {
            if isCorrect {
                return LinearGradient(
                    colors: [Color.green.opacity(0.9), Color.green.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            } else {
                return LinearGradient(
                    colors: [Color.red.opacity(0.9), Color.red.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            }
        } else {
            return LinearGradient(
                colors: [Color.gray.opacity(0.1), Color.gray.opacity(0.05)],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }
    
    private var borderColor: Color {
        if shouldShowResult {
            return isCorrect ? Color.green.opacity(0.5) : Color.red.opacity(0.5)
        }
        return Color.gray.opacity(0.2)
    }
    
    private var borderWidth: CGFloat {
        shouldShowResult ? 2 : 1
    }
    
    private var shadowColor: Color {
        if shouldShowResult {
            return isCorrect ? Color.green.opacity(0.4) : Color.red.opacity(0.4)
        }
        return Color.clear
    }
    
    private var shadowRadius: CGFloat {
        showResult ? 10 : 0
    }
    
    private var shadowY: CGFloat {
        showResult ? 5 : 0
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Icon
                if showResult {
                    if isCorrect {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                    } else if isSelected && !isCorrect {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                
                // Text
                Text(text)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(textColor)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer()
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(backgroundGradient)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
            .shadow(
                color: shadowColor,
                radius: shadowRadius,
                x: 0,
                y: shadowY
            )
        }
        .allowsHitTesting(!showResult) // Disable interaction but keep full opacity
        .buttonStyle(PlainButtonStyle())
    }
}

struct GameEndView: View {
    let score: Int
    let bestScore: Int
    let onPlayAgain: () -> Void
    @EnvironmentObject var languageManager: LanguageManager
    
    var localized: LocalizedStrings {
        LocalizedStrings(language: languageManager.currentLanguage)
    }
    
    var isNewRecord: Bool {
        score >= bestScore && score > 0
    }
    
    var body: some View {
        VStack(spacing: 32) {
            // Trophy Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: isNewRecord ?
                            [Color.yellow.opacity(0.3), Color.orange.opacity(0.2)] :
                            [Color.blue.opacity(0.3), Color.purple.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 140, height: 140)
                
                Image(systemName: isNewRecord ? "trophy.fill" : "checkmark.circle.fill")
                    .font(.system(size: 70, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: isNewRecord ?
                            [Color.yellow, Color.orange] :
                            [Color.blue, Color.purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            VStack(spacing: 16) {
                if isNewRecord {
                    Text(localized.newRecord)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.yellow)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(Color.yellow.opacity(0.2))
                        )
                }
                
                Text(localized.gameOver)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.blue, Color.purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                // Score Display
                VStack(spacing: 12) {
                    Text(localized.yourScore)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.secondary)
                    
                    Text("\(score)")
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.blue, Color.purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text(localized.points)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.secondary)
                }
                .padding(32)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(.systemBackground))
                        .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 8)
                )
                
                // Best Score
                if bestScore > 0 {
                    HStack(spacing: 12) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.yellow)
                        
                        Text("\(localized.bestScore): \(bestScore) \(localized.points)")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.gray.opacity(0.1))
                    )
                }
            }
            
            // Play Again Button
            Button(action: onPlayAgain) {
                HStack(spacing: 12) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 20, weight: .bold))
                    Text(localized.playAgain)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(
                    LinearGradient(
                        colors: [Color.blue, Color.purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(20)
                .shadow(color: Color.blue.opacity(0.4), radius: 15, x: 0, y: 8)
            }
            .padding(.horizontal, 40)
        }
        .padding(32)
    }
}

#Preview {
    GameView()
        .environmentObject(LanguageManager())
}

