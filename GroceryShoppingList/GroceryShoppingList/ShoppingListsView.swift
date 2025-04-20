//
//  ShoppingListsView.swift
//  GroceryShoppingList
//
//  Created by Marisol on 4/4/25.
//

import SwiftUI
import SwiftData

class ShoppingListsViewModel: ObservableObject {

    // Function to add a grocery list
    func addList(groceryListToAddName: String, to modelContext: ModelContext) {
        withAnimation {
            let newList = GroceryList(name: groceryListToAddName)
            modelContext.insert(newList)
            try? modelContext.save()
        }
    }

    // Function to delete a grocery list
    func deleteList(offsets: IndexSet, from groceryLists: [GroceryList], to modelContext: ModelContext) {
        withAnimation {
            for index in offsets {
                modelContext.delete(groceryLists[index])
                try? modelContext.save()
            }
        }
    }
}


/* This view displays the grocery lists */
struct ShoppingListsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var groceryLists: [GroceryList]
    @State private var addGroceryListAlert = false // to show alert when wanting to add a grocery list
    @State private var addGroceryListName: String = "" // for the name of the grocery list to add
    
    @StateObject private var shoppingListsViewModel = ShoppingListsViewModel() // view model
    
    var body: some View {
        NavigationView {
            VStack {
                // Display each grocery list added
                List {
                    ForEach(groceryLists) { list in
                        NavigationLink(destination: DisplayItemsView(groceryList: list))
                        {
                            Text(list.name)
                        }
                    }
                    .onDelete{ IndexSet in
                        shoppingListsViewModel.deleteList(offsets: IndexSet, from: groceryLists, to: modelContext)
                    }
                }.listStyle(InsetGroupedListStyle())
                    .navigationTitle("My Grocery Lists")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading){
                            EditButton()
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: { addGroceryListAlert = true }) {
                                Image(systemName: "plus")
                            }
                        }
                                            
                    }
                // Nearby Stores
                NavigationLink(destination: NearbyStoresView())
                {
                    Text("Find Nearby Stores").padding().foregroundColor(Color("DefaultColor"))
                }

            }.alert("Add Grocery List", isPresented: $addGroceryListAlert, actions: { // alert pops up to add a grocery list
                TextField("Enter grocery list name", text: $addGroceryListName).autocorrectionDisabled()
                
                Button("Add", action: {
                    // If no name is entered do not add an empty grocery list
                    if addGroceryListName.isEmpty {
                        return
                    }
                    // Add the grocery list
                    shoppingListsViewModel.addList(groceryListToAddName: addGroceryListName, to: modelContext)
                    addGroceryListName = "" // Reset the addGroceryListName
                    addGroceryListAlert = false
                })
                Button("Cancel", role: .cancel, action: {
                    addGroceryListAlert = false
                })
            }, message: {
                Text("Please enter a name.")
            })
        }.navigationBarBackButtonHidden()
    }
}

#Preview {
    ShoppingListsView()
}
