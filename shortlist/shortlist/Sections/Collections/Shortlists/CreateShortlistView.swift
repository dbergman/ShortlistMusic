//
//  CreateShortlistView.swift
//  shortlist
//
//  Created by Dustin Bergman on 12/28/22.
//

import SwiftUI

struct CreateShortlistView: View {
    @Binding var isPresented: Bool
    @State private var shortlistName = ""
    @State private var selectedYear = "All"
    @FocusState private var focus: Bool
    
    var body: some View {
        NavigationStack {
            Form {
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
                        isPresented = false
                    }, label: {
                        HStack {
                            Spacer()
                            Text("Create")
                            Spacer()
                        }
                    })
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
        CreateShortlistView(isPresented: .constant(false))
    }
}
