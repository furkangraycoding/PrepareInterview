//
//  Question.swift
//  InterviewPrep
//
//  Created on 2024
//

import Foundation

struct QuestionData: Codable {
    let lowLevelDesign: [Question]
    let highLevelDesign: [Question]
}

struct Question: Codable, Identifiable {
    let id: String
    let category: String
    let title: String
    let question: String
    let answer: String
    let explanation: String
}

enum QuestionCategory: String, CaseIterable {
    case lowLevelDesign = "lowLevelDesign"
    case highLevelDesign = "highLevelDesign"
    
    var displayName: String {
        switch self {
        case .lowLevelDesign:
            return "Low Level Design"
        case .highLevelDesign:
            return "High Level Design"
        }
    }
}

