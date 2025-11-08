//
//  PDFTopic.swift
//  InterviewPrep
//
//  Created on 2024
//

import Foundation

struct PDFTopic: Identifiable, Codable {
    let id: String
    let title: String
    let startPage: Int
    let endPage: Int
    
    var pageRange: String {
        if startPage == endPage {
            return "\(startPage)"
        }
        return "\(startPage)-\(endPage)"
    }
}

struct PDFTopicsData: Codable {
    let topics: [PDFTopic]
}

