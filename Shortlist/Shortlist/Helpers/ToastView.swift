//
//  ToastView.swift
//  Shortlist
//
//  Created by Dustin Bergman on 12/26/22.
//

import SwiftUI

struct ToastView: View {
    let message: String
    let type: ToastType
    let isVisible: Bool
    let onDismiss: (() -> Void)?
    
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false
    
    enum ToastType {
        case success
        case error
        
        var backgroundColor: Color {
            switch self {
            case .success: return .green
            case .error: return .red
            }
        }
        
        var icon: String {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .error: return "exclamationmark.circle.fill"
            }
        }
    }
    
    var body: some View {
        if isVisible {
            HStack(spacing: 12) {
                Image(systemName: type.icon)
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .semibold))
                
                Text(message)
                    .foregroundColor(.white)
                    .font(.system(size: 14, weight: .medium))
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(type.backgroundColor)
            .cornerRadius(8)
            .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .offset(y: dragOffset)
            .opacity(isDragging ? max(0.3, 1 - abs(dragOffset) / 100.0) : 1)
            .transition(.move(edge: .top))
            .zIndex(999)
            .animation(.easeInOut(duration: 0.3), value: isDragging)
            .animation(.easeInOut(duration: 0.5), value: isVisible)
            .onTapGesture {
                onDismiss?()
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        isDragging = true
                        // Only allow upward swipes
                        if value.translation.height < 0 {
                            dragOffset = value.translation.height
                        }
                    }
                    .onEnded { value in
                        isDragging = false
                        // Dismiss if swiped up more than 50 points
                        if value.translation.height < -50 {
                            onDismiss?()
                        } else {
                            // Snap back to original position
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                dragOffset = 0
                            }
                        }
                    }
            )
        }
    }
}

struct ToastOverlay: View {
    @Binding var showToast: Bool
    @Binding var toastMessage: String
    @Binding var toastType: ToastView.ToastType
    
    var body: some View {
        VStack {
            ToastView(
                message: toastMessage,
                type: toastType,
                isVisible: showToast,
                onDismiss: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showToast = false
                    }
                }
            )
            Spacer()
        }
    }
}

struct ToastOverlay_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.gray.opacity(0.3)
                .ignoresSafeArea()
            
            VStack {
                ToastView(
                    message: "Success message here!",
                    type: .success,
                    isVisible: true,
                    onDismiss: { print("Toast dismissed!") }
                )
                Spacer()
            }
        }
    }
}
