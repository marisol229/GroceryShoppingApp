//
//  DisplayItemsView.swift
//  GroceryShoppingList
//
//  Created by Marisol on 4/4/25.
//

import SwiftUI
import SwiftData

struct DisplayItemsView: View {
    @Bindable var groceryList: GroceryList
    @Environment(\.modelContext) private var modelContext
    
    @State private var message: String = ""
    @State private var addGroceryItemSheetView = false
    
    @State private var addGroceryItemName: String = "" // for the name of the grocery item to add
    @State private var addGroceryItemCategory: GroceryCategory = .other
    @State private var addGroceryItemNotes: String = ""
    @State private var addGroceryItemIsPurchased: Bool = false

    
    var body: some View {
        
        NavigationView {
            VStack {
                // Display each item from the grocery list
                List {
                    ForEach(groceryList.groceryItems) { item in
                        Section(header: Text(item.category.rawValue)) {
                            VStack(alignment: .leading) {
                                // Display item name and notes
                                Text(item.name).font(.headline)
                                if let notes = item.notes, !notes.isEmpty {
                                        Text("Notes: \(notes)").font(.subheadline).foregroundColor(.gray)
                                }
                            }.padding(.vertical, 2)
                        }
                    }
                    .onDelete(perform: deleteItem)
                }
                // Get Nutritional Facts
                NavigationLink(destination: NutritionalFactsView())
                {
                    Label("Get Nutritional Facts", systemImage: "fork.knife").padding().foregroundColor(Color("DefaultColor"))
                }
                
            }.sheet(isPresented: $addGroceryItemSheetView) {
                VStack {
                    Text("Add Grocery Item").font(.title2).bold(true)
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
                    // Select if the item is purchased or not
                    Toggle("Is Purchased", isOn: $addGroceryItemIsPurchased).padding()
                        
                    // Add the item
                    Button("Add") {
                        if addGroceryItemName.isEmpty {
                            message = "Enter a name"
                            return
                        }
                        addItem(itemToAddName: addGroceryItemName,
                                itemToAddCategory: addGroceryItemCategory,
                                itemToAddNotes: addGroceryItemNotes,
                                itemToAddIsPurchased: addGroceryItemIsPurchased)
                        addGroceryItemSheetView = false
                        
                        // Reset fields
                        addGroceryItemName = ""
                        addGroceryItemCategory = .other
                        addGroceryItemNotes = ""
                        addGroceryItemIsPurchased = false
                        
                    }
                    .padding()

                    Button("Cancel") {
                        addGroceryItemSheetView = false // Close the sheet
                    }
                    .padding()
                    
                }.padding()
            }
        }.listStyle(InsetGroupedListStyle())
            .navigationTitle("Items for \(groceryList.name)")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { addGroceryItemSheetView = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
    }
    
    // Function to add a grocery item to a list
    private func addItem(itemToAddName: String, itemToAddCategory: GroceryCategory, itemToAddNotes: String?, itemToAddIsPurchased: Bool) {
        withAnimation {
            let newItem = GroceryItem(name: itemToAddName, category: itemToAddCategory, notes: itemToAddNotes, isPurchased: itemToAddIsPurchased)
            groceryList.groceryItems.append(newItem)
            modelContext.insert(newItem)
            try? modelContext.save()
        }
    }
    
    // Function to delete a grocery item from a list
    private func deleteItem(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(groceryList.groceryItems[index])
                try? modelContext.save()
            }
        }
    }
}

/*#Preview {
    DisplayItemsView()
        .modelContainer(for: [GroceryItem.self, GroceryList.self], inMemory: true)
}*/
