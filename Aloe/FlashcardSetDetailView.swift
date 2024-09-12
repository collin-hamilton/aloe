//
//  FlashcardSetDetailView.swift
//  Aloe
//
//  Created by Collin Hamilton on 9/5/24.
//

import SwiftUI

struct FlashcardSetDetailView: View {
    @ObservedObject var flashcardStore: FlashcardStore
    var selectedSet: FlashcardSet

    @State private var newTerm: String = ""
    @State private var newDefinition: String = ""
    @State private var selectedCard: Flashcard?
    @State private var showDeleteConfirmation = false

    // Use the environment to control the presentation mode
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            // List of flashcards
            List {
                ForEach(selectedSet.flashcards) { card in
                    VStack(alignment: .leading) {
                        Text("Term: \(card.term)")
                            .font(.headline)
                        Text("Definition: \(card.definition)")
                            .font(.subheadline)
                            .foregroundColor(.gray)

                        // Edit and Delete options
                        HStack {
                            Button(action: {
                                selectedCard = card
                            }) {
                                Text("Edit")
                                    .foregroundColor(.blue)
                            }
                            Spacer()
                            Button(action: {
                                deleteFlashcard(card: card)
                            }) {
                                Text("Delete")
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(.top, 5)
                    }
                    .padding(.vertical)
                }
            }
            .sheet(item: $selectedCard) { card in
                EditFlashcardView(flashcardStore: flashcardStore, selectedSet: selectedSet, card: card)
            }

            Spacer()

            // Section to add new flashcards
            VStack(spacing: 15) {
                TextField("Term", text: $newTerm)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                TextField("Definition", text: $newDefinition)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button(action: addFlashcard) {
                    Text("Add Flashcard")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
            }
            .padding(.bottom, 20)
        }
        .navigationTitle(selectedSet.setName)
        .toolbar {
            // Small delete button in the upper right
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showDeleteConfirmation = true
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
        }
        .alert(isPresented: $showDeleteConfirmation) {
            Alert(
                title: Text("Delete Set"),
                message: Text("Are you sure you want to delete this set? This action cannot be undone."),
                primaryButton: .destructive(Text("Delete")) {
                    deleteSet()
                },
                secondaryButton: .cancel()
            )
        }
    }

    // Add new flashcard
    func addFlashcard() {
        flashcardStore.addFlashcard(to: selectedSet, term: newTerm, definition: newDefinition)
        newTerm = ""
        newDefinition = ""
    }

    // Delete a flashcard
    func deleteFlashcard(card: Flashcard) {
        flashcardStore.flashcardSets = flashcardStore.flashcardSets.map { set in
            if set.id == selectedSet.id {
                var updatedSet = set
                updatedSet.flashcards.removeAll { $0.id == card.id }
                return updatedSet
            }
            return set
        }
    }

    // Delete the entire flashcard set and return to the previous screen
    func deleteSet() {
        flashcardStore.flashcardSets.removeAll { $0.id == selectedSet.id }

        // Dismiss the view and go back to the Manage Flashcard Sets screen
        presentationMode.wrappedValue.dismiss()
    }
}
