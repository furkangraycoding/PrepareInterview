//
//  GameQuestion.swift
//  InterviewPrep
//
//  Created on 2024
//

import Foundation

struct GameQuestion: Codable, Identifiable, Equatable {
    let id: UUID
    let topic: String
    let question: String
    let options: [String]
    let answer: String
    
    init(topic: String, question: String, options: [String], answer: String) {
        self.id = UUID()
        self.topic = topic
        self.question = question
        self.options = options
        self.answer = answer
    }
    
    enum CodingKeys: String, CodingKey {
        case topic, question, options, answer
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.topic = try container.decode(String.self, forKey: .topic)
        self.question = try container.decode(String.self, forKey: .question)
        self.options = try container.decode([String].self, forKey: .options)
        self.answer = try container.decode(String.self, forKey: .answer)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(topic, forKey: .topic)
        try container.encode(question, forKey: .question)
        try container.encode(options, forKey: .options)
        try container.encode(answer, forKey: .answer)
    }
}

