//
//  SelectFlashcardSetView.swift
//  Aloe
//
//  Created by Collin Hamilton on 9/5/24.
//

import SwiftUI

struct SelectFlashcardSetView: View {
    @ObservedObject var flashcardStore: FlashcardStore
    @Binding var selectedSet: FlashcardSet?

    var body: some View {
        List {
            ForEach(flashcardStore.flashcardSets) { set in
                NavigationLink(destination: LearnModeView(flashcardStore: flashcardStore, currentSet: set)) {
                    Text(set.setName)
                        .font(.headline)
                        .padding()
                }
            }
        }
        .navigationTitle("Select a Flashcard Set")
    }
}
