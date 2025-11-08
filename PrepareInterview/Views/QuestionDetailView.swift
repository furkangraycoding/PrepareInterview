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
    // Title is always shown in original (already in English)
    var displayTitle: String {
        return question.title
    }
    
    var displayQuestion: String {
        if languageManager.currentLanguage == .english && !translatedQuestion.isEmpty {
            return translatedQuestion
        }
        return question.question
    }
    
    var displayAnswer: String {
        if languageManager.currentLanguage == .english && !translatedAnswer.isEmpty {
            return translatedAnswer
        }
        return question.answer
    }
    
    var displayExplanation: String {
        if languageManager.currentLanguage == .english && !translatedExplanation.isEmpty {
            return translatedExplanation
        }
        return question.explanation
    }
    
    var body: some View {
        NavigationView {
            ZStack {
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
                
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            // Progress Indicator
                            if viewModel.questions.count > 0 {
                                HStack {
                                    Text("\(viewModel.currentQuestionIndex + 1) / \(viewModel.questions.count)")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("\(Int(viewModel.progress * 100))%")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal)
                                .padding(.top, 8)
                                
                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(Color.gray.opacity(0.2))
                                            .frame(height: 6)
                                        
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(
                                                LinearGradient(
                                                    colors: [Color.blue, Color.purple],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                            .frame(width: geometry.size.width * viewModel.progress, height: 6)
                                    }
                                }
                                .frame(height: 6)
                                .padding(.horizontal)
                                .padding(.bottom, 16)
                            }
                            
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
                            
                            // Bottom padding for navigation buttons
                            Spacer()
                                .frame(height: 100)
                        }
                        .padding(.vertical)
                    }
                    
                    // Navigation Buttons - Enhanced Design
                    VStack(spacing: 0) {
                        Divider()
                            .background(Color.gray.opacity(0.3))
                        
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
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(
                            Color(.systemBackground)
                                .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: -5)
                        )
                    }
                    .blur(radius: isTranslating ? 8 : 0)
                    .disabled(isTranslating)
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
                
                ToolbarItem(placement: .navigationBarLeading) {
                    LanguageToggleButton()
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
        guard languageManager.currentLanguage == .english else {
            resetTranslations()
            return
        }
        
        isTranslating = true
        
        Task {
            // Don't translate title - it's already in English
            async let questionTask = translationService.translateToEnglish(question.question)
            async let answerTask = translationService.translateToEnglish(question.answer)
            async let explanationTask = translationService.translateToEnglish(question.explanation)
            
            let (questionText, answer, explanation) = await (questionTask, answerTask, explanationTask)
            
            await MainActor.run {
                // Keep title empty - we don't translate it
                translatedTitle = ""
                translatedQuestion = questionText
                translatedAnswer = answer
                translatedExplanation = explanation
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
