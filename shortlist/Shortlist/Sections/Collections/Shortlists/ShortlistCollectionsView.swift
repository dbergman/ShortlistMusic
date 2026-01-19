//
//  ShortlistCollectionsView.swift
//  Shortlist
//
//  Created by Dustin Bergman on 10/27/22.
//

import SkeletonUI
import SwiftUI
import MessageUI

struct ShortlistCollectionsView: View {
    @State var isPresented = false
    @State private var buttonOpacity: Double = 0
    @State private var showingOrderOptions = false
    @State private var showingMailSheet = false
    @State private var showingSettings = false
    @ObservedObject private var viewModel = ViewModel()
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        NavigationStack {
            CollectionsView(viewModel: viewModel, isPresented: $isPresented, buttonOpacity: $buttonOpacity)
                .navigationTitle("My ShortLists")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            showingOrderOptions = true
                        } label: {
                            Image(systemName: "arrow.up.arrow.down")
                        }
                        .tint(.primary)
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack(spacing: 16) {
                            if !viewModel.shortlists.isEmpty {
                                Button {
                                    showingMailSheet = true
                                } label: {
                                    Image(systemName: "square.and.arrow.up")
                                }
                                .tint(.primary)
                            }
                            
                            Button {
                                showingSettings = true
                            } label: {
                                Image(systemName: "gearshape")
                            }
                            .tint(.primary)
                        }
                    }
                }
                .onBoardingSheet()
                .sheet(isPresented: $isPresented) {
                    CreateShortlistView(isPresented: $isPresented, collectionsViewModel: viewModel)
                        .presentationDetents([.medium, .large])
                }
                .sheet(isPresented: $showingMailSheet) {
                    if MFMailComposeViewController.canSendMail() {
                        MailView(
                            subject: "My Music Shortlists",
                            messageBody: generateEmailContent(),
                            isHTML: false,
                            attachment: nil,
                            attachmentMimeType: nil,
                            attachmentFilename: nil
                        )
                    } else {
                        // Fallback for when mail is not available
                        VStack(spacing: 20) {
                            Text("Email Not Available")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("Your device is not configured to send emails. You can copy the shortlist information to your clipboard instead.")
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)
                            
                            Button("Copy to Clipboard") {
                                UIPasteboard.general.string = generatePlainTextContent()
                                showingMailSheet = false
                            }
                            .buttonStyle(.borderedProminent)
                            
                            Button("Cancel") {
                                showingMailSheet = false
                            }
                            .buttonStyle(.bordered)
                        }
                        .padding(40)
                        .presentationDetents([.medium])
                    }
                }
                .sheet(isPresented: $showingOrderOptions) {
                    SortOrderSelectionView(
                        currentOrdering: viewModel.currentOrdering,
                        onOrderingSelected: { ordering in
                            Task {
                                try? await viewModel.getShortlists(ordering: ordering)
                            }
                            showingOrderOptions = false
                        }
                    )
                    .presentationDetents([.medium])
                }
                .sheet(isPresented: $showingSettings) {
                    SettingsView()
                }
                .onAppear() {
                    // Log screen view analytics
                    AnalyticsManager.shared.logScreenView(
                        screenName: "Shortlists",
                        screenClass: "ShortlistCollectionsView"
                    )
                    
                    Task {
                        try? await viewModel.getShortlists()
                    }
                }
        }
    }
    
    private func generateEmailContent() -> String {
        var content = "My Music Shortlists\n\n"
        content += "Here are all my music shortlists and the albums they contain:\n\n"
        
        for shortlist in viewModel.shortlists {
            content += "\(shortlist.name) (\(shortlist.year))\n"
            content += String(repeating: "-", count: shortlist.name.count + shortlist.year.description.count + 3) + "\n"
            
            if let albums = shortlist.albums, !albums.isEmpty {
                let sortedAlbums = albums.sorted { $0.rank < $1.rank }
                
                for album in sortedAlbums {
                    content += "\(album.rank). \(album.title) - \(album.artist)\n"
                }
            } else {
                content += "No albums in this shortlist yet\n"
            }
            
            content += "\n"
        }
        
        return content
    }
    
    private func generatePlainTextContent() -> String {
        var textContent = "My Music Shortlists\n\n"
        textContent += "Here are all my music shortlists and the albums they contain:\n\n"
        
        for shortlist in viewModel.shortlists {
            textContent += "\(shortlist.name) (\(shortlist.year))\n"
            textContent += String(repeating: "-", count: shortlist.name.count + shortlist.year.description.count + 3) + "\n"
            
            if let albums = shortlist.albums, !albums.isEmpty {
                let sortedAlbums = albums.sorted { $0.rank < $1.rank }
                
                for album in sortedAlbums {
                    textContent += "\(album.rank). \(album.title) - \(album.artist)\n"
                }
            } else {
                textContent += "No albums in this shortlist yet\n"
            }
            
            textContent += "\n"
        }
        
        return textContent
    }
}

