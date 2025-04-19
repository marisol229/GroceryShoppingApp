//
//  ToolView.swift
//  GroceryShoppingList
//
//  Created by Marisol on 4/4/25.
//

import SwiftUI
import SwiftData

struct ToolView: View {
    //@State  var showingSearchAlert = false
    var body: some View {
        Text("")
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    NavigationLink(destination: ShoppingListsView())
                    {
                        Image(systemName:"list.dash").resizable()
                            .scaledToFit()
                            .foregroundColor(Color("DefaultColor"))
                    }
                }
            }
    }
}

#Preview {
    ToolView()
}
