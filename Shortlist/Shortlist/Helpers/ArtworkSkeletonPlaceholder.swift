import SkeletonUI
import SwiftUI

/// Animated artwork loading placeholder matching ShortlistCollections.
struct ArtworkSkeletonPlaceholder: View {
    let size: CGFloat
    var cornerRadius: CGFloat = 10

    /// Remounted after navigation transitions so SkeletonUI’s pulse isn’t cancelled.
    @State private var animationID = UUID()

    var body: some View {
        Rectangle()
            .skeleton(
                with: true,
                size: CGSize(width: size, height: size),
                animation: .pulse(),
                appearance: .gradient(),
                shape: .rectangle
            )
            .scaledToFit()
            .cornerRadius(cornerRadius)
            .frame(width: size, height: size)
            .id(animationID)
            .task {
                // Zoom / matched transitions disable animations during the first
                // onAppear. Restart once the transition has settled.
                try? await Task.sleep(for: .milliseconds(350))
                animationID = UUID()
            }
    }
}
