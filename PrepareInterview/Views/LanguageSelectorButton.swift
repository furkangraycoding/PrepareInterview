//
//  LanguageSelectorButton.swift
//  InterviewPrep
//
//  Created on 2024
//

import SwiftUI

struct LanguageSelectorButton: View {
    @EnvironmentObject var languageManager: LanguageManager
    @State private var isMenuOpen = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Main Button
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isMenuOpen.toggle()
                }
            }) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.blue.opacity(0.9), Color.purple.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                        .shadow(color: Color.blue.opacity(0.4), radius: 8, x: 0, y: 4)
                    
                    Text(languageManager.currentLanguage.flag)
                        .font(.system(size: 24))
                }
            }
            .zIndex(10)
            
            // Dropdown Menu - Compact size, only under button
            if isMenuOpen {
                VStack(spacing: 0) {
                    ForEach(AppLanguage.allCases, id: \.self) { language in
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                languageManager.setLanguage(language)
                                isMenuOpen = false
                            }
                        }) {
                            HStack(spacing: 10) {
                                Text(language.flag)
                                    .font(.system(size: 20))
                                
                                if languageManager.currentLanguage == language {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.blue)
                                }
                            }
                            .frame(width: 44, height: 44)
                            .background(
                                languageManager.currentLanguage == language ?
                                Color.blue.opacity(0.1) :
                                Color.clear
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
                .frame(width: 44)
                .padding(.top, 50)
                .transition(.opacity.combined(with: .move(edge: .top)))
                .zIndex(9)
            }
        }
    }
}

#Preview {
    LanguageSelectorButton()
        .environmentObject(LanguageManager())
        .padding()
}

