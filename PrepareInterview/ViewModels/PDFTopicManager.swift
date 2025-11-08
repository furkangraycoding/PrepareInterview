//
//  PDFTopicManager.swift
//  InterviewPrep
//
//  Created on 2024
//

import Foundation
import PDFKit

class PDFTopicManager: ObservableObject {
    static let shared = PDFTopicManager()
    
    @Published var topics: [PDFTopic] = []
    @Published var isLoading: Bool = false
    
    private init() {
        loadTopics()
    }
    
    func loadTopics() {
        // Try to load from JSON first
        if let url = Bundle.main.url(forResource: "pdf_topics", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let topicsData = try? JSONDecoder().decode(PDFTopicsData.self, from: data) {
            topics = topicsData.topics
            return
        }
        
        // If no JSON, try to extract from PDF
        extractTopicsFromPDF()
    }
    
    private func extractTopicsFromPDF() {
        isLoading = true
        
        // Try to load from Desktop first, then bundle
        let pdfURL: URL?
        
        // First try Desktop path
        let desktopPath = "/Users/furkangurcay/Desktop/abcde.pdf"
        if FileManager.default.fileExists(atPath: desktopPath) {
            pdfURL = URL(fileURLWithPath: desktopPath)
        } else if let bundleURL = Bundle.main.url(forResource: "abcde", withExtension: "pdf") {
            pdfURL = bundleURL
        } else if let bundleURL = Bundle.main.url(forResource: "notes", withExtension: "pdf") {
            pdfURL = bundleURL
        } else {
            pdfURL = nil
        }
        
        guard let url = pdfURL,
              let document = PDFDocument(url: url) else {
            isLoading = false
            return
        }
        
        var extractedTopics: [PDFTopic] = []
        var currentTopicTitle: String? = nil
        var currentTopicStartPage: Int = 0
        
        // Extract text from each page and detect topics
        for pageIndex in 0..<document.pageCount {
            if let page = document.page(at: pageIndex),
               let pageText = page.string {
                let lines = pageText.components(separatedBy: .newlines)
                
                // Look for topic headers (usually first few lines, bold, or numbered)
                for (lineIndex, line) in lines.prefix(5).enumerated() {
                    let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    // Detect topic headers (usually short, uppercase, or numbered)
                    if trimmedLine.count > 3 && trimmedLine.count < 100 &&
                       (trimmedLine.first?.isUppercase == true || 
                        trimmedLine.first?.isNumber == true ||
                        trimmedLine.contains(":") ||
                        lineIndex == 0) {
                        
                        // If we found a new topic, save the previous one
                        if let previousTitle = currentTopicTitle {
                            extractedTopics.append(PDFTopic(
                                id: "topic-\(extractedTopics.count + 1)",
                                title: previousTitle,
                                startPage: currentTopicStartPage + 1,
                                endPage: pageIndex
                            ))
                        }
                        
                        // Start new topic
                        currentTopicTitle = trimmedLine
                        currentTopicStartPage = pageIndex
                        break
                    }
                }
            }
        }
        
        // Add the last topic
        if let lastTitle = currentTopicTitle {
            extractedTopics.append(PDFTopic(
                id: "topic-\(extractedTopics.count + 1)",
                title: lastTitle,
                startPage: currentTopicStartPage + 1,
                endPage: document.pageCount
            ))
        }
        
        // If no topics found, create default topics by page ranges
        if extractedTopics.isEmpty {
            let pagesPerTopic = max(1, document.pageCount / 5)
            for i in 0..<5 {
                let startPage = i * pagesPerTopic + 1
                let endPage = min((i + 1) * pagesPerTopic, document.pageCount)
                extractedTopics.append(PDFTopic(
                    id: "topic-\(i + 1)",
                    title: "Bölüm \(i + 1)",
                    startPage: startPage,
                    endPage: endPage
                ))
            }
        }
        
        topics = extractedTopics
        isLoading = false
    }
    
    func getTopicForPage(_ page: Int) -> PDFTopic? {
        return topics.first { page >= $0.startPage && page <= $0.endPage }
    }
}

