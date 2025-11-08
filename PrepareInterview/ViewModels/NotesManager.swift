//
//  NotesManager.swift
//  InterviewPrep
//
//  Created on 2024
//

import Foundation
import SwiftUI

class NotesManager: ObservableObject {
    static let shared = NotesManager()
    
    @Published var sections: [NoteSection] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private init() {
        loadNotes()
    }
    
    func loadNotes() {
        isLoading = true
        errorMessage = nil
        
        guard let url = Bundle.main.url(forResource: "notes_java", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let notesData = try? JSONDecoder().decode(JavaNotesData.self, from: data) else {
            errorMessage = "Notlar yüklenemedi"
            isLoading = false
            return
        }
        
        sections = notesData.sections
        isLoading = false
    }
}
