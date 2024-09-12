//
//  ContentView.swift
//  Aloe
//
//  Created by Collin Hamilton on 9/5/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject var flashcardStore = FlashcardStore() // Create a shared instance of FlashcardStore
    @State private var selectedSet: FlashcardSet?

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Center the buttons
                NavigationLink(destination: CreateSetView(flashcardStore: flashcardStore)) {
                    Text("Create Flashcard Set")
                        .font(.headline)
                        .frame(width: 250, height: 50)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                NavigationLink(destination: FlashcardSetListView(flashcardStore: flashcardStore)) {
                    Text("Manage Flashcard Sets")
                        .font(.headline)
                        .frame(width: 250, height: 50)
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                NavigationLink(destination: ImportSetView(flashcardStore: flashcardStore)) {
                    Text("Import Flashcard Set")
                        .font(.headline)
                        .frame(width: 250, height: 50)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                NavigationLink(destination: SelectFlashcardSetView(flashcardStore: flashcardStore, selectedSet: $selectedSet)) {
                    Text("Learn Mode")
                        .font(.headline)
                        .frame(width: 250, height: 50)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .navigationTitle("Aloe Home")
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center) // Center the buttons
        }
    }
}
