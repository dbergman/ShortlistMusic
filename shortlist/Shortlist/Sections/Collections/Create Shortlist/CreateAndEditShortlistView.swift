//
//  CreateShortlistView.swift
//  Shortlist
//
//  Created by Dustin Bergman on 12/28/22.
//

import SwiftUI

struct CreateAndEditShortlistView: View {
    @Binding var isPresented: Bool
    @FocusState private var focus: Bool
    @ObservedObject private var viewModel = ViewModel()
    @State private var shortlistName = ""
    @State private var selectedYear = "All"
    @Binding var shortlists: [Shortlist]

    var body: some View {
        NavigationStack {
            Form {
                !viewModel.createShortlistError.isEmpty ? Section(header: Text("Error")) {
                   Text("\(viewModel.createShortlistError)")
                       .foregroundColor(.red)
                       .animation(.easeIn)
                } : nil
                Section(header: Text("Shortlist Details")) {
                    TextField("Shortlist Name", text: $shortlistName)
                        .focused($focus)
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
                }
                Section {
                    Button(action: {
                        Task {
                            viewModel.addNewShortlist(name: shortlistName, year: selectedYear) { shortlist in
                                DispatchQueue.main.async {
                                    self.shortlists.append(shortlist)
                                }
                                
                                self.isPresented = false
                            }
                        }
                    }, label: {
                        HStack {
                            Spacer()
                            Text("Create")
                            Spacer()
                        }
                    })
                    .disabled(shortlistName.isEmpty || shortlistName.count < 5)
                }
            }
            .navigationTitle("New Shortlist")
            .toolbar {
                Button("Cancel") {
                    isPresented = false
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

struct CreateShortlistView_Previews: PreviewProvider {
    static var previews: some View {
        CreateAndEditShortlistView(isPresented: .constant(false), shortlists: .constant([]))
    }
}
