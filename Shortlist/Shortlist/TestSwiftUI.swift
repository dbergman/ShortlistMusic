//
//  TestSwiftUI.swift
//  Shortlist
//
//  Created by Dustin Bergman on 12/24/23.
//

import SwiftUI

//struct TestSwiftUI: View {
//    var body: some View {
//        VStack {
//            Text("Sensitive Data")
//            // .redacted(reason: .placeholder)
//            Image(systemName: "record.circle.fill")
//                .resizable()
//                .scaledToFit()
//                .cornerRadius(10)
//                .frame(width: 150, height: 150)
//        }
//        .foregroundStyle(
//            .linearGradient(
//                colors: [Color.gray, Color.black],
//                startPoint: .leading,
//                endPoint: .trailing)
//            .animation(Animation.linear(duration: 2.0).repeatForever(autoreverses: true))
//        )
//        .redacted(reason: .placeholder)
//    }
//}
//
//
//#Preview {
//    TestSwiftUI()
//}

//struct AnimatedLinearGradientView: View {
//    @State private var gradientColors: [Color] = [.red, .blue]
//    private let animationDuration: Double = 2.0
//
//    var body: some View {
//        LinearGradient(gradient: Gradient(colors: gradientColors), startPoint: .leading, endPoint: .trailing)
//            .animation(Animation.linear(duration: animationDuration).repeatForever(autoreverses: true))
//            .onAppear {
//                withAnimation {
//                    gradientColors = [.blue, .red]
//                }
//            }
//            .frame(width: 200, height: 200)
//    }
//}
//
//struct AnimatedLinearGradientView_Previews: PreviewProvider {
//    static var previews: some View {
//        AnimatedLinearGradientView()
//    }
//}


struct ContentView: View {
    @State private var gradientColors: [Color] = [.white, Color(red: 0.8, green: 0.8, blue: 0.8)]
    private let animationDuration: Double = 2.0

    var body: some View {
                VStack {
                    Text("Sensitive Data")
                    Rectangle()
                }
            .foregroundStyle(LinearGradient(gradient: Gradient(colors: gradientColors), startPoint: .leading, endPoint: .trailing))
            .onAppear {
                withAnimation(Animation.linear(duration: animationDuration).repeatForever(autoreverses: true)) {
                    gradientColors = [Color(red: 0.8, green: 0.8, blue: 0.8), .white]
                }
            }
            .frame(width: 200, height: 200)
            .redacted(reason: .placeholder)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
