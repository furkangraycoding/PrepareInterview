//
//  PDFContentManager.swift
//  InterviewPrep
//
//  Created on 2024
//

import Foundation
import PDFKit

struct PDFSection: Identifiable {
    let id: String
    let title: String
    let content: String
    let pageNumber: Int
}

class PDFContentManager: ObservableObject {
    static let shared = PDFContentManager()
    
    @Published var sections: [PDFSection] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private init() {
        loadPDFContent()
    }
    
    func loadPDFContent() {
        isLoading = true
        errorMessage = nil
        
        // Try to load from Desktop first, then bundle
        let pdfURL: URL?
        
        // First try Desktop path
        let desktopPath = "abcde"
        if FileManager.default.fileExists(atPath: desktopPath) {
            pdfURL = URL(fileURLWithPath: desktopPath)
        } else if let bundleURL = Bundle.main.url(forResource: "notes", withExtension: "pdf") {
            pdfURL = bundleURL
        } else if let bundleURL = Bundle.main.url(forResource: "abcde", withExtension: "pdf") {
            pdfURL = bundleURL
        } else {
            pdfURL = nil
        }
        
        guard let url = pdfURL,
              let document = PDFDocument(url: url) else {
            errorMessage = "PDF dosyası bulunamadı"
            isLoading = false
            return
        }
        
        var extractedSections: [PDFSection] = []
        
        // Extract text from each page
        for pageIndex in 0..<document.pageCount {
            if let page = document.page(at: pageIndex),
               let pageText = page.string {
                let trimmedText = pageText.trimmingCharacters(in: .whitespacesAndNewlines)
                
                if !trimmedText.isEmpty {
                    // Try to detect section titles (first few lines that might be headings)
                    let lines = trimmedText.components(separatedBy: .newlines)
                    var title = "Sayfa \(pageIndex + 1)"
                    var content = trimmedText
                    
                    // Look for potential headings in first 3 lines
                    if lines.count > 0 {
                        let firstLine = lines[0].trimmingCharacters(in: .whitespacesAndNewlines)
                        // If first line is short and looks like a heading
                        if firstLine.count > 3 && firstLine.count < 80 && 
                           (firstLine.first?.isUppercase == true || 
                            firstLine.first?.isNumber == true ||
                            firstLine.contains(":") ||
                            firstLine.allSatisfy({ $0.isUppercase || $0.isWhitespace || $0.isNumber || $0.isPunctuation })) {
                            title = firstLine
                            // Remove title from content
                            if lines.count > 1 {
                                content = lines.dropFirst().joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
                            }
                        }
                    }
                    
                    extractedSections.append(PDFSection(
                        id: "section-\(pageIndex)",
                        title: title,
                        content: content,
                        pageNumber: pageIndex + 1
                    ))
                }
            }
        }
        
        sections = extractedSections
        isLoading = false
        
        print("PDF Content loaded: \(sections.count) sections")
    }
    
    func getSectionForPage(_ page: Int) -> PDFSection? {
        return sections.first { $0.pageNumber == page }
    }
}

