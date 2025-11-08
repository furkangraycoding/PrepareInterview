//
//  MainMenuView.swift
//  InterviewPrep
//
//  Created on 2024
//

import SwiftUI

struct MainMenuView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @State private var selectedTab: MenuTab = .questions
    
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
                
                VStack(spacing: 0) {
                    // Content Area
                    Group {
                        if selectedTab == .questions {
                            QuestionsContentView()
                        } else {
                            NotesContentView()
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: selectedTab == .questions ? .leading : .trailing)))
                    
                    // Tab Bar at the bottom
                    HStack(spacing: 0) {
                        // Questions Tab
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedTab = .questions
                            }
                        }) {
                            VStack(spacing: 8) {
                                Image(systemName: selectedTab == .questions ? "questionmark.circle.fill" : "questionmark.circle")
                                    .font(.system(size: 24, weight: .semibold))
                                
                                Text(localized.questionsTab)
                                    .font(.system(size: 12, weight: selectedTab == .questions ? .bold : .medium, design: .rounded))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .foregroundColor(selectedTab == .questions ? .blue : .gray)
                            .background(
                                selectedTab == .questions ?
                                Color.blue.opacity(0.1) :
                                Color.clear
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Notes Tab
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedTab = .notes
                            }
                        }) {
                            VStack(spacing: 8) {
                                Image(systemName: selectedTab == .notes ? "book.fill" : "book")
                                    .font(.system(size: 24, weight: .semibold))
                                
                                Text(localized.notesTab)
                                    .font(.system(size: 12, weight: selectedTab == .notes ? .bold : .medium, design: .rounded))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .foregroundColor(selectedTab == .notes ? .green : .gray)
                            .background(
                                selectedTab == .notes ?
                                Color.green.opacity(0.1) :
                                Color.clear
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .background(
                        Color(.systemBackground)
                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -5)
                    )
                    .overlay(
                        Rectangle()
                            .frame(height: 0.5)
                            .foregroundColor(Color.gray.opacity(0.3)),
                        alignment: .top
                    )
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

enum MenuTab {
    case questions
    case notes
}

struct QuestionsContentView: View {
    @StateObject private var viewModel = QuestionViewModel()
    @EnvironmentObject var languageManager: LanguageManager
    
    var localized: LocalizedStrings {
        LocalizedStrings(language: languageManager.currentLanguage)
    }
    
    var body: some View {
        ZStack {
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
    }
}

struct NotesContentView: View {
    @EnvironmentObject var languageManager: LanguageManager
    
    var localized: LocalizedStrings {
        LocalizedStrings(language: languageManager.currentLanguage)
    }
    
    var body: some View {
        PDFViewerView()
    }
}

#Preview {
    MainMenuView()
        .environmentObject(LanguageManager())
}

