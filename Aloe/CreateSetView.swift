//
//  CreateSetView.swift
//  Aloe
//
//  Created by Collin Hamilton on 9/5/24.
//

import SwiftUI

struct CreateSetView: View {
    @ObservedObject var flashcardStore: FlashcardStore
    @State private var setName: String = ""
    @State private var newTerm: String = ""
    @State private var newDefinition: String = ""
    @State private var selectedSet: FlashcardSet?

    var body: some View {
        VStack {
            TextField("Enter Set Name", text: $setName)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding()

            Button(action: {
                flashcardStore.addFlashcardSet(setName: setName)
                setName = ""
            }) {
                Text("Create Set")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            List {
                ForEach(flashcardStore.flashcardSets) { set in
                    Button(action: {
                        selectedSet = set
                    }) {
                        VStack(alignment: .leading) {
                            Text(set.setName)
                                .font(.headline)
                        }
                    }
                }
            }
            .padding()

            if let set = selectedSet {
                Text("Adding Flashcards to: \(set.setName)")
                    .font(.title2)
                    .padding()

                HStack {
                    TextField("Term", text: $newTerm)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 150)

                    TextField("Definition", text: $newDefinition)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 150)

                    Button(action: {
                        flashcardStore.addFlashcard(to: set, term: newTerm, definition: newDefinition)
                        newTerm = ""
                        newDefinition = ""
                    }) {
                        Text("Add")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()
            }

            Spacer()
        }
        .navigationTitle("Create Flashcard Set")
        .padding()
    }
}
