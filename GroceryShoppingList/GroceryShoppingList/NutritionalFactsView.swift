//
//  NutritionalFactsView.swift
//  GroceryShoppingList
//
//  Created by Marisol on 4/4/25.
//

import SwiftUI
import SwiftData
import Foundation

struct NutritionalFactsView: View {
    @StateObject private var viewModel = NutritionalFactsViewModel()
    @State private var foodItemToSearch: String = ""
    @State private var message: String = ""
    
    var body: some View {
        VStack {
            Text("Get Nutrition Facts").font(.title).padding()
            Text(message).foregroundColor(Color.red)
            //Spacer()
            // Enter the food item name to get the nutrition facts
            TextField("Enter food item name (e.g., apple)", text: $foodItemToSearch).textFieldStyle(RoundedBorderTextFieldStyle()).padding().autocorrectionDisabled()
            Button("Search") {
                if(foodItemToSearch.isEmpty)
                {
                    message = "Please enter a food item name to search"
                } else {
                    viewModel.getNutritions(foodItem: foodItemToSearch)
                }
                
            }.padding()
                .background(RoundedRectangle(cornerRadius: 8).fill(Color("DefaultColor")))
                .foregroundColor(.white)
            
            if !viewModel.foodName.isEmpty {
                Text("\(viewModel.foodName)").font(.headline).padding(.top)
                // Display the nutritional facts
                List(viewModel.nutrientsReturned) { nutrient in
                    HStack {
                        Text(nutrient.nutrientName)
                        Spacer()
                        Text(String(nutrient.value) + " " + nutrient.unitName)
                    }
                }
            }
            Spacer()
        }
        .padding()
    }
}

class NutritionalFactsViewModel: ObservableObject {
    @Published var foodName: String = ""
    @Published var nutrientsReturned: [FoodNutrient] = []
    private let apiKey = "GPGhthnSYAArK3DS165tIQQnPxUH2diz0mxOarzD"
    
    func getNutritions(foodItem: String) {
        let urlAsString = "https://api.nal.usda.gov/fdc/v1/foods/search?query=\(foodItem)&api_key=\(apiKey)"
        print(urlAsString)
        let url = URL(string: urlAsString)!
        let urlSession = URLSession.shared
        
        let jsonQuery = urlSession.dataTask(with: url, completionHandler: { data, response, error -> Void in
            if (error != nil) {
                print(error!.localizedDescription)
            }
            
            // Decode Json results from the API call to mathResults decodable structure
            let decoder = JSONDecoder()
            let jsonResult = try! decoder.decode(FoodSearchResult.self, from: data!)
            

            DispatchQueue.main.async {
                if let foodResult = jsonResult.foods.first {
                    self.foodName = "Nutritional facts for: " + foodResult.description
                    self.nutrientsReturned = foodResult.foodNutrients
                }
                else
                {
                    print("Cannot display information now for that item.")
                    self.foodName = "Cannot display information now for that item."
                    self.nutrientsReturned = []
                }
            }
        })
        jsonQuery.resume()
    }
}

// API Structure
struct FoodSearchResult: Codable {
    let foods: [Food]
}

struct Food: Codable {
    let description: String
    let foodNutrients: [FoodNutrient]
}
struct FoodNutrient: Codable, Identifiable {
    var id: UUID { UUID() }
    let nutrientName: String
    let value: Double
    let unitName: String
}

#Preview {
    NutritionalFactsView()
}
