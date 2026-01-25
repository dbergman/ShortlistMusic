//
//  SearchMusicView.swift
//  Shortlist
//
//  Created by Dustin Bergman on 10/27/22.
//

import MusicKit
import SwiftUI

extension SearchMusicView {
    struct Content {
        struct Artist: Hashable, Identifiable {
            let id = UUID()
            let name: String
            let artistImageURL: URL?
            let musicKitArtist: MusicKit.Artist?
        }
        
        struct Album: Hashable, Identifiable {
            let id = UUID()
            let name: String
            let artworkURL: URL?
            let artist: String
            let releaseYear: String
            let musicKitAlbum: MusicKit.Album?
        }
    }
}

extension SearchMusicView {
    enum Route: Hashable {
        case artist(Content.Artist)
        case album(Content.Album)
    }
}

struct SearchMusicView: View {
    @Binding var isPresented: Bool
    @StateObject private var viewModel = ViewModel()
    @State private var searchTerm = ""
    @State private var filterByYear = true
    @State private var selectedYears: Set<String> = []
    @State private var showingYearPicker = false
    @Environment(\.colorScheme) private var colorScheme
    let shortlist: Shortlist
    
    private var filteredAlbums: [Content.Album] {
        if shouldShowSpecificYearFilter && filterByYear {
            // Filter by shortlist's specific year
            return viewModel.albums.filter { $0.releaseYear == shortlist.year }
        } else if shouldShowYearPickerFilter && !selectedYears.isEmpty {
            // Filter by selected years from popup
            return viewModel.albums.filter { selectedYears.contains($0.releaseYear) }
        } else {
            return viewModel.albums
        }
    }
    
    private var shouldShowSpecificYearFilter: Bool {
        !shortlist.year.isEmpty && shortlist.year != "All"
    }
    
    private var shouldShowYearPickerFilter: Bool {
        shortlist.year.isEmpty || shortlist.year == "All"
    }
    
    private var availableYears: [String] {
        let currentYear = Calendar.current.component(.year, from: Date())
        var years: [String] = []
        years.append("\(currentYear)")
        
        repeat {
            guard let lastYear = years.last, let lastYearInt = Int(lastYear) else { continue }
            years.append("\(lastYearInt - 1)")
        } while years.last != "1955"
        
        return years
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if shouldShowSpecificYearFilter {
                    HStack {
                        Toggle(isOn: $filterByYear) {
                            Text("Filter by \(shortlist.year)")
                                .font(Theme.shared.avenir(size: 16, weight: .medium))
                                .foregroundColor(.primary)
                        }
                        .tint(.blue)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                    }
                    .background(Color(.secondarySystemBackground))
                } else if shouldShowYearPickerFilter {
                    HStack {
                        Button {
                            showingYearPicker = true
                        } label: {
                            HStack {
                                Image(systemName: selectedYears.isEmpty ? "line.3.horizontal.decrease" : "line.3.horizontal.decrease.circle.fill")
                                    .foregroundColor(selectedYears.isEmpty ? .primary : .blue)
                                Text(selectedYears.isEmpty ? "Filter by Year" : "\(selectedYears.count) year\(selectedYears.count == 1 ? "" : "s") selected")
                                    .font(Theme.shared.avenir(size: 16, weight: .medium))
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                        }
                    }
                    .background(Color(.secondarySystemBackground))
                }
                
                SearchResultsList(albums: filteredAlbums, searchTerm: searchTerm)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            Text("Add to ShortList")
                                .font(Theme.shared.avenir(size: 22, weight: .bold))
                                .foregroundColor(.primary)
                        }
                    }
                    .navigationDestination(for: SearchMusicView.Route.self) { route in
                        switch route {
                        case .album(let album):
                            if let albumMK = album.musicKitAlbum {
                                let albumType = AlbumDetailView.AlbumType.musicKit(albumMK)
                                AlbumDetailView(albumType:  albumType, shortlist: shortlist, isPresented: $isPresented)
                            }
                            
                        case .artist(let artist):
                            if let artistMK = artist.musicKitArtist {
                                SearchAlbumsView(artist: artistMK, shortlist: shortlist, isPresented: $isPresented)
                            }
                        }
                    }
                    .toolbar {
                        Button("Done") {
                            isPresented = false
                        }
                        .font(Theme.shared.avenir(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    }
            }
        }
        .searchable(text: $searchTerm, prompt: "Search by Artist")
        .onAppear {
            // Log screen view analytics
            AnalyticsManager.shared.logScreenView(
                screenName: "Search Music",
                screenClass: "SearchMusicView"
            )
        }
        .onChange(of: searchTerm) { _, newValue in
            requestUpdatedSearchResults(for: newValue)
        }
        .sheet(isPresented: $showingYearPicker) {
            YearPickerView(selectedYears: $selectedYears, availableYears: availableYears)
        }
        .tint(.primary)
    }
    
    private func requestUpdatedSearchResults(for searchTerm: String) {
        Task {
            if searchTerm.isEmpty {
                self.viewModel.resetResults()
            } else {
                await viewModel.performSearch(for: searchTerm)
            }
        }
    }
}