extension ShortlistCollectionsView {
    struct CollectionsView: View {
        @ObservedObject private var viewModel: ViewModel
        @Binding var isPresented: Bool
        @Binding var buttonOpacity: Double
        @Environment(\.colorScheme) private var colorScheme
        @State private var selectedShortlist: Shortlist?
        @State private var shortlistToDelete: Shortlist?
        
        init(viewModel: ViewModel, isPresented: Binding<Bool>, buttonOpacity: Binding<Double>) {
            self.viewModel = viewModel
            self._isPresented = isPresented
            self._buttonOpacity = buttonOpacity
        }
        
        var body: some View {
            if viewModel.isloading {
                loadingPlaceholder()
            } else if viewModel.shortlists.isEmpty {
                VStack(spacing: 16) {
                    Spacer()

                    Image(systemName: "music.note.list")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 72, height: 72)
                        .foregroundColor(.secondary)
                        .accessibilityHidden(true)

                    Text("No Shortlists Yet")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text("Create your first Shortlist to start tracking your favorite albums.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 32)

                    Button {
                        self.isPresented.toggle()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "plus.circle.fill")
                            Text("Add a Shortlist")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.primary)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    Capsule()
                                        .stroke(.quaternary, lineWidth: 0.5)
                                )
                        )
                        .clipShape(Capsule())
                    }
                    .padding(.top, 8)

                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
                .onAppear {
                    withAnimation(.easeIn(duration: 0.6)) {
                        buttonOpacity = 1
                    }
                }
            } else {
                List {
                    ForEach(viewModel.shortlists, id: \.self) { shortlist in
                        Button(action: {
                            selectedShortlist = shortlist
                        }) {
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text(shortlist.name)
                                        .font(Theme.shared.avenir(size: 20, weight: .bold))
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    
                                    if shortlist.year != "All" {
                                        Text(shortlist.year)
                                            .font(Theme.shared.avenir(size: 14, weight: .medium))
                                            .foregroundColor(.secondary)
                                            .padding(.leading, 5)
                                    }
                                }
                                .padding(.horizontal)
                                
                                VStack(spacing: 12) {
                                    HStack {
                                        loadImage(from: shortlist, with: 0)
                                        VStack {
                                            Grid {
                                                GridRow {
                                                    loadImage(from: shortlist, with: 1)
                                                    loadImage(from: shortlist, with: 2)
                                                }
                                                GridRow {
                                                    loadImage(from: shortlist, with: 3)
                                                    loadImage(from: shortlist, with: 4)
                                                }
                                            }
                                        }
                                    }
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color(.systemBackground))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(Color(.separator), lineWidth: 0.5)
                                        )
                                )
                                .cornerRadius(16)
                                .shadow(
                                    color: colorScheme == .dark ? 
                                        Color.black.opacity(0.4) : 
                                        Color.black.opacity(0.1),
                                    radius: colorScheme == .dark ? 12 : 8,
                                    x: 0,
                                    y: colorScheme == .dark ? 6 : 4
                                )
                                .padding(.horizontal)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal, 10)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                shortlistToDelete = shortlist
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .navigationDestination(isPresented: Binding(
                    get: { selectedShortlist != nil },
                    set: { if !$0 { selectedShortlist = nil } }
                )) {
                    if let shortlist = selectedShortlist {
                        ShortlistDetailsView(shortlist: shortlist)
                    }
                }
                .confirmationDialog("Delete Shortlist", isPresented: Binding(
                    get: { shortlistToDelete != nil },
                    set: { if !$0 { shortlistToDelete = nil } }
                )) {
                    Button("Delete", role: .destructive) {
                        if let shortlist = shortlistToDelete {
                            Task {
                                try? await viewModel.remove(shortlist: shortlist)
                            }
                        }
                        shortlistToDelete = nil
                    }
                    Button("Cancel", role: .cancel) {
                        shortlistToDelete = nil
                    }
                } message: {
                    if let shortlist = shortlistToDelete {
                        Text("Are you sure you want to delete '\(shortlist.name)'? This action cannot be undone.")
                    }
                }
                .overlay(
                    VStack {
                        Spacer()
                        HStack {
                            Button {
                                self.isPresented.toggle()
                            } label: {
                                HStack(spacing: 8) {
                                    Text("Add a Shortlist")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                                .foregroundColor(.primary)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(
                                    Capsule()
                                        .fill(.ultraThinMaterial)
                                        .overlay(
                                            Capsule()
                                                .stroke(.quaternary, lineWidth: 0.5)
                                        )
                                )
                                .clipShape(Capsule())
                            }
                            .opacity(buttonOpacity)
                            .padding(.bottom, 20)
                        }
                    }
                )
                .onAppear {
                    withAnimation(.easeIn(duration: 0.6)) {
                        buttonOpacity = 1
                    }
                }
            }
        }
        
        @ViewBuilder
        private func loadImage(from shortlist: Shortlist?, with index: Int) -> some View {
            let size = getImageSize(for: index)
            
            if
                let shortlistAlbums = shortlist?.albums,
                shortlistAlbums.count > index,
                let artworkURLString = shortlist?.albums?[index].artworkURLString,
                let url = URL(string: artworkURLString)
            {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: size, height: size)
                        .cornerRadius(10)
                        .clipped()
                } placeholder: {
                    placeHolderRect(with: size)
                }
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(.separator), lineWidth: 1)
                        .frame(width: size, height: size)
                    Image(systemName: "music.note.list")
                        .resizable()
                        .scaledToFit()
                        .frame(width: size * 0.3, height: size * 0.3)
                        .foregroundColor(.secondary)
                }
            }
        }
        
        @ViewBuilder
        private func loadingPlaceholder() -> some View {
            List {
                ForEach(0..<3) { _ in
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("")
                                    .skeleton(
                                        with: true,
                                        size: CGSize(width: 250, height: 25),
                                        shape: .rectangle
                                    )
                                    .cornerRadius(10)
                                Spacer()
                                Text("")
                                    .skeleton(
                                        with: true,
                                        size: CGSize(width: 60, height: 20),
                                        shape: .rectangle
                                    )
                                    .cornerRadius(8)
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 4)
                            
                            VStack(spacing: 12) {
                                HStack {
                                    placeHolderRect(with: getImageSize(for: 0))
                                    VStack {
                                        Grid {
                                            GridRow {
                                                placeHolderRect(with: getImageSize(for: 1))
                                                placeHolderRect(with: getImageSize(for: 2))
                                            }
                                            GridRow {
                                                placeHolderRect(with: getImageSize(for: 3))
                                                placeHolderRect(with: getImageSize(for: 4))
                                            }
                                        }
                                    }
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(.systemBackground))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color(.separator), lineWidth: 0.5)
                                    )
                            )
                            .cornerRadius(16)
                            .shadow(
                                color: colorScheme == .dark ? 
                                    Color.black.opacity(0.4) : 
                                    Color.black.opacity(0.1),
                                radius: colorScheme == .dark ? 12 : 8,
                                x: 0,
                                y: colorScheme == .dark ? 6 : 4
                            )
                            .padding(.horizontal)
                        }
                        .padding(.horizontal, 10)
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
            }
            .listStyle(PlainListStyle())
        }
        
        @ViewBuilder
        private func placeHolderRect(with size: CGFloat) -> some View {
            Rectangle()
                .skeleton(
                    with: true,
                    size: CGSize(width: size, height: size),
                    shape: .rectangle
                )
                .scaledToFit()
                .cornerRadius(10)
                .frame(width: size, height: size)
        }
        
        private func getImageSize(for index: Int) -> CGFloat {
            let screenWidth = UIScreen.main.bounds.width
            let imageWidth = 0.54545 * screenWidth - 54.55
            let size: CGFloat = index == 0 ? imageWidth : (imageWidth - 10) / 2
            
            return size
        }
    }
}

