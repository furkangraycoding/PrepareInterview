//
//  PDFViewerView.swift
//  InterviewPrep
//
//  Created on 2024
//

import SwiftUI
import PDFKit

struct PDFViewerView: View {
    @StateObject private var contentManager = PDFContentManager.shared
    @StateObject private var topicManager = PDFTopicManager.shared
    @State private var selectedTopic: PDFTopic?
    @EnvironmentObject var languageManager: LanguageManager
    
    var localized: LocalizedStrings {
        LocalizedStrings(language: languageManager.currentLanguage)
    }
    
    var body: some View {
        ZStack {
            if contentManager.isLoading {
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text(localized.loading)
                        .foregroundColor(.secondary)
                }
            } else if let error = contentManager.errorMessage {
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 48))
                        .foregroundColor(.orange)
                    Text(error)
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Button(action: {
                        contentManager.loadPDFContent()
                    }) {
                        Text("Tekrar Dene")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(
                                LinearGradient(
                                    colors: [Color.blue, Color.purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                    }
                }
                .padding()
            } else {
                VStack(spacing: 0) {
                    // Topic Selector Bar
                    if !topicManager.topics.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(topicManager.topics) { topic in
                                    Button(action: {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            selectedTopic = topic
                                        }
                                    }) {
                                        VStack(spacing: 6) {
                                            Text(topic.title)
                                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                                .lineLimit(1)
                                            
                                            Text("\(localized.page) \(topic.pageRange)")
                                                .font(.caption2)
                                                .opacity(0.8)
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .background(
                                            Group {
                                                if selectedTopic?.id == topic.id {
                                                    LinearGradient(
                                                        colors: [Color.green, Color.orange],
                                                        startPoint: .leading,
                                                        endPoint: .trailing
                                                    )
                                                } else {
                                                    LinearGradient(
                                                        colors: [Color.gray.opacity(0.15), Color.gray.opacity(0.1)],
                                                        startPoint: .leading,
                                                        endPoint: .trailing
                                                    )
                                                }
                                            }
                                        )
                                        .foregroundColor(selectedTopic?.id == topic.id ? .white : .primary)
                                        .cornerRadius(12)
                                        .shadow(
                                            color: selectedTopic?.id == topic.id ? Color.green.opacity(0.3) : Color.clear,
                                            radius: selectedTopic?.id == topic.id ? 6 : 0
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        }
                        .background(
                            Color(.systemBackground)
                                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        )
                    }
                    
                    // Content ScrollView
                    ScrollView {
                        LazyVStack(spacing: 24) {
                            ForEach(filteredSections) { section in
                                PDFSectionView(section: section)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 24)
                    }
                }
            }
        }
        .onAppear {
            if contentManager.sections.isEmpty {
                contentManager.loadPDFContent()
            }
            topicManager.loadTopics()
        }
    }
    
    private var filteredSections: [PDFSection] {
        if let topic = selectedTopic {
            return contentManager.sections.filter { section in
                section.pageNumber >= topic.startPage && section.pageNumber <= topic.endPage
            }
        }
        return contentManager.sections
    }
}

struct PDFSectionView: View {
    let section: PDFSection
    @EnvironmentObject var languageManager: LanguageManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section Title
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(section.title)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("Sayfa \(section.pageNumber)")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(.bottom, 8)
            
            Divider()
                .background(Color.gray.opacity(0.3))
            
            // Section Content
            Text(section.content)
                .font(.system(size: 16, weight: .regular, design: .default))
                .foregroundColor(.primary)
                .lineSpacing(8)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [Color.green.opacity(0.3), Color.orange.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
}

#Preview {
    PDFViewerView()
        .environmentObject(LanguageManager())
}
