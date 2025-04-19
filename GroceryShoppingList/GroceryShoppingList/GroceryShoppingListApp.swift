//
//  GroceryShoppingListApp.swift
//  GroceryShoppingList
//
//  Created by Marisol on 4/4/25.
//

import SwiftUI
import SwiftData

@main
struct GroceryShoppingListApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            GroceryItem.self, GroceryList.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
