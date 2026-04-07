import SwiftUI

/// A tvOS-friendly letter picker for entering letters via Siri Remote.
/// Grid of A-Z with card-style buttons for easy remote navigation.
/// Also captures voice dictation input from the Siri Remote mic button.
struct LetterInputView: View {
    @ObservedObject var viewModel: PuzzleViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var dictatedText: String = ""
    @FocusState private var textFieldFocused: Bool

    private let columns = Array(repeating: GridItem(.fixed(80), spacing: 10), count: 7)
    private let letters: [Character] = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")

    var body: some View {
        VStack(spacing: 24) {
            // Current clue context
            if let clue = viewModel.activeClue {
                Text(clue.label)
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }

            // Voice input field (hidden but captures Siri dictation)
            TextField("Say a letter or word...", text: $dictatedText)
                .focused($textFieldFocused)
                .textInputAutocapitalization(.characters)
                .onChange(of: dictatedText) { _, newValue in
                    handleDictation(newValue)
                }
                .frame(height: 50)
                .padding(.horizontal)

            // Letter grid
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(letters, id: \.self) { letter in
                    Button {
                        viewModel.enterLetter(letter)
                        SoundManager.shared.play(.letterPlaced)
                        dismiss()
                    } label: {
                        Text(String(letter))
                            .font(.title2)
                            .fontWeight(.semibold)
                            .frame(width: 80, height: 80)
                    }
                    .buttonStyle(.card)
                }
            }

            // Action buttons
            HStack(spacing: 40) {
                Button("Clear") {
                    viewModel.clearCurrentCell()
                    dismiss()
                }

                Button("Cancel") {
                    dismiss()
                }
            }
            .padding(.top, 8)
        }
        .padding(40)
        .onAppear {
            textFieldFocused = true
        }
    }

    private func handleDictation(_ text: String) {
        let cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard !cleaned.isEmpty else { return }

        if cleaned.count == 1, let letter = cleaned.first {
            // Single letter input
            viewModel.enterLetter(letter)
            SoundManager.shared.play(.letterPlaced)
            dismiss()
        } else if cleaned.count > 1 {
            // Word input — fill from cursor
            viewModel.enterWord(cleaned)
            SoundManager.shared.play(.wordCompleted)
            dismiss()
        }
    }
}
