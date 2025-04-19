//
//  ContentView.swift
//  GroceryShoppingList
//
//  Created by Marisol on 4/4/25.
//

import SwiftUI
import SwiftData

/* This view is the start view */
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var groceryLists: [GroceryList]
    
    var body: some View {
        NavigationStack {
            VStack {
                VStack(alignment: .center){
                    Text("Create your grocery shopping lists.").font(.title2)
                    
                    // Start Now
                    NavigationLink(destination: ShoppingListsView())
                    {
                        Text("Start Now").padding().background(RoundedRectangle(cornerRadius: 8).fill(Color("DefaultColor"))).foregroundColor(.white)
                    }
                }.padding(.top, 300)
               
                // Grocery Image
                Image("GroceriesImage").resizable().scaledToFit().frame(maxHeight: .infinity, alignment: .bottom).ignoresSafeArea()
            }
        }.navigationBarBackButtonHidden(true)
    }
}



#Preview {
    ContentView()
        .modelContainer(for: [GroceryItem.self, GroceryList.self], inMemory: true)
}
