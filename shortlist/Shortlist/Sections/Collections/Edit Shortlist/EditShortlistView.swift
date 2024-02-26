//
//  EditShortlistView.swift
//  Shortlist
//
//  Created by Dustin Bergman on 2/24/24.
//

import SwiftUI

struct EditShortlistView: View {
    struct Content {
        let shortlistName: String
        let shortlistYear: String
    }
    
    @Binding var isPresented: Bool
    @FocusState private var focus: Bool
    @ObservedObject private var viewModel = ViewModel()
    @Binding var shortlist: Shortlist
    
    @State var shortlistName: String
    @State var selectedYear: String
    
    var body: some View {
        NavigationStack {
            Form {
                !viewModel.editShortlistError.isEmpty ? Section(header: Text("Error")) {
                    Text("\(viewModel.editShortlistError)")
                        .foregroundColor(.red)
                        .animation(.easeIn)
                } : nil
                Section(header: Text("Shortlist Details")) {
                    TextField("Shortlist Name", text:  $shortlistName)
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
                            viewModel.updateNewShortlist(shortlist: shortlist, updatedName: shortlistName, updatedYear: selectedYear, completion: { _ in
                                self.isPresented = false
                            })
                        }
                    }, label: {
                        HStack {
                            Spacer()
                            Text("Update")
                            Spacer()
                        }
                    })
                    .disabled(shortlistName.isEmpty || shortlistName.count < 5)
                }
            }
            .navigationTitle("Edit Shortlist")
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

struct EditShortlistView_Previews: PreviewProvider {
    static var previews: some View {
        EditShortlistView(
            isPresented: .constant(false),
            shortlist: .constant(TestData.ShortLists.shortList),
            shortlistName: TestData.ShortLists.shortList.name,
            selectedYear: TestData.ShortLists.shortList.year)
    }
}
