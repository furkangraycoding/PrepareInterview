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
    
    var localized: LocalizedStrings {
        LocalizedStrings(language: languageManager.currentLanguage)
    }
    
    var body: some View {
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
                            isCurrent: index == viewModel.currentQuestionIndex
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
            
            // Modern Navigation Buttons
            if let currentQuestion = viewModel.currentQuestion {
                NavigationButtonsView(
                    viewModel: viewModel,
                    currentQuestion: currentQuestion
                )
            }
        }
        .sheet(isPresented: $showQuestionDetail) {
            if let question = viewModel.currentQuestion {
                QuestionDetailView(question: question, viewModel: viewModel)
            }
        }
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
    @EnvironmentObject var languageManager: LanguageManager
    
    var localized: LocalizedStrings {
        LocalizedStrings(language: languageManager.currentLanguage)
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
                Text(question.title)
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
    }
}

struct NavigationButtonsView: View {
    @ObservedObject var viewModel: QuestionViewModel
    let currentQuestion: Question
    @EnvironmentObject var languageManager: LanguageManager
    
    var localized: LocalizedStrings {
        LocalizedStrings(language: languageManager.currentLanguage)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
                .background(Color.gray.opacity(0.3))
            
            VStack(spacing: 16) {
                // Enhanced Progress Bar with Info
                VStack(spacing: 10) {
                    HStack {
                        HStack(spacing: 6) {
                            Image(systemName: "list.number")
                                .font(.caption2)
                            Text("\(viewModel.currentQuestionIndex + 1) / \(viewModel.questions.count)")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        HStack(spacing: 6) {
                            Image(systemName: "chart.bar.fill")
                                .font(.caption2)
                            Text("\(Int(viewModel.progress * 100))%")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 8)
                            
                            RoundedRectangle(cornerRadius: 6)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.blue, Color.purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * viewModel.progress, height: 8)
                                .shadow(color: Color.blue.opacity(0.3), radius: 4, x: 0, y: 2)
                        }
                    }
                    .frame(height: 8)
                    .padding(.horizontal)
                }
                .padding(.top, 16)
                
                // Enhanced Navigation Buttons
                HStack(spacing: 14) {
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            viewModel.previousQuestion()
                        }
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .bold))
                            Text(localized.previous)
                                .font(.system(size: 16, weight: .bold, design: .rounded))
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
                    
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            viewModel.nextQuestion()
                        }
                    }) {
                        HStack(spacing: 10) {
                            Text(localized.next)
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                            Image(systemName: "chevron.right")
                                .font(.system(size: 16, weight: .bold))
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
                .padding(.bottom, 16)
            }
        }
        .background(
            Color(.systemBackground)
                .shadow(color: Color.black.opacity(0.12), radius: 20, x: 0, y: -5)
        )
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
