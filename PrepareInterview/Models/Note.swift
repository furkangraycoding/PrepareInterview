//
//  Note.swift
//  InterviewPrep
//
//  Created on 2024
//

import Foundation

struct JavaNotesData: Codable {
    let sections: [NoteSection]
}

struct NoteSection: Identifiable, Codable, Equatable {
    let id: Int
    let title: String
    let topics: [NoteTopic]
    
    static func == (lhs: NoteSection, rhs: NoteSection) -> Bool {
        lhs.id == rhs.id && lhs.title == rhs.title && lhs.topics == rhs.topics
    }
}

struct NoteTopic: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let content: String
}
