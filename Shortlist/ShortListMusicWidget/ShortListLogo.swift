//
//  ShortListLogo.swift
//  ShortListMusicWidget
//
//  Created by Dustin Bergman on 10/7/25.
//

import SwiftUI
import WidgetKit

struct ShortListLogo: View {
    var size: CGFloat = 100
    
    var body: some View {
        // RecordPlayer asset as base
        Image("RecordPlayer")
            .renderingMode(.original)
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .overlay(
                // RecordBars asset as overlay
                Image("RecordBars")
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size, height: size)
            )
    }
}
