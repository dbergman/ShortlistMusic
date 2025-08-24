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
    @State private var toastType: ToastType = .success
    
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
                                            .fill(Color.black.opacity(0.75))
                                            .frame(width: 28, height: 28)
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.white.opacity(0.8), lineWidth: 1.5)
                                            )
                                            .shadow(color: Color.black.opacity(0.4), radius: 3, x: 0, y: 2)
                                        
                                        Text("\(album.rank)")
                                            .foregroundColor(.white)
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
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
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
            // Toast notification
            VStack {
                if showToast {
                    HStack(spacing: 12) {
                        Image(systemName: toastType.icon)
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .semibold))
                        
                        Text(toastMessage)
                            .foregroundColor(.white)
                            .font(.system(size: 14, weight: .medium))
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(toastType.backgroundColor)
                    .cornerRadius(8)
                    .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                    .padding(.horizontal, 20)
                    .padding(.top, 60) // Below navigation bar
                    .offset(y: showToast ? 0 : -100) // Start above screen
                    .opacity(showToast ? 1 : 0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showToast)
                }
                Spacer()
            }
        )
        .onChange(of: isMailDataReady) { oldValue, newValue in
            if newValue && MFMailComposeViewController.canSendMail() {
                isShowingMailView = true
                isMailDataReady = false
            }
        }
        .navigationTitle(viewModel.shortlist.name)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(
            leading: CustomBarButton.backButton {
                dismiss()
            },
            trailing: CustomBarButton(systemName: "plus.magnifyingglass") {
                isPresented.toggle()
            }
        )
        .fullScreenCover(isPresented: $isPresented, onDismiss: {
            Task {
                try await viewModel.getAlbums(for: viewModel.shortlist)
            }
        }, content: {
            SearchMusicView(isPresented: $isPresented, shortlist: viewModel.shortlist)
        })
        
        .onAppear() {
            Task {
                try await viewModel.getAlbums(for: viewModel.shortlist)
            }
        }
        .environmentObject(viewModel)
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
        toastMessage = "Shortlist image saved to Photos! 📸"
        toastType = .success
        showToast = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            showToast = false
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
            toastMessage = "Shortlist text copied to clipboard! 📋"
            toastType = .success
            showToast = true
            
            // Auto-hide toast after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                showToast = false
            }
            
            print("📋 Shortlist text copied to clipboard")
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
        
        return await withTaskGroup(of: UIImage?.self) { group in
            let artworkURLs: [URL] = albums
                .sorted(by: { $0.rank < $1.rank })
                .compactMap { URL(string: $0.artworkURLString) }
            
            for url in artworkURLs {
                group.addTask {
                    do {
                        let (data, _) = try await URLSession.shared.data(from: url)
                        return UIImage(data: data)
                    } catch {
                        print("⚠️ Failed to load image from: \(url) – \(error)")
                        return nil
                    }
                }
            }
            
            var images: [UIImage] = []
            for await image in group {
                if let img = image {
                    images.append(img)
                }
            }
            return images
        }
    }
}

struct ShortlistDetails_Previews: PreviewProvider {
    static var previews: some View {
        return ShortlistDetailsView(shortlist: TestData.ShortLists.shortList)
    }
}