extension SearchMusicView {
    struct YearPickerView: View {
        @Binding var selectedYears: Set<String>
        let availableYears: [String]
        @Environment(\.dismiss) private var dismiss
        @Environment(\.colorScheme) private var colorScheme
        
        var body: some View {
            NavigationStack {
                List {
                    ForEach(availableYears, id: \.self) { year in
                        Button {
                            if selectedYears.contains(year) {
                                selectedYears.remove(year)
                            } else {
                                selectedYears.insert(year)
                            }
                        } label: {
                            HStack {
                                Text(year)
                                    .font(Theme.shared.avenir(size: 16, weight: .medium))
                                    .foregroundColor(.primary)
                                Spacer()
                                if selectedYears.contains(year) {
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
                .navigationTitle("Filter by Year")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Clear") {
                            selectedYears.removeAll()
                        }
                        .font(Theme.shared.avenir(size: 16, weight: .medium))
                        .foregroundColor(.blue)
                        .disabled(selectedYears.isEmpty)
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                        .font(Theme.shared.avenir(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    }
                }
            }
        }
    }
}

extension SearchMusicView {
    struct SearchResultsList: View {
        private let albums: [Content.Album]
        private let searchTerm: String
        @Environment(\.colorScheme) private var colorScheme

        init(albums: [Content.Album], searchTerm: String) {
            self.albums = albums
            self.searchTerm = searchTerm
        }

        var body: some View {
            if albums.isEmpty {
                emptyStateView(hasSearched: !searchTerm.isEmpty)
            } else {
                List {
                    Section {
                        ForEach(albums) { album in
                            ZStack {
                                NavigationLink(value: SearchMusicView.Route.album(album)) {
                                    EmptyView()
                                }
                                .opacity(0)

                                HStack {
                                    SearchMusicView.SearchMusicAlbumCell(album: album)

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .foregroundColor(colorScheme == .dark ? .white.opacity(0.6) : .gray)
                                        .imageScale(.small)
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(colorScheme == .dark ? Color(.secondarySystemBackground) : Color(.systemBackground))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(colorScheme == .dark ? Color(.tertiarySystemBackground) : Color(.separator), lineWidth: 1)
                                        )
                                        .shadow(
                                            color: colorScheme == .dark ? Color.black.opacity(0.3) : Color.black.opacity(0.1),
                                            radius: colorScheme == .dark ? 6 : 4,
                                            x: 0,
                                            y: colorScheme == .dark ? 3 : 2
                                        )
                                )
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                            }
                            .listRowInsets(EdgeInsets())
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        
        @ViewBuilder
        private func emptyStateView(hasSearched: Bool) -> some View {
            VStack(spacing: 24) {
                Spacer()
                
                if hasSearched {
                    // No results message
                    VStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        
                        Text("No Results Found")
                            .font(Theme.shared.avenir(size: 24, weight: .bold))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                        
                        Text("We couldn't find any albums for \"\(searchTerm)\"")
                            .font(Theme.shared.avenir(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .lineLimit(nil)
                            .padding(.horizontal, 32)
                    }
                    
                    // Search suggestions
                    VStack(spacing: 16) {
                        Text("Try these suggestions:")
                            .font(Theme.shared.avenir(size: 14, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        VStack(spacing: 8) {
                            HStack(spacing: 12) {
                                Image(systemName: "checkmark.circle")
                                    .foregroundColor(.blue)
                                    .frame(width: 20)
                                Text("Check the spelling of the artist name")
                                    .font(Theme.shared.avenir(size: 14, weight: .regular))
                                    .foregroundColor(.secondary)
                            }
                            
                            HStack(spacing: 12) {
                                Image(systemName: "checkmark.circle")
                                    .foregroundColor(.green)
                                    .frame(width: 20)
                                Text("Try a different or more common name")
                                    .font(Theme.shared.avenir(size: 14, weight: .regular))
                                    .foregroundColor(.secondary)
                            }
                            
                            HStack(spacing: 12) {
                                Image(systemName: "checkmark.circle")
                                    .foregroundColor(.orange)
                                    .frame(width: 20)
                                Text("Search for the band name instead of solo artist")
                                    .font(Theme.shared.avenir(size: 14, weight: .regular))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                } else {
                    // Initial search message
                    VStack(spacing: 12) {
                        Text("Search for Music")
                            .font(Theme.shared.avenir(size: 24, weight: .bold))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                        
                        Text("Start typing an artist name above to discover albums and add them to your shortlist")
                            .font(Theme.shared.avenir(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .lineLimit(nil)
                            .padding(.horizontal, 32)
                    }
                    
                    // Search tips
                    VStack(spacing: 16) {
                        Text("Search Tips:")
                            .font(Theme.shared.avenir(size: 14, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        VStack(spacing: 8) {
                            HStack(spacing: 12) {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.blue)
                                    .frame(width: 20)
                                Text("Try artist names like 'The Beatles' or 'The Clash'")
                                    .font(Theme.shared.avenir(size: 14, weight: .regular))
                                    .foregroundColor(.secondary)
                            }
                            
                            HStack(spacing: 12) {
                                Image(systemName: "music.note")
                                    .foregroundColor(.green)
                                    .frame(width: 20)
                                Text("Browse albums and tap to add them to your shortlist")
                                    .font(Theme.shared.avenir(size: 14, weight: .regular))
                                    .foregroundColor(.secondary)
                            }
                            
                            HStack(spacing: 12) {
                                Image(systemName: "heart.fill")
                                    .foregroundColor(.red)
                                    .frame(width: 20)
                                Text("Discover new music and build your perfect collection")
                                    .font(Theme.shared.avenir(size: 14, weight: .regular))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                }
                
                Spacer()
            }
            .padding()
        }
    }
}




struct Previews_SearchMusicView_Previews: PreviewProvider {
    static var previews: some View {
        let albums = [
            SearchMusicView.Content.Album(
                name: "About Time (2005 Remaster)",
                artworkURL: URL(string: "https://is1-ssl.mzstatic.com/image/thumb/Music112/v4/7d/6d/18/7d6d18a5-2368-cd42-3eb3-58493c2bba01/0045778673865.png/60x60bb.jpg"),
                artist: "Pennywise",
                releaseYear: "1995",
                musicKitAlbum: nil
            ),
            SearchMusicView.Content.Album(
                name: "Full Circle (2005 Remaster)",
                artworkURL: URL(string: "https://is5-ssl.mzstatic.com/image/thumb/Music112/v4/ad/7c/9f/ad7c9f8c-1d43-2512-da06-0dcebbef60b0/0045778673902.png/60x60bb.jpg"),
                artist: "Pennywise",
                releaseYear: "1997",
                musicKitAlbum: nil
            ),
            SearchMusicView.Content.Album(
                name: "Unknown Road (2005 Remaster)",
                artworkURL: URL(string: "https://is5-ssl.mzstatic.com/image/thumb/Music112/v4/56/f3/d1/56f3d11f-682e-9bb7-6543-f5318563c2fa/0045778673766.png/60x60bb.jpg"),
                artist: "Pennywise",
                releaseYear: "1993",
                musicKitAlbum: nil
            )
        ]
        
        Group {
            SearchMusicView.SearchResultsList(albums: albums, searchTerm: "")
                .preferredColorScheme(.light)
                .previewDisplayName("Light Mode")
            
            SearchMusicView.SearchResultsList(albums: albums, searchTerm: "")
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
        }
    }
}
