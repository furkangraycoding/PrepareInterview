//
//  QuestionDetailView.swift
//  InterviewPrep
//
//  Created on 2024
//

import SwiftUI

struct QuestionDetailView: View {
    let question: Question
    @ObservedObject var viewModel: QuestionViewModel
    @EnvironmentObject var languageManager: LanguageManager
    @Environment(\.dismiss) var dismiss
    @State private var translatedTitle: String = ""
    @State private var translatedQuestion: String = ""
    @State private var translatedAnswer: String = ""
    @State private var translatedExplanation: String = ""
    @State private var isTranslating = false
    
    private let translationService = TranslationService.shared
    
    var localized: LocalizedStrings {
        LocalizedStrings(language: languageManager.currentLanguage)
    }
    
    // Get display text based on current language
    var displayTitle: String {
        if languageManager.currentLanguage != .turkish && !translatedTitle.isEmpty {
            return translatedTitle
        }
        return question.title
    }
    
    var displayQuestion: String {
        if languageManager.currentLanguage != .turkish && !translatedQuestion.isEmpty {
            return translatedQuestion
        }
        return question.question
    }
    
    var displayAnswer: String {
        if languageManager.currentLanguage != .turkish && !translatedAnswer.isEmpty {
            return translatedAnswer
        }
        return question.answer
    }
    
