//
//  ContentView.swift
//  InterviewPrep
//
//  Created on 2024
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = QuestionViewModel()
    @EnvironmentObject var languageManager: LanguageManager
    
    var localized: LocalizedStrings {
        LocalizedStrings(language: languageManager.currentLanguage)
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
                } else {
                    QuestionListView(viewModel: viewModel)
                }
            }
            .navigationTitle(localized.appTitle)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    LanguageToggleButton()
                }
            }
        }
    }
}

struct QuestionListView: View {
    @ObservedObject var viewModel: QuestionViewModel
    @EnvironmentObject var languageManager: LanguageManager
    @State private var showQuestionDetail = false
    @State private var translatingQuestions: Set<String> = []
    @State private var isTranslating = false
    
    var localized: LocalizedStrings {
        LocalizedStrings(language: languageManager.currentLanguage)
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Modern Category Selector
                CategorySelectorView(viewModel: viewModel)
                    .padding(.top, 8)
                
                // Question List with better styling
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(Array(viewModel.questions.enumerated()), id: \.element.id) { index, question in
                            QuestionRowView(
                                question: question,
                                index: index,
                                isCurrent: index == viewModel.currentQuestionIndex,
                                onTranslationStart: {
                                    translatingQuestions.insert(question.id)
                                    updateTranslatingState()
                                },
                                onTranslationComplete: {
                                    translatingQuestions.remove(question.id)
                                    updateTranslatingState()
                                }
                            )
                            .onTapGesture {
                                withAnimation(.spring(response: 0.3)) {
                                    viewModel.goToQuestion(at: index)
                                    showQuestionDetail = true
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
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
        .sheet(isPresented: $showQuestionDetail) {
            if let question = viewModel.currentQuestion {
                QuestionDetailView(question: question, viewModel: viewModel)
            }
        }
        .onChange(of: languageManager.currentLanguage) { _ in
            translatingQuestions.removeAll()
            updateTranslatingState()
        }
    }
    
    private func updateTranslatingState() {
        isTranslating = !translatingQuestions.isEmpty
    }
}

struct CategorySelectorView: View {
    @ObservedObject var viewModel: QuestionViewModel
    @EnvironmentObject var languageManager: LanguageManager
    
    var localized: LocalizedStrings {
        LocalizedStrings(language: languageManager.currentLanguage)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(QuestionCategory.allCases, id: \.self) { category in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        viewModel.switchCategory(category)
                    }
                }) {
                    VStack(spacing: 10) {
                        HStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(
                                        viewModel.currentCategory == category ?
                                        LinearGradient(
                                            colors: [Color.white.opacity(0.3), Color.white.opacity(0.2)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ) :
                                        LinearGradient(
                                            colors: [Color.blue.opacity(0.2), Color.purple.opacity(0.15)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 40, height: 40)
                                
                                Image(systemName: category == .lowLevelDesign ? "gearshape.fill" : "network")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(viewModel.currentCategory == category ? .white : .blue)
                            }
                            
                            Text(category.displayName)
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                        }
                        
                        Text("\(viewModel.questions.count) \(localized.questions)")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .opacity(0.9)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .padding(.horizontal, 16)
                    .background(
                        Group {
                            if viewModel.currentCategory == category {
                                LinearGradient(
                                    colors: [Color.blue, Color.purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            } else {
                                LinearGradient(
                                    colors: [Color.gray.opacity(0.12), Color.gray.opacity(0.08)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            }
                        }
                    )
                    .foregroundColor(viewModel.currentCategory == category ? .white : .primary)
                    .cornerRadius(18)
                    .shadow(
                        color: viewModel.currentCategory == category ? Color.blue.opacity(0.4) : Color.black.opacity(0.05),
                        radius: viewModel.currentCategory == category ? 10 : 4,
                        x: 0,
                        y: viewModel.currentCategory == category ? 5 : 2
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(
                                viewModel.currentCategory == category ?
                                LinearGradient(
                                    colors: [Color.white.opacity(0.3), Color.clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ) :
                                LinearGradient(
                                    colors: [Color.clear, Color.clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: viewModel.currentCategory == category ? 1.5 : 0
                            )
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 12)
    }
}

struct QuestionRowView: View {
    let question: Question
    let index: Int
    let isCurrent: Bool
    let onTranslationStart: () -> Void
    let onTranslationComplete: () -> Void
    @EnvironmentObject var languageManager: LanguageManager
    @State private var translatedTitle: String = ""
    
    private let translationService = TranslationService.shared
    
    var localized: LocalizedStrings {
        LocalizedStrings(language: languageManager.currentLanguage)
    }
    
    var displayTitle: String {
        if languageManager.currentLanguage != .turkish && !translatedTitle.isEmpty {
            return translatedTitle
        }
        return question.title
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Enhanced Question Number Badge
            ZStack {
                Circle()
                    .fill(
                        isCurrent ?
                        LinearGradient(
                            colors: [Color.blue, Color.purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            colors: [Color.gray.opacity(0.25), Color.gray.opacity(0.15)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                    .shadow(
                        color: isCurrent ? Color.blue.opacity(0.3) : Color.clear,
                        radius: isCurrent ? 6 : 0
                    )
                
                Text("\(index + 1)")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(isCurrent ? .white : .primary)
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text(displayTitle)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(isCurrent ? .blue : .primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                HStack(spacing: 8) {
                    Image(systemName: question.category.lowercased().contains("kolay") || question.category.lowercased().contains("easy") ? "star.fill" : question.category.lowercased().contains("orta") || question.category.lowercased().contains("medium") ? "star.lefthalf.fill" : "star.circle.fill")
                        .font(.caption2)
                    
                    Text(localized.difficulty(question.category))
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(
                                    question.category.lowercased().contains("kolay") || question.category.lowercased().contains("easy") ?
                                    LinearGradient(
                                        colors: [Color.green.opacity(0.25), Color.green.opacity(0.15)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ) :
                                    question.category.lowercased().contains("orta") || question.category.lowercased().contains("medium") ?
                                    LinearGradient(
                                        colors: [Color.orange.opacity(0.25), Color.orange.opacity(0.15)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ) :
                                    LinearGradient(
                                        colors: [Color.red.opacity(0.25), Color.red.opacity(0.15)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                        .foregroundColor(
                            question.category.lowercased().contains("kolay") || question.category.lowercased().contains("easy") ?
                            .green :
                            question.category.lowercased().contains("orta") || question.category.lowercased().contains("medium") ?
                            .orange :
                            .red
                        )
                }
            }
            
            Spacer()
            
            if isCurrent {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.blue.opacity(0.2), Color.purple.opacity(0.15)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.blue, Color.purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(
                    isCurrent ?
                    LinearGradient(
                        colors: [Color.blue.opacity(0.12), Color.purple.opacity(0.08)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ) :
                    LinearGradient(
                        colors: [Color(.systemBackground), Color(.systemBackground)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(
                    color: isCurrent ? Color.blue.opacity(0.25) : Color.black.opacity(0.08),
                    radius: isCurrent ? 12 : 6,
                    x: 0,
                    y: isCurrent ? 6 : 3
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(
                    isCurrent ?
                    LinearGradient(
                        colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ) :
                    LinearGradient(
                        colors: [Color.clear, Color.clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: isCurrent ? 2 : 0
                )
        )
        .onAppear {
            translateTitle()
        }
        .onChange(of: languageManager.currentLanguage) { _ in
            translateTitle()
        }
    }
    
    private func translateTitle() {
        guard languageManager.currentLanguage != .turkish else {
            translatedTitle = ""
            return
        }
        
        onTranslationStart()
        
        Task {
            let targetLanguage = languageManager.currentLanguage
            let translated = await translationService.translateFromTurkish(question.title, to: targetLanguage)
            
            await MainActor.run {
                translatedTitle = translated.isEmpty ? question.title : translated
                onTranslationComplete()
            }
        }
    }
}

struct LanguageToggleButton: View {
    @EnvironmentObject var languageManager: LanguageManager
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3)) {
                languageManager.toggleLanguage()
            }
        }) {
            HStack(spacing: 6) {
                Text(languageManager.currentLanguage.flag)
                    .font(.title3)
                Text(languageManager.currentLanguage.displayName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color.blue.opacity(0.15), Color.purple.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .foregroundColor(.primary)
        }
    }
}

struct ErrorView: View {
    let message: String
    let retryAction: () -> Void
    @EnvironmentObject var languageManager: LanguageManager
    
    var localized: LocalizedStrings {
        LocalizedStrings(language: languageManager.currentLanguage)
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.orange, Color.red],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text(message)
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Button(action: retryAction) {
                Text(localized.retry)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: [Color.blue, Color.purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .shadow(color: Color.blue.opacity(0.3), radius: 8)
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
        .environmentObject(LanguageManager())
}
