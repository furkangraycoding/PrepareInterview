//
//  NotesView.swift
//  InterviewPrep
//
//  Created on 2024
//

import SwiftUI

struct NotesView: View {
    @StateObject private var notesManager = NotesManager.shared
    @State private var selectedSection: NoteSection?
    @State private var translatingTopics: Set<String> = []
    @State private var isTranslating = false
    @EnvironmentObject var languageManager: LanguageManager
    
    var localized: LocalizedStrings {
        LocalizedStrings(language: languageManager.currentLanguage)
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Enhanced Gradient Background
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.08),
                    Color.purple.opacity(0.05),
                    Color.pink.opacity(0.03)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Language Selector Button - Fixed at top right
            LanguageSelectorButton()
                .padding(.top, 60)
                .padding(.trailing, 16)
                .zIndex(1000)
            
            if notesManager.isLoading {
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text(localized.loading)
                        .foregroundColor(.secondary)
                }
            } else if let error = notesManager.errorMessage {
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 48))
                        .foregroundColor(.orange)
                    Text(error)
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Button(action: {
                        notesManager.loadNotes()
                    }) {
                        Text(localized.retry)
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
                    // Enhanced Section Selector Bar
                    if !notesManager.sections.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(notesManager.sections) { section in
                                    SectionButton(
                                        section: section,
                                        isSelected: selectedSection?.id == section.id,
                                        onTap: {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                selectedSection = section
                                            }
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                        }
                        .background(
                            Color(.systemBackground)
                                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        )
                    }
                    
                    // Content ScrollView
                    ScrollView {
                        LazyVStack(spacing: 24) {
                            ForEach(filteredTopics) { topic in
                                NoteTopicView(
                                    topic: topic,
                                    onTranslationStart: {
                                        translatingTopics.insert(topic.id)
                                        updateTranslatingState()
                                    },
                                    onTranslationComplete: {
                                        translatingTopics.remove(topic.id)
                                        updateTranslatingState()
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 24)
                    }
                    .blur(radius: isTranslating ? 8 : 0)
                    .disabled(isTranslating)
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
        .onAppear {
            if notesManager.sections.isEmpty {
                notesManager.loadNotes()
            }
            if selectedSection == nil && !notesManager.sections.isEmpty {
                selectedSection = notesManager.sections.first
            }
        }
        .onChange(of: languageManager.currentLanguage) { _ in
            translatingTopics.removeAll()
            updateTranslatingState()
        }
        .onChange(of: notesManager.sections) { _ in
            // When sections load, trigger translation for all topics
            if !notesManager.sections.isEmpty && selectedSection == nil {
                selectedSection = notesManager.sections.first
            }
        }
    }
    
    private func updateTranslatingState() {
        isTranslating = !translatingTopics.isEmpty
    }
    
    private var filteredTopics: [NoteTopic] {
        if let section = selectedSection {
            return section.topics
        }
        return notesManager.sections.flatMap { $0.topics }
    }
    
    private func sectionIcon(for title: String) -> String {
        let lowercased = title.lowercased()
        if lowercased.contains("core") || lowercased.contains("java") {
            return "gearshape.fill"
        } else if lowercased.contains("oop") || lowercased.contains("solid") {
            return "cube.fill"
        } else if lowercased.contains("thread") || lowercased.contains("concurrency") {
            return "cpu.fill"
        } else if lowercased.contains("pattern") || lowercased.contains("design") {
            return "puzzlepiece.fill"
        } else if lowercased.contains("distributed") || lowercased.contains("system") {
            return "network"
        }
        return "book.fill"
    }
}

struct SectionButton: View {
    let section: NoteSection
    let isSelected: Bool
    let onTap: () -> Void
    @EnvironmentObject var languageManager: LanguageManager
    @State private var translatedTitle: String = ""
    @State private var isTranslating = false
    
    private let translationService = TranslationService.shared
    
    private func sectionIcon(for title: String) -> String {
        let lowercased = title.lowercased()
        if lowercased.contains("core") || lowercased.contains("java") {
            return "gearshape.fill"
        } else if lowercased.contains("oop") || lowercased.contains("solid") {
            return "cube.fill"
        } else if lowercased.contains("thread") || lowercased.contains("concurrency") {
            return "cpu.fill"
        } else if lowercased.contains("pattern") || lowercased.contains("design") {
            return "puzzlepiece.fill"
        } else if lowercased.contains("distributed") || lowercased.contains("system") {
            return "network"
        }
        return "book.fill"
    }
    
    var displayTitle: String {
        if languageManager.currentLanguage == .turkish {
            return section.title
        }
        if !translatedTitle.isEmpty {
            return translatedTitle
        }
        return section.title
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                Image(systemName: sectionIcon(for: section.title))
                    .font(.system(size: 14, weight: .semibold))
                
                Text(displayTitle)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                Group {
                    if isSelected {
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color.blue, Color.purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    } else {
                        Capsule()
                            .fill(Color.gray.opacity(0.15))
                    }
                }
            )
            .foregroundColor(isSelected ? .white : .primary)
            .shadow(
                color: isSelected ? Color.blue.opacity(0.3) : Color.clear,
                radius: isSelected ? 6 : 0,
                x: 0,
                y: isSelected ? 3 : 0
            )
        }
        .buttonStyle(PlainButtonStyle())
        .task {
            translateTitle()
        }
        .onChange(of: languageManager.currentLanguage) { _ in
            translateTitle()
        }
    }
    
    private func translateTitle() {
        let targetLanguage = languageManager.currentLanguage
        
        guard targetLanguage != .turkish else {
            translatedTitle = ""
            return
        }
        
        let normalizedTitle = section.title.trimmingCharacters(in: .whitespacesAndNewlines)
        let cacheKey = "tr_\(targetLanguage.rawValue)_\(normalizedTitle)"
        
        // Check cache first
        if let cached = translationService.getCachedTranslation(cacheKey), !cached.isEmpty {
            translatedTitle = cached
            return
        }
        
        // If already translating, don't start again
        if isTranslating {
            return
        }
        
        isTranslating = true
        
        Task {
            let translated = await translationService.translateFromTurkish(section.title, to: targetLanguage)
            
            await MainActor.run {
                translatedTitle = translated.isEmpty ? section.title : translated
                isTranslating = false
            }
        }
    }
}

