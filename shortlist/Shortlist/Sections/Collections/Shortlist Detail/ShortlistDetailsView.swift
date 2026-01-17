//
//  ShortlistDetailsView.swift
//  Shortlist
//
//  Created by Dustin Bergman on 10/27/22.
//

import MessageUI
import SwiftUI
import UniformTypeIdentifiers
import Photos
import SkeletonUI

struct ShortlistDetailsView: View {
    @State private var isPresented = false
    @State var draggedAlbumId: String?
    @ObservedObject private var viewModel: ViewModel
    @State private var isEditShortlistViewPresented = false
    @State private var isShareOptionsPresented = false
    @Environment(\.dismiss) private var dismiss
    
    @State private var isShowingMailView = false
    @State private var mailSubject = ""
    @State private var mailBody = ""
    @State private var mailAttachment: Data?
    @State private var isMailDataReady = false
    
    @State private var shortlistText: String = ""
    
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var toastType: ToastView.ToastType = .success
    @Environment(\.colorScheme) private var colorScheme
    
    let layout = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    init(isPresented: Bool = false, shortlist: Shortlist) {
        viewModel = ViewModel(shortlist: shortlist)
        self.isPresented = isPresented
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if viewModel.isLoading {
                loadingView()
            } else if (viewModel.shortlist.albums?.isEmpty ?? true) {
                VStack(spacing: 16) {
                    Spacer()

                    Image(systemName: "square.stack.3d.up.slash")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 72, height: 72)
                        .foregroundColor(.secondary)
                        .accessibilityHidden(true)

                    Text("No Albums Yet")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text("Add albums to this Shortlist to get started.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 32)

                    Button {
                        isPresented.toggle()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Albums")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(colorScheme == .dark ? .black : .white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(colorScheme == .dark ? Color.white.opacity(0.9) : Color.black.opacity(0.9))
                                .overlay(
                                    Capsule()
                                        .stroke(colorScheme == .dark ? Color.black : Color.white, lineWidth: 1)
                                )
                                .shadow(
                                    color: colorScheme == .dark ?
                                        Color.black.opacity(0.5) :
                                        Color.black.opacity(0.2),
                                    radius: colorScheme == .dark ? 10 : 6,
                                    x: 0,
                                    y: colorScheme == .dark ? 4 : 2
                                )
                        )
                        .clipShape(Capsule())
                    }
                    .padding(.top, 8)

                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            } else {
                ScrollView {
                    LazyVGrid(columns: layout) {
                        ForEach(viewModel.shortlist.albums ?? [], id: \.self) { album in
                            let albumType = AlbumDetailView.AlbumType.shortlistAlbum(album)
                            NavigationLink(
                                destination: AlbumDetailView(albumType: albumType, shortlist: viewModel.shortlist)
                            ){
                                VStack(alignment: .leading) {
                                    ZStack(alignment: .topLeading) {
                                        AsyncImage(url: URL(string: album.artworkURLString)) { image in
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .cornerRadius(20)
                                        } placeholder: {
                                            ProgressView()
                                        }

                                        ZStack {
                                            Circle()
                                                .fill(colorScheme == .dark ? Color.white.opacity(0.9) : Color.black.opacity(0.75))
                                                .frame(width: 28, height: 28)
                                                .overlay(
                                                    Circle()
                                                        .stroke(colorScheme == .dark ? Color.black : Color.white, lineWidth: 1.5)
                                                )
                                                .shadow(color: colorScheme == .dark ? Color.black.opacity(0.3) : Color.black.opacity(0.4), radius: 3, x: 0, y: 2)

                                            Text("\(album.rank)")
                                                .foregroundColor(colorScheme == .dark ? .black : .white)
                                                .font(Theme.shared.avenir(size: 14, weight: .bold))
                                        }
                                        .padding(6)
                                    }
                                    .padding(.bottom, 10)

                                    Text(album.title)
                                        .font(Theme.shared.avenir(size: 16, weight: .bold))
                                        .multilineTextAlignment(.leading)
                                        .foregroundColor(.primary)
                                        .lineLimit(2)
                                    Text(album.artist)
                                        .font(Theme.shared.avenir(size: 14, weight: .medium))
                                        .multilineTextAlignment(.leading)
                                        .foregroundColor(.primary)
                                        .lineLimit(1)
                                    Spacer()
                                }
                                .frame(height: 230)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(colorScheme == .dark ? Color(.secondarySystemBackground) : Color(.systemBackground))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(colorScheme == .dark ? Color(.tertiarySystemBackground) : Color(.separator), lineWidth: 1)
                                        )
                                )
                                .cornerRadius(16)
                                .shadow(
                                    color: colorScheme == .dark ? 
                                        Color.black.opacity(0.6) : 
                                        Color.black.opacity(0.15),
                                    radius: colorScheme == .dark ? 16 : 10,
                                    x: 0,
                                    y: colorScheme == .dark ? 8 : 5
                                )
                                .padding(EdgeInsets(top: 0, leading: 6, bottom: 10, trailing: 6))
                                .onDrag {
                                    draggedAlbumId = album.id
                                    return NSItemProvider(item: nil, typeIdentifier: album.id)
                                }
                            }
                            .onDrop(
                                of: [UTType.text],
                                delegate: MyDropDelegate(
                                    updatedAlbumId: album.id,
                                    shortlistAlbums: $viewModel.shortlist.albums,
                                    draggedItem: $draggedAlbumId,
                                    viewModel: viewModel
                                )
                            )
                        }
                    }
                    .padding()
                }
            }
            
            PillControl(
                onEdit: {
                    isEditShortlistViewPresented.toggle()
                },
                onShare: {
                    isShareOptionsPresented.toggle()
                }
            )
            .padding(.bottom, 20)
            .sheet(isPresented: $isEditShortlistViewPresented) {
                EditShortlistView(
                    isPresented: $isEditShortlistViewPresented,
                    shortlistName: viewModel.shortlist.name,
                    selectedYear: viewModel.shortlist.year
                )
                .environmentObject(viewModel)
                .presentationDetents([.medium, .large])
            }
            .confirmationDialog("Share Shortlist", isPresented: $isShareOptionsPresented, titleVisibility: .visible) {
                Button("Save Image to Photos") {
                    Task {
                        await saveImageToPhotos()
                    }
                }
                
                Button("Copy Shortlist Album text") {
                    Task {
                        await copyShortlistText()
                    }
                }
                
                Button("Share via Email") {
                    Task {
                        await generateShortlistEmail()
                    }
                }
                Button("Cancel", role: .cancel) {}
            }
        }
        .sheet(isPresented: $isShowingMailView) {
            MailView(
                subject: mailSubject,
                messageBody: mailBody,
                isHTML: true,
                attachment: mailAttachment,
                attachmentMimeType: "image/jpeg",
                attachmentFilename: "shortlist.jpg"
            )
        }
        .overlay(
            // Toast notification positioned at bottom of navigation bar
            ToastOverlay(
                showToast: $showToast,
                toastMessage: $toastMessage,
                toastType: $toastType
            )
        )
        .onChange(of: isMailDataReady) { oldValue, newValue in
            if newValue && MFMailComposeViewController.canSendMail() {
                isShowingMailView = true
                isMailDataReady = false
            }
        }
        .navigationTitle(viewModel.shortlist.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                CustomBarButton(systemName: "plus.magnifyingglass") {
                    isPresented.toggle()
                }
            }
        }
        .fullScreenCover(isPresented: $isPresented, onDismiss: {
            Task {
                try await viewModel.getAlbums(for: viewModel.shortlist)
            }
        }, content: {
            SearchMusicView(isPresented: $isPresented, shortlist: viewModel.shortlist)
        })
        
        .onAppear() {
            viewModel.isLoading = true
            Task {
                try await viewModel.getAlbums(for: viewModel.shortlist)
            }
        }
        .environmentObject(viewModel)
    }
    
    @ViewBuilder
    private func loadingView() -> some View {
        ScrollView {
            LazyVGrid(columns: layout) {
                ForEach(0..<6, id: \.self) { _ in
                    VStack(alignment: .leading) {
                        ZStack(alignment: .topLeading) {
                            Rectangle()
                                .skeleton(
                                    with: true,
                                    size: CGSize(width: 150, height: 150),
                                    shape: .rectangle
                                )
                                .cornerRadius(20)
                            
                            ZStack {
                                Circle()
                                    .fill(colorScheme == .dark ? Color.white.opacity(0.9) : Color.black.opacity(0.75))
                                    .frame(width: 28, height: 28)
                                    .overlay(
                                        Circle()
                                            .stroke(colorScheme == .dark ? Color.black : Color.white, lineWidth: 1.5)
                                    )
                                    .shadow(color: colorScheme == .dark ? Color.black.opacity(0.3) : Color.black.opacity(0.4), radius: 3, x: 0, y: 2)
                                
                                Rectangle()
                                    .skeleton(
                                        with: true,
                                        size: CGSize(width: 16, height: 16),
                                        shape: .rectangle
                                    )
                                    .cornerRadius(8)
                            }
                            .padding(6)
                        }
                        .padding(.bottom, 10)
                        
                        Rectangle()
                            .skeleton(
                                with: true,
                                size: CGSize(width: 120, height: 16),
                                shape: .rectangle
                            )
                            .cornerRadius(4)
                        
                        Rectangle()
                            .skeleton(
                                with: true,
                                size: CGSize(width: 100, height: 14),
                                shape: .rectangle
                            )
                            .cornerRadius(4)
                        
                        Spacer()
                    }
                    .frame(height: 230)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(colorScheme == .dark ? Color(.secondarySystemBackground) : Color(.systemBackground))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(colorScheme == .dark ? Color(.tertiarySystemBackground) : Color(.separator), lineWidth: 1)
                            )
                    )
                    .cornerRadius(16)
                    .shadow(
                        color: colorScheme == .dark ? 
                            Color.black.opacity(0.6) : 
                            Color.black.opacity(0.15),
                        radius: colorScheme == .dark ? 16 : 10,
                        x: 0,
                        y: colorScheme == .dark ? 8 : 5
                    )
                    .padding(EdgeInsets(top: 0, leading: 6, bottom: 10, trailing: 6))
                }
            }
            .padding()
        }
    }
    
    struct MyDropDelegate: DropDelegate {
        let updatedAlbumId: String
        @Binding var shortlistAlbums: [ShortlistAlbum]?
        @Binding var draggedItem: String?
        @ObservedObject var viewModel: ViewModel
        
        func performDrop(info: DropInfo) -> Bool {
            guard let shortlistAlbums = shortlistAlbums else { return true }
            
            Task {
                try await viewModel.updateShortlistAlbumRanking(sortedAlbums: shortlistAlbums)
            }
            
            return true
        }
        
        func dropEntered(info: DropInfo) {
            guard
                let draggedItem = self.draggedItem
            else { return }
            
            if draggedItem != updatedAlbumId {
                guard
                    let from = shortlistAlbums?.firstIndex(where: { $0.id == draggedItem }),
                    let to = shortlistAlbums?.firstIndex(where: { $0.id == updatedAlbumId })
                else { return }
                
                withAnimation(.default) {
                    shortlistAlbums?.move(fromOffsets: IndexSet(integer: from), toOffset: to > from ? to + 1 : to)
                }
            }
        }
        
        func dropUpdated(info: DropInfo) -> DropProposal? {
            return DropProposal(operation: .move)
        }
    }
}