    var displayExplanation: String {
        if languageManager.currentLanguage != .turkish && !translatedExplanation.isEmpty {
            return translatedExplanation
        }
        return question.explanation
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .topTrailing) {
                // Enhanced Gradient Background
                LinearGradient(
                    colors: [
                        Color.blue.opacity(0.15),
                        Color.purple.opacity(0.1),
                        Color.pink.opacity(0.05)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Language Selector Button - Fixed at top right
                LanguageSelectorButton()
                    .padding(.top, 8)
                    .padding(.trailing, 16)
                    .zIndex(1000)
                
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            // Category Badge - Enhanced Design
                            HStack {
                                ZStack {
                                    Capsule()
                                        .fill(
                                            question.category.lowercased().contains("kolay") || question.category.lowercased().contains("easy") ?
                                            LinearGradient(
                                                colors: [Color.green.opacity(0.4), Color.green.opacity(0.3)],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            ) :
                                            question.category.lowercased().contains("orta") || question.category.lowercased().contains("medium") ?
                                            LinearGradient(
                                                colors: [Color.orange.opacity(0.4), Color.orange.opacity(0.3)],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            ) :
                                            LinearGradient(
                                                colors: [Color.red.opacity(0.4), Color.red.opacity(0.3)],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(height: 32)
                                    
                                    HStack(spacing: 6) {
                                        Image(systemName: question.category.lowercased().contains("kolay") || question.category.lowercased().contains("easy") ? "star.fill" : question.category.lowercased().contains("orta") || question.category.lowercased().contains("medium") ? "star.lefthalf.fill" : "star.circle.fill")
                                            .font(.caption)
                                        Text(localized.difficulty(question.category))
                                            .font(.subheadline)
                                            .fontWeight(.bold)
                                    }
                                    .foregroundColor(
                                        question.category.lowercased().contains("kolay") || question.category.lowercased().contains("easy") ?
                                        .green :
                                        question.category.lowercased().contains("orta") || question.category.lowercased().contains("medium") ?
                                        .orange :
                                        .red
                                    )
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                }
                                
                                Spacer()
                                
                                if isTranslating {
                                    HStack(spacing: 6) {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                        Text("Translating...")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            
                            // Title - Enhanced
                            Text(displayTitle)
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color.primary, Color.blue],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .padding(.horizontal)
                                .lineSpacing(4)
                            
                            Divider()
                                .padding(.horizontal)
                                .background(Color.gray.opacity(0.3))
                            
                            // Question Card - Enhanced Design
                            VStack(alignment: .leading, spacing: 16) {
                                HStack(spacing: 12) {
                                    ZStack {
                                        Circle()
                                            .fill(
                                                LinearGradient(
                                                    colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.2)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .frame(width: 44, height: 44)
                                        
                                        Image(systemName: "questionmark.circle.fill")
                                            .font(.title3)
                                            .foregroundColor(.blue)
                                    }
                                    
                                    Text(localized.question)
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                }
                                
                                Text(displayQuestion)
                                    .font(.body)
                                    .lineSpacing(8)
                                    .foregroundColor(.primary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(24)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: Color.blue.opacity(0.15), radius: 15, x: 0, y: 5)
                            )
                            .padding(.horizontal)
                            
                            // Answer Section - Always Visible
                            VStack(alignment: .leading, spacing: 20) {
                                    HStack(spacing: 12) {
                                        ZStack {
                                            Circle()
                                                .fill(
                                                    LinearGradient(
                                                        colors: [Color.green.opacity(0.3), Color.green.opacity(0.2)],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                                .frame(width: 44, height: 44)
                                            
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.title3)
                                                .foregroundColor(.green)
                                        }
                                        
                                        Text(localized.answer)
                                            .font(.title3)
                                            .fontWeight(.bold)
                                            .foregroundColor(.primary)
                                        
                                        Spacer()
                                    }
                                    
                                    Text(displayAnswer)
                                        .font(.body)
                                        .lineSpacing(8)
                                        .foregroundColor(.primary)
                                        .fixedSize(horizontal: false, vertical: true)
                                    
                                    Divider()
                                        .background(Color.gray.opacity(0.3))
                                        .padding(.vertical, 8)
                                    
                                    HStack(spacing: 12) {
                                        ZStack {
                                            Circle()
                                                .fill(
                                                    LinearGradient(
                                                        colors: [Color.orange.opacity(0.3), Color.orange.opacity(0.2)],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                                .frame(width: 44, height: 44)
                                            
                                            Image(systemName: "lightbulb.fill")
                                                .font(.title3)
                                                .foregroundColor(.orange)
                                        }
                                        
                                        Text(localized.explanation)
                                            .font(.title3)
                                            .fontWeight(.bold)
                                            .foregroundColor(.primary)
                                        
                                        Spacer()
                                    }
                                    
                                    Text(displayExplanation)
                                        .font(.body)
                                        .lineSpacing(8)
                                        .foregroundColor(.secondary)
                                        .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(24)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.green.opacity(0.12), Color.blue.opacity(0.08)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .shadow(color: Color.green.opacity(0.2), radius: 15, x: 0, y: 5)
                            )
                            .padding(.horizontal)
                            
                            // Navigation Buttons - Inside Question Content
                            HStack(spacing: 16) {
                                // Previous Button
                                Button(action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        viewModel.previousQuestion()
                                        resetTranslations()
                                        translateContent()
                                    }
                                }) {
                                    HStack(spacing: 10) {
                                        Image(systemName: "chevron.left")
                                            .font(.headline)
                                        Text(localized.previous)
                                            .fontWeight(.bold)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 18)
                                    .background(
                                        Group {
                                            if viewModel.canGoPrevious {
                                                LinearGradient(
                                                    colors: [Color.blue.opacity(0.9), Color.purple.opacity(0.8)],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            } else {
                                                LinearGradient(
                                                    colors: [Color.gray.opacity(0.2), Color.gray.opacity(0.15)],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            }
                                        }
                                    )
                                    .foregroundColor(viewModel.canGoPrevious ? .white : .gray)
                                    .cornerRadius(16)
                                    .shadow(
                                        color: viewModel.canGoPrevious ? Color.blue.opacity(0.3) : Color.clear,
                                        radius: viewModel.canGoPrevious ? 8 : 0,
                                        x: 0,
                                        y: viewModel.canGoPrevious ? 4 : 0
                                    )
                                }
                                .disabled(!viewModel.canGoPrevious)
                                
                                // Next Button
                                Button(action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        viewModel.nextQuestion()
                                        resetTranslations()
                                        translateContent()
                                    }
                                }) {
                                    HStack(spacing: 10) {
                                        Text(localized.next)
                                            .fontWeight(.bold)
                                        Image(systemName: "chevron.right")
                                            .font(.headline)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 18)
                                    .background(
                                        Group {
                                            if viewModel.canGoNext {
                                                LinearGradient(
                                                    colors: [Color.blue.opacity(0.9), Color.purple.opacity(0.8)],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            } else {
                                                LinearGradient(
                                                    colors: [Color.gray.opacity(0.2), Color.gray.opacity(0.15)],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            }
                                        }
                                    )
                                    .foregroundColor(viewModel.canGoNext ? .white : .gray)
                                    .cornerRadius(16)
                                    .shadow(
                                        color: viewModel.canGoNext ? Color.blue.opacity(0.3) : Color.clear,
                                        radius: viewModel.canGoNext ? 8 : 0,
                                        x: 0,
                                        y: viewModel.canGoNext ? 4 : 0
                                    )
                                }
                                .disabled(!viewModel.canGoNext)
                            }
                            .padding(.horizontal)
                            .padding(.top, 24)
                            .blur(radius: isTranslating ? 8 : 0)
                            .disabled(isTranslating)
                            
                            // Bottom padding
                            Spacer()
                                .frame(height: 40)
                        }
                        .padding(.vertical)
                    }
                }
                
                // Translation Loading Overlay
                if isTranslating {
                    ZStack {
                        // Semi-transparent overlay
                        Color.black.opacity(0.5)
                            .ignoresSafeArea()
                        
                        // Spinner with background
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
            .navigationTitle(question.id)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(localized.close) {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                }
            }
            .onAppear {
                translateContent()
            }
            .onChange(of: languageManager.currentLanguage) { _ in
                translateContent()
            }
            .onChange(of: viewModel.currentQuestionIndex) { _ in
                resetTranslations()
                translateContent()
            }
        }
    }
    
    private func translateContent() {
        guard languageManager.currentLanguage != .turkish else {
            resetTranslations()
            isTranslating = false
            return
        }
        
        // Reset all translations
        resetTranslations()
        isTranslating = true
        
        Task {
            let targetLanguage = languageManager.currentLanguage
            // Translate title, question, answer, and explanation
            async let titleTask = translationService.translateFromTurkish(question.title, to: targetLanguage)
            async let questionTask = translationService.translateFromTurkish(question.question, to: targetLanguage)
            async let answerTask = translationService.translateFromTurkish(question.answer, to: targetLanguage)
            async let explanationTask = translationService.translateFromTurkish(question.explanation, to: targetLanguage)
            
            let (title, questionText, answer, explanation) = await (titleTask, questionTask, answerTask, explanationTask)
            
            await MainActor.run {
                // Only set translations if they're not empty and different from original
                translatedTitle = (title.isEmpty || title == question.title) ? question.title : title
                translatedQuestion = (questionText.isEmpty || questionText == question.question) ? question.question : questionText
                translatedAnswer = (answer.isEmpty || answer == question.answer) ? question.answer : answer
                translatedExplanation = (explanation.isEmpty || explanation == question.explanation) ? question.explanation : explanation
                
                // Only hide spinner when all translations are complete
                isTranslating = false
            }
        }
    }
    
    private func resetTranslations() {
        translatedTitle = ""
        translatedQuestion = ""
        translatedAnswer = ""
        translatedExplanation = ""
    }
}

#Preview {
    let viewModel = QuestionViewModel()
    return QuestionDetailView(
        question: Question(
            id: "LLD-1",
            category: "Kolay",
            title: "Polymorphism ve Overriding",
            question: "Java'da *polymorphism*'in (çok biçimlilik) temel prensibini ve bir metot *overriding* (geçersiz kılma) örneğini açıklayınız.",
            answer: "Sınıflar arasında üst sınıf referansı ile alt sınıf nesnesini çalıştırma yeteneğidir.",
            explanation: "Çalışma zamanında (runtime) hangi metotun çağrılacağını belirler. Anahtar kelime 'extends' (veya 'implements') ve metot imzalarının (isim ve parametreler) birebir aynı olması gerekir. Bu, kodun esnekliğini artırır."
        ),
        viewModel: viewModel
    )
    .environmentObject(LanguageManager())
}