struct NoteTopicView: View {
    let topic: NoteTopic
    let onTranslationStart: () -> Void
    let onTranslationComplete: () -> Void
    @EnvironmentObject var languageManager: LanguageManager
    @State private var isExpanded = true
    @State private var translatedTitle: String = ""
    @State private var translatedContent: String = ""
    @State private var isTranslating = false
    
    private let translationService = TranslationService.shared
    
    var displayTitle: String {
        if languageManager.currentLanguage == .turkish {
            return topic.title
        }
        // If we have a translated title, use it (even if same as original, it means translation is done)
        if !translatedTitle.isEmpty {
            return translatedTitle
        }
        // Otherwise show original (while translating)
        return topic.title
    }
    
    var displayContent: String {
        if languageManager.currentLanguage == .turkish {
            return topic.content
        }
        // If we have translated content, use it (even if same as original, it means translation is done)
        if !translatedContent.isEmpty {
            return translatedContent
        }
        // Otherwise show original (while translating)
        return topic.content
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Enhanced Topic Header
            HStack(alignment: .top, spacing: 16) {
                // Icon Badge
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.blue.opacity(0.2), Color.purple.opacity(0.15)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                    
                    if isTranslating {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "book.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.blue, Color.purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    // Topic Title
                    Text(displayTitle)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.blue, Color.purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                        .lineSpacing(4)
                    
                    // Topic ID Badge
                    Text(topic.id)
                        .font(.system(size: 12, weight: .semibold, design: .monospaced))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.gray.opacity(0.15))
                        )
                }
                
