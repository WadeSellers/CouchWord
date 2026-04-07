import SwiftUI

/// A tvOS-friendly letter picker for entering letters with the Siri Remote.
/// The grid layout allows quick navigation using the remote's directional pad.
struct LetterInputView: View {
    @ObservedObject var viewModel: PuzzleViewModel
    @Environment(\.dismiss) private var dismiss

    private let columns = Array(repeating: GridItem(.fixed(80), spacing: 12), count: 7)
    private let letters: [Character] = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")

    var body: some View {
        VStack(spacing: 30) {
            if let clue = viewModel.activeClue {
                Text(clue.label)
                    .font(.headline)
            }

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(letters, id: \.self) { letter in
                    Button {
                        viewModel.enterLetter(letter)
                    } label: {
                        Text(String(letter))
                            .font(.title2)
                            .fontWeight(.semibold)
                            .frame(width: 80, height: 80)
                    }
                    .buttonStyle(.card)
                }
            }

            HStack(spacing: 40) {
                Button("Clear") {
                    viewModel.clearCurrentCell()
                    dismiss()
                }

                Button("Cancel") {
                    dismiss()
                }
            }
        }
        .padding(40)
    }
}
