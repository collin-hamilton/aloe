//
//  LearnModeView.swift
//  Aloe
//
//  Created by Collin Hamilton on 9/5/24.
//

import SwiftUI

struct LearnModeView: View {
    @ObservedObject var flashcardStore: FlashcardStore
    var currentSet: FlashcardSet

    @State private var selectedMode: String = "Multiple Choice"
    @State private var currentCardIndex = 0
    @State private var questionCount = 0
    @State private var masteredCards: [Flashcard] = []
    @State private var missedCards: [Flashcard] = []
    @State private var knownCards: [Flashcard] = []
    @State private var seenCards: Set<Flashcard> = []
    @State private var showAnswer = false
    @State private var showResult = false
    @State private var resultMessage = ""
    @State private var trueFalseQuestionIsTrue = true
    @State private var options: [String] = []
    @State private var userAnswer: String = ""
    @State private var showResetAlert = false
    @State private var showProgressReport = false
    @State private var disableAnswerSelection = false
    @State private var shuffleCards = false // New state for shuffling cards

    var modes = ["Multiple Choice", "True/False", "Written Answer"]

    var body: some View {
        VStack {
            if showProgressReport {
                progressReportView
            } else {
                if selectedMode == "Multiple Choice" {
                    multipleChoiceView
                } else if selectedMode == "True/False" {
                    trueFalseView
                } else {
                    writtenAnswerView
                }

                Spacer()

                // Progress Bars
                VStack(spacing: 10) {
                    ProgressView(value: Double(questionCount % 10) / 10)
                        .progressViewStyle(LinearProgressViewStyle(tint: .orange))
                        .padding()
                        .frame(height: 10)
                        .overlay(Text("\(questionCount % 10)/10").font(.footnote))

                    ProgressView(value: Double(masteredCards.count) / Double(currentSet.flashcards.count))
                        .progressViewStyle(LinearProgressViewStyle(tint: .green))
                        .padding()
                        .frame(height: 10)
                        .overlay(Text("\(masteredCards.count)/\(currentSet.flashcards.count)").font(.footnote))
                }
                .padding(.bottom)
            }
        }
        .onAppear {
            prepareNextQuestion()
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                // Options Menu on the left
                Menu {
                    Picker("Select Learn Mode", selection: $selectedMode) {
                        ForEach(modes, id: \.self) { mode in
                            Text(mode)
                        }
                    }

                    // Shuffle option toggle
                    Toggle("Shuffle Cards", isOn: $shuffleCards)
                } label: {
                    Label("Options", systemImage: "ellipsis.circle")
                }

                // Reset button on the right
                Button("Reset") {
                    showResetAlert = true
                }
            }
        }
        .alert(isPresented: $showResetAlert) {
            Alert(
                title: Text("Reset Progress"),
                message: Text("Are you sure you want to reset your progress?"),
                primaryButton: .destructive(Text("Reset")) {
                    resetProgress()
                },
                secondaryButton: .cancel()
            )
        }
    }

    // Progress Report View (unchanged)
    var progressReportView: some View {
        VStack {
            Text("Progress Report")
                .font(.largeTitle)
                .padding()

            Text("Cards Not Seen Yet: \(currentSet.flashcards.count - seenCards.count)")
                .font(.headline)
                .padding()

            Text("Cards Missed So Far: \(missedCards.count)")
                .font(.headline)
                .padding()

            Text("Cards Known: \(knownCards.count)")
                .font(.headline)
                .padding()

            Text("Cards Mastered: \(masteredCards.count)")
                .font(.headline)
                .padding()

            Button(action: {
                showProgressReport = false
                prepareNextQuestion()
            }) {
                Text("Continue")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }

            Spacer()
        }
    }

    // Multiple Choice Mode (unchanged)
    var multipleChoiceView: some View {
        VStack {
            Text("Term: \(currentSet.flashcards[currentCardIndex].term)")
                .font(.largeTitle)
                .padding()

            ForEach(options, id: \.self) { option in
                Button(action: {
                    if !disableAnswerSelection {
                        checkAnswerMultipleChoice(selectedAnswer: option)
                    }
                }) {
                    Text(option)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                .disabled(disableAnswerSelection)
            }

            if showResult {
                Text(resultMessage)
                    .font(.headline)
                    .foregroundColor(resultMessage == "Correct!" ? .green : .red)
                    .padding()
            }
        }
    }

    // True/False Mode (unchanged)
    var trueFalseView: some View {
        VStack {
            Text("Term: \(currentSet.flashcards[currentCardIndex].term)")
                .font(.largeTitle)
                .padding()

            Text("Is this definition correct?")
                .font(.title2)
                .padding()

            Text(currentSet.flashcards[currentCardIndex].definition)
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding()

            HStack {
                Button(action: {
                    if !disableAnswerSelection {
                        checkAnswerTrueFalse(isTrueSelected: true)
                    }
                }) {
                    Text("True")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                .disabled(disableAnswerSelection)

                Button(action: {
                    if !disableAnswerSelection {
                        checkAnswerTrueFalse(isTrueSelected: false)
                    }
                }) {
                    Text("False")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                .disabled(disableAnswerSelection)
            }

            if showResult {
                Text(resultMessage)
                    .font(.headline)
                    .foregroundColor(resultMessage == "Correct!" ? .green : .red)
                    .padding()
            }
        }
    }

    // Written Answer Mode (unchanged)
    var writtenAnswerView: some View {
        VStack {
            Text("Term: \(currentSet.flashcards[currentCardIndex].term)")
                .font(.largeTitle)
                .padding()

            TextField("Enter the definition", text: $userAnswer)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button(action: {
                if !disableAnswerSelection {
                    checkAnswerWritten()
                }
            }) {
                Text("Submit")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
            .disabled(disableAnswerSelection)

            if showResult {
                Text(resultMessage)
                    .font(.headline)
                    .foregroundColor(resultMessage == "Correct!" ? .green : .red)
                    .padding()
            }
        }
    }

    // Check answers for multiple choice
    func checkAnswerMultipleChoice(selectedAnswer: String) {
        let correctAnswer = currentSet.flashcards[currentCardIndex].definition
        processAnswer(isCorrect: selectedAnswer == correctAnswer)
    }

    // Check answers for True/False
    func checkAnswerTrueFalse(isTrueSelected: Bool) {
        let correctAnswer = trueFalseQuestionIsTrue
        processAnswer(isCorrect: isTrueSelected == correctAnswer)
    }

    // Check answers for Written Mode
    func checkAnswerWritten() {
        let correctAnswer = currentSet.flashcards[currentCardIndex].definition
        processAnswer(isCorrect: userAnswer.lowercased() == correctAnswer.lowercased())
    }

    // Process the answer (unchanged)
    func processAnswer(isCorrect: Bool) {
        let currentCard = currentSet.flashcards[currentCardIndex]
        seenCards.insert(currentCard)

        if isCorrect {
            resultMessage = "Correct!"
            if masteredCards.contains(currentCard) {
                // Already mastered
            } else if knownCards.contains(currentCard) {
                // Promote to mastered if already known
                masteredCards.append(currentCard)
                knownCards.removeAll { $0.id == currentCard.id }
            } else {
                // Mark as known
                knownCards.append(currentCard)
            }
        } else {
            resultMessage = "Wrong!"
            missedCards.append(currentCard)
        }

        showResult = true
        questionCount += 1

        disableAnswerSelection = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            disableAnswerSelection = false
            if questionCount % 10 == 0 {
                showProgressReport = true
            } else {
                prepareNextQuestion()
            }
        }
    }

    // Prepare the next question (updated for shuffle)
    func prepareNextQuestion() {
        showResult = false
        userAnswer = ""

        if shuffleCards {
            currentCardIndex = Int.random(in: 0..<currentSet.flashcards.count)
        } else {
            currentCardIndex = (currentCardIndex + 1) % currentSet.flashcards.count
        }

        if selectedMode == "Multiple Choice" {
            generateMultipleChoiceOptions()
        } else if selectedMode == "True/False" {
            trueFalseQuestionIsTrue = Bool.random()
        }
    }

    // Generate options for multiple choice mode (unchanged)
    func generateMultipleChoiceOptions() {
        let correctAnswer = currentSet.flashcards[currentCardIndex].definition
        var incorrectAnswers = currentSet.flashcards.filter { $0.definition != correctAnswer }.map { $0.definition }

        incorrectAnswers.shuffle()

        options = Array(incorrectAnswers.prefix(3)) + [correctAnswer]
        options.shuffle()
    }

    // Reset progress (unchanged)
    func resetProgress() {
        flashcardStore.flashcardSets = flashcardStore.flashcardSets.map { set in
            if set.id == currentSet.id {
                var updatedSet = set
                updatedSet.flashcards = updatedSet.flashcards.map { card in
                    var resetCard = card
                    resetCard.correctCount = 0
                    resetCard.wrongCount = 0
                    return resetCard
                }
                return updatedSet
            }
            return set
        }
        questionCount = 0
        masteredCards.removeAll()
        missedCards.removeAll()
        knownCards.removeAll()
        seenCards.removeAll()
        prepareNextQuestion()
    }
}