                Spacer()
            }
            .padding(.bottom, 20)
            
            Divider()
                .background(Color.gray.opacity(0.3))
                .padding(.bottom, 20)
            
            // Enhanced Content with Rich Formatting
            FormattedContentText(content: displayContent)
        }
        .padding(28)
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
        .task {
            // Use task to ensure translation happens on first load
            translateContent()
        }
        .onChange(of: languageManager.currentLanguage) { newLanguage in
            // Force translation when language changes
            translatedTitle = ""
            translatedContent = ""
            isTranslating = false
            translateContent()
        }
        .onChange(of: topic.id) { _ in
            // When topic changes, translate again
            translateContent()
        }
    }
    
    private func translateContent() {
        let targetLanguage = languageManager.currentLanguage
        
        // If Turkish, clear translations
        guard targetLanguage != .turkish else {
            translatedTitle = ""
            translatedContent = ""
            isTranslating = false
            return
        }
        
        let normalizedTitle = topic.title.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedContent = topic.content.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check cache first - use the same format as TranslationService uses internally
        let titleCacheKey = "tr_\(targetLanguage.rawValue)_\(normalizedTitle)"
        let contentCacheKey = "tr_\(targetLanguage.rawValue)_\(normalizedContent)"
        
        // Check if we already have translations for this exact content
        if let cachedTitle = translationService.getCachedTranslation(titleCacheKey),
           let cachedContent = translationService.getCachedTranslation(contentCacheKey),
           !cachedTitle.isEmpty,
           !cachedContent.isEmpty {
            // Clean cached translations and use them
            let cleanCachedTitle = cleanTranslatedText(cachedTitle)
            let cleanCachedContent = cleanTranslatedText(cachedContent)
            
            // Only use cached if it's different from original
            if cleanCachedTitle != normalizedTitle {
                translatedTitle = cleanCachedTitle
            } else {
                translatedTitle = topic.title
            }
            
            if cleanCachedContent != normalizedContent {
                translatedContent = cleanCachedContent
            } else {
                translatedContent = topic.content
            }
            
            isTranslating = false
            return
        }
        
        // If we're already translating, don't start again
        if isTranslating {
            return
        }
        
        // Reset translations when language changes (if not cached)
        translatedTitle = ""
        translatedContent = ""
        isTranslating = true
        onTranslationStart()
        
        Task {
            // Translate both title and content
            async let titleTask = translationService.translateFromTurkish(topic.title, to: targetLanguage)
            async let contentTask = translationService.translateFromTurkish(topic.content, to: targetLanguage)
            
            let (translatedTitleResult, translatedContentResult) = await (titleTask, contentTask)
            
            await MainActor.run {
                // Clean up translated title - remove cache keys, file names, and other artifacts
                var cleanTitle = translatedTitleResult.isEmpty ? topic.title : translatedTitleResult
                cleanTitle = cleanTranslatedText(cleanTitle)
                
                // Clean up translated content
                var cleanContent = translatedContentResult.isEmpty ? topic.content : translatedContentResult
                cleanContent = cleanTranslatedText(cleanContent)
                
                translatedTitle = cleanTitle
                translatedContent = cleanContent
                
                isTranslating = false
                onTranslationComplete()
            }
        }
    }
    
    /// Clean translated text by removing cache keys, file names, and other artifacts
    private func cleanTranslatedText(_ text: String) -> String {
        var cleaned = text
        
        // Remove cache key patterns like "tr_en_", "tr_es_", etc.
        let cacheKeyPattern = #"tr_[a-z]{2}_"#
        cleaned = cleaned.replacingOccurrences(of: cacheKeyPattern, with: "", options: .regularExpression)
        
        // Remove file extensions and file names (e.g., ".md", hash patterns, etc.)
        // Remove common file extensions
        cleaned = cleaned.replacingOccurrences(of: "\\.md", with: "", options: .regularExpression)
        cleaned = cleaned.replacingOccurrences(of: "\\.txt", with: "", options: .regularExpression)
        cleaned = cleaned.replacingOccurrences(of: "\\.json", with: "", options: .regularExpression)
        
        // Remove hash patterns (32+ character alphanumeric strings)
        cleaned = cleaned.replacingOccurrences(of: #"[a-f0-9]{32,}"#, with: "", options: .regularExpression)
        
        // Remove date patterns like "2023q1", "2024", etc.
        cleaned = cleaned.replacingOccurrences(of: #"\d{4}q\d"#, with: "", options: .regularExpression)
        
        // Remove duplicate text (if same text appears multiple times consecutively)
        // This handles cases where translation duplicates the text
        var words = cleaned.split(separator: " ")
        if words.count > 1 {
            var uniqueWords: [String] = []
            var lastWord = ""
            for word in words {
                let wordStr = String(word)
                // Only add if it's not a duplicate of the last word
                if wordStr != lastWord || uniqueWords.isEmpty {
                    uniqueWords.append(wordStr)
                    lastWord = wordStr
                } else {
                    // Check if we're in a duplicate sequence
                    if uniqueWords.count > 1 && wordStr == uniqueWords[uniqueWords.count - 2] {
                        // Skip this duplicate
                        continue
                    }
                    uniqueWords.append(wordStr)
                    lastWord = wordStr
                }
            }
            cleaned = uniqueWords.joined(separator: " ")
        }
        
        // Trim whitespace
        cleaned = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Remove any remaining cache key patterns or artifacts
        // Remove strings that look like cache keys (start with language codes)
        let lines = cleaned.components(separatedBy: .newlines)
        cleaned = lines.filter { line in
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            // Skip lines that look like cache keys or file names
            if trimmed.contains("tr_") || trimmed.contains("_en_") || trimmed.hasSuffix(".md") {
                return false
            }
            // Skip lines that are just hash codes
            if trimmed.range(of: #"^[a-f0-9]{32,}$"#, options: .regularExpression) != nil {
                return false
            }
            return true
        }.joined(separator: "\n")
        
        return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

struct FormattedContentText: View {
    let content: String
    @State private var formattedSegments: [ContentSegment] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            ForEach(Array(formattedSegments.enumerated()), id: \.offset) { index, segment in
                segmentView(for: segment, index: index)
                    .transition(.opacity.combined(with: .move(edge: .leading)))
            }
        }
        .onAppear {
            formattedSegments = parseContent(content)
        }
        .onChange(of: content) { newContent in
            formattedSegments = parseContent(newContent)
        }
    }
    
    @ViewBuilder
    private func segmentView(for segment: ContentSegment, index: Int) -> some View {
        switch segment.type {
        case .heading:
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.orange.opacity(0.3), Color.yellow.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "star.fill")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.orange, Color.yellow],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                
                Text(segment.text)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.orange, Color.pink],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .lineSpacing(2)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [Color.orange.opacity(0.12), Color.yellow.opacity(0.08)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            colors: [Color.orange.opacity(0.4), Color.yellow.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            )
            .shadow(color: Color.orange.opacity(0.2), radius: 8, x: 0, y: 4)
            .padding(.vertical, 4)
            
        case .bullet:
            HStack(alignment: .top, spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.blue, Color.purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 24, height: 24)
                        .shadow(color: Color.blue.opacity(0.4), radius: 4, x: 0, y: 2)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 8, height: 8)
                }
                .padding(.top, 4)
                
                Text(segment.text)
                    .font(.system(size: 17, weight: .medium, design: .default))
                    .foregroundColor(.primary)
                    .lineSpacing(8)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.leading, 4)
            .padding(.vertical, 6)
            
        case .highlight:
            HStack(alignment: .top, spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                colors: [Color.yellow.opacity(0.3), Color.orange.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.yellow, Color.orange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(segment.text)
                        .font(.system(size: 17, weight: .semibold, design: .default))
                        .foregroundColor(.primary)
                        .lineSpacing(8)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(
                        LinearGradient(
                            colors: [Color.yellow.opacity(0.18), Color.orange.opacity(0.12)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(
                        LinearGradient(
                            colors: [Color.yellow.opacity(0.5), Color.orange.opacity(0.4)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            )
            .shadow(color: Color.yellow.opacity(0.25), radius: 12, x: 0, y: 6)
            
        case .important:
            HStack(alignment: .top, spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                colors: [Color.red.opacity(0.3), Color.pink.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.red, Color.pink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(segment.text)
                        .font(.system(size: 17, weight: .semibold, design: .default))
                        .foregroundColor(.primary)
                        .lineSpacing(8)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(
                        LinearGradient(
                            colors: [Color.red.opacity(0.15), Color.pink.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(
                        LinearGradient(
                            colors: [Color.red.opacity(0.5), Color.pink.opacity(0.4)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            )
            .shadow(color: Color.red.opacity(0.25), radius: 12, x: 0, y: 6)
            
        case .code:
            HStack(alignment: .top, spacing: 12) {
                VStack(spacing: 4) {
                    Circle()
                        .fill(Color.red.opacity(0.8))
                        .frame(width: 12, height: 12)
                    Circle()
                        .fill(Color.yellow.opacity(0.8))
                        .frame(width: 12, height: 12)
                    Circle()
                        .fill(Color.green.opacity(0.8))
                        .frame(width: 12, height: 12)
                }
                .padding(.top, 8)
                
                Text(segment.text)
                    .font(.system(size: 15, weight: .medium, design: .monospaced))
                    .foregroundColor(.white)
                    .lineSpacing(6)
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    colors: [Color.black.opacity(0.9), Color.gray.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                LinearGradient(
                                    colors: [Color.blue.opacity(0.5), Color.purple.opacity(0.4)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
            }
            .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
            
        case .regular:
            Text(segment.text)
                .font(.system(size: 18, weight: .regular, design: .default))
                .foregroundColor(.primary)
                .lineSpacing(12)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 4)
                .padding(.vertical, 8)
        }
    }
    
    private func parseContent(_ content: String) -> [ContentSegment] {
        var segments: [ContentSegment] = []
        let lines = content.components(separatedBy: .newlines)
        
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            if trimmed.isEmpty {
                continue
            }
            
            // Check for headings (lines ending with : and not starting with bullet)
            if trimmed.hasSuffix(":") && !trimmed.hasPrefix("•") && !trimmed.hasPrefix("-") && trimmed.count < 60 {
                segments.append(ContentSegment(text: String(trimmed.dropLast()), type: .heading))
            }
            // Check for bullet points
            else if trimmed.hasPrefix("•") || trimmed.hasPrefix("-") {
                let bulletText = trimmed.replacingOccurrences(of: "^[•-]\\s*", with: "", options: .regularExpression)
                segments.append(ContentSegment(text: bulletText, type: .bullet))
            }
            // Check for important keywords (must be at start or after colon)
            else if (trimmed.lowercased().hasPrefix("önemli") || 
                    trimmed.lowercased().hasPrefix("dikkat") ||
                    trimmed.lowercased().contains("not:") ||
                    trimmed.lowercased().contains("mülakat") ||
                    trimmed.lowercased().contains("anti-pattern")) && trimmed.count < 200 {
                segments.append(ContentSegment(text: trimmed, type: .important))
            }
            // Check for highlight keywords
            else if (trimmed.lowercased().hasPrefix("örnek") ||
                    trimmed.lowercased().hasPrefix("fayda") ||
                    trimmed.lowercased().hasPrefix("kullanım") ||
                    trimmed.lowercased().hasPrefix("amaç") ||
                    trimmed.lowercased().hasPrefix("avantaj")) && trimmed.count < 200 {
                segments.append(ContentSegment(text: trimmed, type: .highlight))
            }
            // Check for code-like patterns (short lines with parentheses or colons)
            else if trimmed.contains("()") && trimmed.count < 50 {
                segments.append(ContentSegment(text: trimmed, type: .code))
            }
            // Regular text
            else {
                segments.append(ContentSegment(text: trimmed, type: .regular))
            }
        }
        
        return segments
    }
}

struct ContentSegment {
    let text: String
    let type: SegmentType
}

enum SegmentType {
    case heading
    case bullet
    case highlight
    case important
    case code
    case regular
}

#Preview {
    NotesView()
        .environmentObject(LanguageManager())
}
