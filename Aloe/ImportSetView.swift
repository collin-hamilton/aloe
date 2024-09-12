//
//  ImportSetView.swift
//  Aloe
//
//  Created by Collin Hamilton on 9/5/24.
//

import SwiftUI

struct ImportSetView: View {
    @ObservedObject var flashcardStore: FlashcardStore
    @State private var importText: String = ""
    @State private var termDefinitionSeparator: String = ":"
    @State private var cardSeparator: String = "\n\n" // Default to double newline separating cards
    @State private var flashcardCount: Int = 0
    @State private var selectedSet: FlashcardSet? = nil
    @State private var newSetName: String = ""
    @State private var showCreateNewSet: Bool = false // Toggle to show "Create New Set" field

    var body: some View {
        VStack {
            Text("Import Flashcards")
                .font(.largeTitle)
                .padding()

            // Set Selection Dropdown (Moved above the text box)
            Picker("Select Set", selection: $selectedSet) {
                ForEach(flashcardStore.flashcardSets) { set in
                    Text(set.setName).tag(set as FlashcardSet?)
                }
            }
            .padding()
            .pickerStyle(MenuPickerStyle())

            // Option to create a new set
            Toggle(isOn: $showCreateNewSet) {
                Text("Create New Set")
            }
            .padding()

            if showCreateNewSet {
                TextField("New Set Name", text: $newSetName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
            }

            // Text box for the flashcards data (Moved below set selection)
            TextEditor(text: $importText)
                .border(Color.gray)
                .frame(height: 300)
                .padding()

            // Display how many flashcards are detected
            Text("Detected Flashcards: \(flashcardCount)")
                .font(.headline)
                .padding()

            // Separators for term/definition and cards
            HStack {
                VStack(alignment: .leading) {
                    Text("Between Term and Definition Separator")
                    TextField("Separator (e.g., ':')", text: $termDefinitionSeparator)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                }
                VStack(alignment: .leading) {
                    Text("Between Cards Separator")
                    TextField("Separator (e.g., '\\n\\n')", text: $cardSeparator)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                }
            }

            // Button to import flashcards
            Button(action: {
                importFlashcards()
            }) {
                Text("Import Flashcards")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }

            Spacer()
        }
        .padding()
        .onChange(of: importText) {
            updateFlashcardCount()
        }
        .onChange(of: termDefinitionSeparator) {
            updateFlashcardCount()
        }
    }

    // Function to count and display how many flashcards are parsed
    func updateFlashcardCount() {
        let flashcards = importText.components(separatedBy: cardSeparator)
        flashcardCount = flashcards.filter { $0.contains(termDefinitionSeparator) }.count
    }

    // Function to import flashcards into the set
    func importFlashcards() {
        var setToImportInto: FlashcardSet

        // Check if a new set is being created
        if showCreateNewSet && !newSetName.isEmpty {
            let newSet = FlashcardSet(setName: newSetName)
            flashcardStore.flashcardSets.append(newSet)
            setToImportInto = newSet
        } else if let selected = selectedSet {
            setToImportInto = selected
        } else {
            // Fallback if nothing is selected or created (default to the first set)
            setToImportInto = flashcardStore.flashcardSets.first ?? FlashcardSet(setName: "Imported Set")
        }

        let flashcards = importText.components(separatedBy: cardSeparator)

        for flashcard in flashcards {
            let components = flashcard.components(separatedBy: termDefinitionSeparator)

            if components.count == 2 {
                let term = components[0].trimmingCharacters(in: .whitespacesAndNewlines)
                let definition = components[1].trimmingCharacters(in: .whitespacesAndNewlines)

                flashcardStore.addFlashcard(to: setToImportInto, term: term, definition: definition)
            }
        }
    }
}
