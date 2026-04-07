import SwiftUI

struct OnboardingView: View {
    let onComplete: () -> Void

    @State private var currentPage = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "hand.draw.fill",
            title: "Navigate with Siri Remote",
            description: "Swipe to move between cells.\nClick to toggle Across / Down.\nDouble-tap to zoom out and see the full grid.",
            color: .blue
        ),
        OnboardingPage(
            icon: "mic.fill",
            title: "Speak Your Answers",
            description: "Hold the Siri button and say a letter\nor spell out a full word.\nThe fastest way to fill in the grid.",
            color: .green
        ),
        OnboardingPage(
            icon: "iphone.radiowaves.left.and.right",
            title: "Shake to Undo",
            description: "Made a mistake? Shake the remote.\nSingle letter entries undo one cell.\nWord entries undo the whole word.",
            color: .orange
        ),
    ]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                // Page content
                let page = pages[currentPage]

                VStack(spacing: 28) {
                    Image(systemName: page.icon)
                        .font(.system(size: 80))
                        .foregroundStyle(page.color)
                        .id(currentPage)
                        .transition(.scale.combined(with: .opacity))

                    Text(page.title)
                        .font(.system(size: 42, weight: .bold, design: .serif))
                        .id("title-\(currentPage)")
                        .transition(.push(from: .trailing))

                    Text(page.description)
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .id("desc-\(currentPage)")
                        .transition(.push(from: .trailing))
                }
                .animation(.easeInOut(duration: 0.3), value: currentPage)

                Spacer()

                // Page indicators
                HStack(spacing: 12) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? pages[currentPage].color : Color.gray)
                            .frame(width: 10, height: 10)
                            .animation(.easeInOut, value: currentPage)
                    }
                }

                // Buttons
                HStack(spacing: 40) {
                    Button("Skip") {
                        onComplete()
                    }
                    .foregroundStyle(.secondary)

                    if currentPage < pages.count - 1 {
                        Button("Next") {
                            currentPage += 1
                        }
                    } else {
                        Button("Get Started") {
                            onComplete()
                        }
                        .fontWeight(.semibold)
                    }
                }
                .font(.title3)
                .padding(.bottom, 40)
            }
            .padding(60)
        }
        .onMoveCommand { direction in
            switch direction {
            case .right:
                if currentPage < pages.count - 1 { currentPage += 1 }
            case .left:
                if currentPage > 0 { currentPage -= 1 }
            default: break
            }
        }
    }
}

private struct OnboardingPage {
    let icon: String
    let title: String
    let description: String
    let color: Color
}