extension ShortlistDetailsView {
    private func generateShortlistEmail() async {
        guard let albums = viewModel.shortlist.albums else { return }
        
        let emailBody = createShortlistEmailBody(
            from: albums,
            shortlistName: viewModel.shortlist.name,
            year: viewModel.shortlist.year
        )
        
        let images = await loadImagesFromRemoteURLs()
        
        let imageGridCreator = ImageGridCreator()
        let gridImage = await imageGridCreator.createSquareImageGrid(
            from: images,
            outputSize: CGSize(width: 1024, height: 1024)
        )
        
        mailSubject = "Shortlist: \(viewModel.shortlist.name)"
        mailBody = emailBody
        mailAttachment = gridImage?.jpegData(compressionQuality: 0.8)
        
        isMailDataReady = true
    }
    
    private func saveImageToPhotos() async {
        let images = await loadImagesFromRemoteURLs()
        
        let imageGridCreator = ImageGridCreator()
        let gridImage = await imageGridCreator.createSquareImageGrid(
            from: images,
            outputSize: CGSize(width: 1024, height: 1024)
        )
        
        guard let image = gridImage else {
            print("⚠️ Failed to create image grid")
            return
        }
        
        // Save image to photos using simple approach
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        
        await MainActor.run {
            toastMessage = "Shortlist image saved to Photos"
            toastType = .success
            
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                showToast = true
            }
            
            // Auto-hide toast after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    showToast = false
                }
            }
        }
    }
    
    private func copyShortlistText() async {
        guard let albums = viewModel.shortlist.albums else { 
            print("⚠️ No albums found")
            return 
        }
        
        let copyText = createShortlistPlainText(
            from: albums,
            shortlistName: viewModel.shortlist.name,
            year: viewModel.shortlist.year
        )
        
        UIPasteboard.general.string = copyText
        shortlistText = copyText
        
        await MainActor.run {
            toastMessage = "Shortlist text copied to clipboard"
            toastType = .success
            
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                showToast = true
            }
            
            // Auto-hide toast after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    showToast = false
                }
            }
            
            print("Shortlist text copied to clipboard")
        }
    }
    
    private func createShortlistEmailBody(from albums: [ShortlistAlbum], shortlistName: String, year: String?) -> String {
        let header = """
        <h2>🎵 My Shortlist: \(shortlistName)\(year != nil ? " (\(year!))" : "")</h2>
        <ul>
        """
        
        let sortedAlbums = albums.sorted(by: { $0.rank < $1.rank })
        
        let items = sortedAlbums.map { album in
            """
            <li><strong>\(album.rank).</strong> \(album.title) – \(album.artist)</li>
            """
        }.joined(separator: "\n")
        
        let footer = "</ul>"
        
        return header + items + footer
    }
    
    private func createShortlistPlainText(from albums: [ShortlistAlbum], shortlistName: String, year: String?) -> String {
        let sortedAlbums = albums.sorted(by: { $0.rank < $1.rank })
        
        let header = "🎵 Shortlist: \(shortlistName)\(year != nil ? " (\(year!))" : "")"
        let items = sortedAlbums.map { "\($0.rank). \($0.title) – \($0.artist)" }.joined(separator: "\n")
        
        return "\(header)\n\n\(items)"
    }
    
    private func loadImagesFromRemoteURLs() async -> [UIImage] {
        guard let albums = viewModel.shortlist.albums else { return [] }
        
        return await withTaskGroup(of: (Int, UIImage?).self) { group in
            let sortedAlbums = albums.sorted(by: { $0.rank < $1.rank })
            let artworkURLs: [(Int, URL)] = sortedAlbums
                .enumerated()
                .compactMap { index, album in
                    guard let url = URL(string: album.artworkURLString) else { return nil }
                    return (index, url)
                }
            
            for (index, url) in artworkURLs {
                group.addTask {
                    do {
                        let (data, _) = try await URLSession.shared.data(from: url)
                        return (index, UIImage(data: data))
                    } catch {
                        print("⚠️ Failed to load image from: \(url) – \(error)")
                        return (index, nil)
                    }
                }
            }
            
            var imageDict: [Int: UIImage] = [:]
            for await (index, image) in group {
                if let img = image {
                    imageDict[index] = img
                }
            }
            
            // Reconstruct array in correct order
            return artworkURLs.compactMap { index, _ in imageDict[index] }
        }
    }
}

struct ShortlistDetails_Previews: PreviewProvider {
    static var previews: some View {
        ShortlistDetailsView(shortlist: TestData.ShortLists.shortList)
            .preferredColorScheme(.light)
            .previewDisplayName("Light Mode")
        
        ShortlistDetailsView(shortlist: TestData.ShortLists.shortList)
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
    }
}

