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
            HStack(spacing: 4) {
                Image(systemName: systemName)
                    .font(.system(size: 16, weight: isBackButton ? .semibold : .medium))
                    .foregroundColor(.primary)
            }
        }
        .buttonStyle(CustomButtonStyle())
    }
}

struct CustomButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.primary)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// Convenience initializer for back button
extension CustomBarButton {
    static func backButton(action: @escaping () -> Void) -> CustomBarButton {
        CustomBarButton(systemName: "chevron.left", isBackButton: true, action: action)
    }
}

#Preview {
    NavigationView {
        Text("Sample View")
            .navigationTitle("Title")
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(
                leading: CustomBarButton.backButton {
                    print("Back button tapped")
                },
                trailing: CustomBarButton(systemName: "plus.magnifyingglass") {
                    print("Plus button tapped")
                }
            )
    }
}
