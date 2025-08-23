//
//  ShortlistCollectionsView.swift
//  Shortlist
//
//  Created by Dustin Bergman on 10/27/22.
//

import SkeletonUI
import SwiftUI

struct ShortlistCollectionsView: View {
    @State var isPresented = false
    @State private var buttonOpacity: Double = 0
    @ObservedObject private var viewModel = ViewModel()
    
    var body: some View {
        NavigationStack {
            CollectionsView(viewModel: viewModel, isPresented: $isPresented, buttonOpacity: $buttonOpacity)
                .navigationTitle("My ShortLists")
                .task {
                    await MusicPermission.shared.requestMusicKitAuthorization()
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            print("Order shortlists button was tapped")
                        } label: {
                            Image(systemName: "arrow.up.arrow.down")
                        }
                        .tint(.primary)
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            print("Share shortlists button was tapped")
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                        }
                        .tint(.primary)
                    }
                }
                .onBoardingSheet()
                .sheet(isPresented: $isPresented) {
                    CreateShortlistView(isPresented: $isPresented, shortlists: $viewModel.shortlists)
                        .presentationDetents([.medium, .large])
                }.onAppear() {
                    Task {
                        try? await viewModel.getShortlists()
                    }
                }
        }
    }
}

extension ShortlistCollectionsView {
    struct CollectionsView: View {
        @ObservedObject private var viewModel: ViewModel
        @Binding var isPresented: Bool
        @Binding var buttonOpacity: Double
        
        init(viewModel: ViewModel, isPresented: Binding<Bool>, buttonOpacity: Binding<Double>) {
            self.viewModel = viewModel
            self._isPresented = isPresented
            self._buttonOpacity = buttonOpacity
        }
        
        var body: some View {
            if viewModel.isloading {
                loadingPlaceholder()
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(viewModel.shortlists, id: \.self) { shortlist in
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text(shortlist.name)
                                        .font(Theme.shared.avenir(size: 20, weight: .bold))
                                        .fontWeight(.bold)
                                    Spacer()
                                    
                                    if shortlist.year != "All" {
                                        Text(shortlist.year)
                                            .font(Theme.shared.avenir(size: 14, weight: .medium))
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(.horizontal)
                                NavigationLink(destination: ShortlistDetailsView(shortlist: shortlist)) {
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
                                    .background(Color.white)
                                    .cornerRadius(16)
                                    .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                                    .padding(.horizontal)
                                }
                            }
                            .padding(.horizontal, 10)
                        }
                    }
                    .padding(.vertical)
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
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(Color.primary)
                                .clipShape(Capsule())
                                .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
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
                        .stroke(Color.gray, lineWidth: 1)
                        .frame(width: size, height: size)
                    Image(systemName: "music.note.list")
                        .resizable()
                        .scaledToFit()
                        .frame(width: size * 0.3, height: size * 0.3)
                        .foregroundColor(.gray)
                }
            }
        }
        
        @ViewBuilder
        private func loadingPlaceholder() -> some View {
            ScrollView {
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
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                            .padding(.horizontal)
                        }
                        .padding(.horizontal, 10)
                        
                    }
                    .padding(.vertical)
                }
            }
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
        
        private func delete(at offsets: IndexSet) {
            guard let index = offsets.first else { return }
            
            let shortlist = viewModel.shortlists[index]
            
            Task {
                try? await viewModel.remove(shortlist: shortlist)
            }
            
        }
        
        private func getImageSize(for index: Int) -> CGFloat {
            let screenWidth = UIScreen.main.bounds.width
            let imageWidth = 0.54545 * screenWidth - 54.55
            let size: CGFloat = index == 0 ? imageWidth : (imageWidth - 10) / 2
            
            return size
        }
    }
}

struct ShortlistCollections_Previews: PreviewProvider {
    static var previews: some View {
        let shortlist = TestData.ShortLists.shortList
        
        return ShortlistCollectionsView.CollectionsView(
            viewModel: ShortlistCollectionsView.ViewModel(
                shortlists: [shortlist, shortlist, shortlist]
            ),
            isPresented: .constant(false),
            buttonOpacity: .constant(0)
        )
    }
}