struct SortOrderSelectionView: View {
    let currentOrdering: ShortlistOrdering
    let onOrderingSelected: (ShortlistOrdering) -> Void
    
    var body: some View {
        NavigationView {
            List {
                ForEach(ShortlistOrdering.allCases, id: \.self) { ordering in
                    Button(action: {
                        onOrderingSelected(ordering)
                    }) {
                        HStack {
                            Text(ordering.displayName)
                                .foregroundColor(.primary)
                            Spacer()
                            if currentOrdering == ordering {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                                    .fontWeight(.semibold)
                            }
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .navigationTitle("Sort Shortlists")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onOrderingSelected(currentOrdering)
                    }
                }
            }
        }
    }
}

struct ShortlistCollections_Previews: PreviewProvider {
    static var previews: some View {
        let shortlist = TestData.ShortLists.shortList
        
        Group {
            ShortlistCollectionsView.CollectionsView(
                viewModel: ShortlistCollectionsView.ViewModel(
                    shortlists: [shortlist, shortlist, shortlist]
                ),
                isPresented: .constant(false),
                buttonOpacity: .constant(0)
            )
            .preferredColorScheme(.light)
            .previewDisplayName("Light Mode")
            
            ShortlistCollectionsView.CollectionsView(
                viewModel: ShortlistCollectionsView.ViewModel(
                    shortlists: [shortlist, shortlist, shortlist]
                ),
                isPresented: .constant(false),
                buttonOpacity: .constant(0)
            )
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
            
            SortOrderSelectionView(
                currentOrdering: .yearDescending,
                onOrderingSelected: { _ in }
            )
            .previewDisplayName("Sort Order Selection")
        }
    }
}

