//
//  DisplayItemsView.swift
//  GroceryShoppingList
//
//  Created by Marisol on 4/4/25.
//

import SwiftUI
import SwiftData

class DisplayItemsViewModel: ObservableObject {
    
    // Function to add a grocery item to a list
    func addItem(itemToAddName: String, itemToAddCategory: GroceryCategory, itemToAddNotes: String?, from groceryList: GroceryList, to modelContext: ModelContext) {
        withAnimation {
            let newItem = GroceryItem(name: itemToAddName, category: itemToAddCategory, notes: itemToAddNotes)
            groceryList.groceryItems.append(newItem)
            modelContext.insert(newItem)
            try? modelContext.save()
        }
    }
    
    // Function to delete a grocery item from a list
    func deleteItem(offsets: IndexSet, from groceryList: GroceryList, to modelContext: ModelContext) {
        withAnimation {
            for index in offsets {
                modelContext.delete(groceryList.groceryItems[index])
                try? modelContext.save()
            }
        }
    }
}

struct DisplayItemsView: View {
    @Bindable var groceryList: GroceryList
    @Environment(\.modelContext) private var modelContext
    
    @State private var message: String = ""
    @State private var addGroceryItemSheetView = false
    
    @State private var addGroceryItemName: String = "" // for the name of the grocery item to add
    @State private var addGroceryItemCategory: GroceryCategory = .other
    @State private var addGroceryItemNotes: String = ""
    
    @StateObject private var displayItemsViewModel = DisplayItemsViewModel() // view model
    
    // Search for item
    @Query private var items: [GroceryItem]
    @State private var searchQuery:String = ""
    var filteredGroceryItems: [GroceryItem] {
        if searchQuery.isEmpty {
            return groceryList.groceryItems
        } else {
            return groceryList.groceryItems.filter {
                $0.name.localizedCaseInsensitiveContains(searchQuery)
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack {
                // Display each item from the grocery list with their corresponding category
                List {
                    ForEach(GroceryCategory.allCases, id: \.self) { category in
                        let categoryGroceryItems = filteredGroceryItems.filter { $0.category == category }
                        // Display all items for each category
                        if !categoryGroceryItems.isEmpty {
                            Section(header: Text(category.rawValue)) {
                                ForEach(categoryGroceryItems) { item in
                                    VStack(alignment: .leading) {
                                        Text(item.name).fontWeight(.semibold)
                                            .minimumScaleFactor(0.5)
                                        if let notes = item.notes, !notes.isEmpty {
                                            Text("Notes: \(notes)").font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }.onDelete { indexSet in
                                    for i in indexSet {
                                        let removeItem = categoryGroceryItems[i]
                                        // Delete first in the categoryItems and then in the original groceryItems
                                        if let groceryItemsIndex = groceryList.groceryItems.firstIndex(where: { $0.id == removeItem.id })
                                        {
                                            displayItemsViewModel.deleteItem(offsets: IndexSet(integer: groceryItemsIndex), from: groceryList, to: modelContext)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }.searchable(text: $searchQuery, prompt: "Search for an item")
                    .listStyle(InsetGroupedListStyle())
                // Get Nutritional Facts
                NavigationLink(destination: NutritionalFactsView())
                {
                    Label("Get Nutritional Facts", systemImage: "fork.knife").padding().foregroundColor(Color("DefaultColor"))
                }
                
            }.navigationTitle("Items for \(groceryList.name)")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { addGroceryItemSheetView = true }) {
                            Image(systemName: "plus")
                        }
                    }
                }.sheet(isPresented: $addGroceryItemSheetView) {
                VStack {
                    Text("Add Grocery Item").font(.title2).bold(true).padding(.bottom, 15)
                    Text(message).foregroundColor(.red)
                    // Enter item name
                    TextField("Name", text: $addGroceryItemName).autocorrectionDisabled().padding().overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray)
                    )
                    // Enter notes
                    TextField("Notes (Optional)", text: $addGroceryItemNotes).autocorrectionDisabled().padding().overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray)
                    )
                    // Select a category for the item to be added
                    HStack {
                        Text("Select category:").padding()
                        Picker("Category", selection: $addGroceryItemCategory) {
                            ForEach(GroceryCategory.allCases, id: \.self) { category in
                                Text(category.rawValue).tag(category)
                            }
                        }.pickerStyle(MenuPickerStyle()).padding()
                        Spacer()
                    }
                    
                    HStack {
                        Spacer()
                        // Add the item
                        Button("Add") {
                            if addGroceryItemName.isEmpty {
                                message = "Enter a name"
                                return
                            }
                            displayItemsViewModel.addItem(itemToAddName: addGroceryItemName,
                                                          itemToAddCategory: addGroceryItemCategory,
                                                          itemToAddNotes: addGroceryItemNotes, from: groceryList, to: modelContext)
                            addGroceryItemSheetView = false
                            
                            // Reset fields
                            addGroceryItemName = ""
                            addGroceryItemCategory = .other
                            addGroceryItemNotes = ""
                            
                        }.frame(width: 100).padding()
                            .background(RoundedRectangle(cornerRadius: 8).fill(Color("DefaultColor")))
                            .foregroundColor(.white)
                        Spacer()
                        Button("Cancel") {
                            addGroceryItemSheetView = false // Close the sheet
                        }.frame(width: 100).padding()
                            .background(RoundedRectangle(cornerRadius: 8).fill(Color("DefaultColor")))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    
                }.padding()
                
            }
        }
            
    }
}


/*#Preview {
    DisplayItemsView()
        .modelContainer(for: [GroceryItem.self, GroceryList.self], inMemory: true)
}*/
