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
    @State private var isTabBarVisible: Bool = true
    
    var localized: LocalizedStrings {
        LocalizedStrings(language: languageManager.currentLanguage)
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
                    // Content Area
                    Group {
                        if selectedTab == .questions {
                            QuestionsContentView(isTabBarVisible: $isTabBarVisible)
                        } else if selectedTab == .notes {
                            NotesContentView(isTabBarVisible: $isTabBarVisible)
                        } else {
                            GameContentView(isTabBarVisible: $isTabBarVisible)
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: selectedTab == .questions ? .leading : .trailing)))
                    
                    // Tab Bar at the bottom - Collapsible
                    if isTabBarVisible {
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
                            
                            // Game Tab
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedTab = .game
                                }
                            }) {
                                VStack(spacing: 8) {
                                    Image(systemName: selectedTab == .game ? "gamecontroller.fill" : "gamecontroller")
                                        .font(.system(size: 24, weight: .semibold))
                                    
                                    Text(localized.gameTab)
                                        .font(.system(size: 12, weight: selectedTab == .game ? .bold : .medium, design: .rounded))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .foregroundColor(selectedTab == .game ? .orange : .gray)
                                .background(
                                    selectedTab == .game ?
                                    Color.orange.opacity(0.1) :
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
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

enum MenuTab {
    case questions
    case notes
    case game
}

struct QuestionsContentView: View {
    @Binding var isTabBarVisible: Bool
    @StateObject private var viewModel = QuestionViewModel()
    @EnvironmentObject var languageManager: LanguageManager
    
    var localized: LocalizedStrings {
        LocalizedStrings(language: languageManager.currentLanguage)
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
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
            
            // Floating toggle button
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isTabBarVisible.toggle()
                }
            }) {
                Image(systemName: isTabBarVisible ? "chevron.down.circle.fill" : "chevron.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.white)
                    .background(
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.blue, Color.purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 56, height: 56)
                            .shadow(color: Color.blue.opacity(0.4), radius: 8, x: 0, y: 4)
                    )
            }
            .padding(.trailing, 20)
            .padding(.bottom, isTabBarVisible ? 80 : 20)
            .transition(.scale.combined(with: .opacity))
        }
    }
}

struct NotesContentView: View {
    @Binding var isTabBarVisible: Bool
    @EnvironmentObject var languageManager: LanguageManager
    @State private var scrollOffset: CGFloat = 0
    @State private var lastScrollOffset: CGFloat = 0
    
    var localized: LocalizedStrings {
        LocalizedStrings(language: languageManager.currentLanguage)
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            NotesView()
            
            // Floating toggle button
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isTabBarVisible.toggle()
                }
            }) {
                Image(systemName: isTabBarVisible ? "chevron.down.circle.fill" : "chevron.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.white)
                    .background(
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.blue, Color.purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 56, height: 56)
                            .shadow(color: Color.blue.opacity(0.4), radius: 8, x: 0, y: 4)
                    )
            }
            .padding(.trailing, 20)
            .padding(.bottom, isTabBarVisible ? 80 : 20)
            .transition(.scale.combined(with: .opacity))
        }
    }
}

struct GameContentView: View {
    @Binding var isTabBarVisible: Bool
    @EnvironmentObject var languageManager: LanguageManager
    
    var localized: LocalizedStrings {
        LocalizedStrings(language: languageManager.currentLanguage)
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            GameView()
            
            // Floating toggle button
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isTabBarVisible.toggle()
                }
            }) {
                Image(systemName: isTabBarVisible ? "chevron.down.circle.fill" : "chevron.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.white)
                    .background(
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.blue, Color.purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 56, height: 56)
                            .shadow(color: Color.blue.opacity(0.4), radius: 8, x: 0, y: 4)
                    )
            }
            .padding(.trailing, 20)
            .padding(.bottom, isTabBarVisible ? 80 : 20)
            .transition(.scale.combined(with: .opacity))
        }
    }
}

#Preview {
    MainMenuView()
        .environmentObject(LanguageManager())
}
