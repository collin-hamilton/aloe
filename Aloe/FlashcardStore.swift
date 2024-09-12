//
//  FlashcardStore.swift
//  Aloe
//
//  Created by Collin Hamilton on 9/5/24.
//

import Foundation

// Flashcard model
struct Flashcard: Identifiable, Codable, Hashable {
    var id: UUID
    var term: String
    var definition: String
    var correctCount: Int // Tracks correct answers
    var wrongCount: Int    // Tracks wrong answers

    init(id: UUID = UUID(), term: String, definition: String, correctCount: Int = 0, wrongCount: Int = 0) {
        self.id = id
        self.term = term
        self.definition = definition
        self.correctCount = correctCount
        self.wrongCount = wrongCount
    }
}

// FlashcardSet model
struct FlashcardSet: Identifiable, Codable, Hashable {
    var id: UUID
    var setName: String
    var flashcards: [Flashcard]

    init(id: UUID = UUID(), setName: String, flashcards: [Flashcard] = []) {
        self.id = id
        self.setName = setName
        self.flashcards = flashcards
    }
}

class FlashcardStore: ObservableObject {
    @Published var flashcardSets: [FlashcardSet] = [] {
        didSet {
            saveFlashcardSets()
        }
    }

    let userDefaultsKey = "FlashcardSetsData"

    init() {
        loadFlashcardSets()
    }

    // Add a new flashcard set
    func addFlashcardSet(setName: String) {
        let newSet = FlashcardSet(setName: setName)
        flashcardSets.append(newSet)
    }

    // Add flashcards to an existing set
    func addFlashcard(to set: FlashcardSet, term: String, definition: String) {
        if let index = flashcardSets.firstIndex(where: { $0.id == set.id }) {
            flashcardSets[index].flashcards.append(Flashcard(term: term, definition: definition))
        }
    }

    // Save flashcard sets to UserDefaults
    private func saveFlashcardSets() {
        if let encodedData = try? JSONEncoder().encode(flashcardSets) {
            UserDefaults.standard.set(encodedData, forKey: userDefaultsKey)
        }
    }

    // Load flashcard sets from UserDefaults
    private func loadFlashcardSets() {
        if let savedData = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decodedSets = try? JSONDecoder().decode([FlashcardSet].self, from: savedData) {
            flashcardSets = decodedSets
        }
    }
}
