import SwiftUI

struct CustomBarButton: View {
    let systemName: String
    let action: () -> Void
    let isBackButton: Bool
    
    init(systemName: String, isBackButton: Bool = false, action: @escaping () -> Void) {
        self.systemName = systemName
        self.isBackButton = isBackButton
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 17, weight: isBackButton ? .semibold : .medium))
                .foregroundStyle(.primary)
        }
        // Plain avoids oversized glass circles; don't add frame/padding here —
        // toolbar layout uses that size for the chrome.
        .buttonStyle(.plain)
    }
}

// Convenience initializer for back button
extension CustomBarButton {
    static func backButton(action: @escaping () -> Void) -> CustomBarButton {
        CustomBarButton(systemName: "chevron.left", isBackButton: true, action: action)
    }
}

#Preview {
    NavigationStack {
        Text("Sample View")
            .navigationTitle("Title")
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    CustomBarButton.backButton {
                        print("Back button tapped")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    CustomBarButton(systemName: "plus.circle") {
                        print("Plus button tapped")
                    }
                }
            }
    }
}
