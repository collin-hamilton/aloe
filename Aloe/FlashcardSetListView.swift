//
//  FlashcardSetListView.swift
//  Aloe
//
//  Created by Collin Hamilton on 9/5/24.
//

import SwiftUI

struct FlashcardSetListView: View {
    @ObservedObject var flashcardStore: FlashcardStore

    var body: some View {
        List {
            ForEach(flashcardStore.flashcardSets) { set in
                NavigationLink(destination: FlashcardSetDetailView(flashcardStore: flashcardStore, selectedSet: set)) {
                    Text(set.setName)
                        .font(.headline)
                        .padding()
                }
            }
        }
        .navigationTitle("Manage Flashcard Sets")
    }
}
