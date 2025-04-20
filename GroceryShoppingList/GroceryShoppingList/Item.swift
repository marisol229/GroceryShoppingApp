//
//  Item.swift
//  GroceryShoppingList
//
//  Created by Marisol on 4/4/25.
//

import Foundation
import SwiftData

@Model
final class GroceryItem {
    @Attribute(.unique) var id = UUID()
    var name: String
    var category: GroceryCategory
    var notes: String?
    
    
    init(id: UUID = UUID(), name: String, category: GroceryCategory, notes: String? = nil) {
        self.id = id
        self.name = name
        self.category = category
        self.notes = notes
    }
}

// Grocery categories defined
enum GroceryCategory: String, CaseIterable, Codable {
    case produce = "🍎 Produce"
    case dairy = "🥛 Dairy"
    case meat = "🥩 Meat"
    case seafood = "🐟 Seafood"
    case bakery = "🥖 Bakery"
    case beverage = "🧋 Berverage"
    case other = "Other"
}

// Each GroceryList has an array of GroceryItem
@Model
final class GroceryList {
    @Attribute(.unique) var id = UUID()
    var name: String
    @Relationship(deleteRule: .cascade) var groceryItems: [GroceryItem] = [] // Deletes all items in the list if the list gets deleted
    
    init(id: UUID = UUID(), name: String, groceryItems: [GroceryItem] = []) {
        self.id = id
        self.name = name
        self.groceryItems = groceryItems
    }
}
