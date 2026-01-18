//
//  EditShortlistView.swift
//  Shortlist
//
//  Created by Dustin Bergman on 2/24/24.
//

import SwiftUI

struct EditShortlistView: View {
    @Binding var isPresented: Bool
    @FocusState private var focus: Bool
    @ObservedObject private var viewModel = ViewModel()
    @EnvironmentObject var shortlistDetailsVM: ShortlistDetailsView.ViewModel
    
    @State var shortlistName: String
    @State var selectedYear: String
    
    var body: some View {
        NavigationStack {
            Form {
                !viewModel.editShortlistError.isEmpty ? Section(header: Text("Error")
                    .font(Theme.shared.avenir(size: 14, weight: .semibold)))  {
                        Text("\(viewModel.editShortlistError)")
                            .font(Theme.shared.avenir(size: 14, weight: .medium))
                            .foregroundColor(.red)
                            .animation(.easeIn)
                    } : nil
                Section(header: Text("Shortlist Details")
                    .font(Theme.shared.avenir(size: 18, weight: .bold))) {
                        TextField("Shortlist Name", text:  $shortlistName)
                            .focused($focus)
                            .disabled(viewModel.isUpdating)
                            .toolbar {
                                ToolbarItemGroup(placement: .keyboard) {
                                    Button("Done") {
                                        focus = false
                                    }
                                    Spacer()
                                }
                            }
                        Picker("Shortlist Year", selection: $selectedYear) {
                            ForEach(generateShortlistYears(), id: \.self) {
                                Text($0)
                            }
                        }
                        .disabled(viewModel.isUpdating)
                    }
                Section {
                    Button(action: {
                        // Store original values for potential revert
                        let originalShortlist = shortlistDetailsVM.shortlist
                        
                        // Optimistically update the UI immediately
                        let optimisticShortlist = originalShortlist.updating(name: shortlistName, year: selectedYear)
                        
                        // Update UI immediately for instant feedback
                        shortlistDetailsVM.shortlist = optimisticShortlist
                        
                        let dismissSheet = {
                            isPresented = false
                        }
                        
                        Task { @MainActor in
                            do {
                                // Perform the actual CloudKit update with retry logic
                                let shortlist = try await viewModel.updateNewShortlist(
                                    shortlist: optimisticShortlist,
                                    updatedName: shortlistName,
                                    updatedYear: selectedYear
                                )
                                
                                // Update with the confirmed data from CloudKit
                                shortlistDetailsVM.shortlist = shortlist
                                
                                // Small delay to ensure UI updates before dismissing
                                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
                                dismissSheet()
                                
                            } catch {
                                // On error, revert to the original values
                                shortlistDetailsVM.shortlist = originalShortlist
                                // The error is already displayed in the viewModel
                            }
                        }
                    }, label: {
                        HStack {
                            Spacer()
                            if viewModel.isUpdating {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .scaleEffect(0.8)
                                Text("Updating...")
                                    .font(Theme.shared.avenir(size: 16, weight: .bold))
                                    .foregroundColor(.primary)
                                    .padding(.leading, 8)
                            } else {
                                Text("Update")
                                    .font(Theme.shared.avenir(size: 16, weight: .bold))
                                    .foregroundColor(.primary)
                            }
                            Spacer()
                        }
                    })
                    .disabled(shortlistName.isEmpty || shortlistName.count < 5 || viewModel.isUpdating)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Edit Shortlist")
                        .font(Theme.shared.avenir(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {
                        isPresented = false
                    }) {
                        Text("Cancel")
                            .font(Theme.shared.avenir(size: 16, weight: .regular))
                            .foregroundColor(.primary)
                    }
                }
            }
        }
    }
    
    
    private func generateShortlistYears() -> [String] {
        let currentYear = Calendar.current.component(.year, from: Date())
        
        var years = ["All"]
        years.append("\(currentYear)")
        
        repeat {
            guard let lastYear = years.last, let lastYearInt = Int(lastYear) else { continue }
            
            years.append("\(lastYearInt - 1)")
        } while years.last != "1955"
        
        return years
    }
}

struct EditShortlistView_Previews: PreviewProvider {
    static var previews: some View {
        EditShortlistView(
            isPresented: .constant(false),
            shortlistName: TestData.ShortLists.shortList.name,
            selectedYear: TestData.ShortLists.shortList.year)
    }
}
