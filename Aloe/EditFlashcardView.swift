//
//  EditFlashcardView.swift
//  Aloe
//
//  Created by Collin Hamilton on 9/5/24.
//

import SwiftUI

struct EditFlashcardView: View {
    @ObservedObject var flashcardStore: FlashcardStore
    var selectedSet: FlashcardSet
    @State var card: Flashcard

    @State private var term: String = ""
    @State private var definition: String = ""

    // Use the environment to control the presentation mode
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            Text("Edit Flashcard")
                .font(.largeTitle)
                .padding()

            TextField("Term", text: $term)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            TextField("Definition", text: $definition)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button(action: saveChanges) {
                Text("Save Changes")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
            .padding()

            Spacer()
        }
        .onAppear {
            term = card.term
            definition = card.definition
        }
    }

    // Save changes to the flashcard and dismiss the sheet
    func saveChanges() {
        if let setIndex = flashcardStore.flashcardSets.firstIndex(where: { $0.id == selectedSet.id }),
           let cardIndex = flashcardStore.flashcardSets[setIndex].flashcards.firstIndex(where: { $0.id == card.id }) {

            // Update the card in the set
            flashcardStore.flashcardSets[setIndex].flashcards[cardIndex].term = term
            flashcardStore.flashcardSets[setIndex].flashcards[cardIndex].definition = definition
        }

        // Dismiss the sheet
        presentationMode.wrappedValue.dismiss()
    }
}
