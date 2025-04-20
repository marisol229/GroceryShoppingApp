//
//  NearbyStoresView.swift
//  GroceryShoppingList
//
//  Created by Evangelos Leros on 4/4/25.
//

import SwiftUI
import SwiftData
import MapKit

struct NearbyStoresView: View {
    @StateObject private var viewModel = NearbyStoresViewModel()
    @State private var zipCode: String = ""
    @State private var message: String = ""
    
    var body: some View {
        VStack {
            Text("Find Nearby Grocery Stores").font(.title).padding()
            Text(message).foregroundColor(Color.red)
            
            // Enter zip code to search for nearby stores
            TextField("Enter zip code (e.g., 85224)", text: $zipCode)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
                .padding()
            
            Button("Search") {
                if zipCode.isEmpty {
                    message = "Please enter a zip code to search"
                } else if zipCode.count != 5 || Int(zipCode) == nil {
                    message = "Please enter a valid 5-digit zip code"
                } else {
                    message = ""
                    viewModel.searchNearbyStores(zipCode: zipCode)
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 8).fill(Color("DefaultColor")))
            .foregroundColor(.white)
            
            if viewModel.isLoading {
                ProgressView("Searching for stores...")
                    .padding()
            } else if !viewModel.errorMessage.isEmpty {
                Text(viewModel.errorMessage)
                    .foregroundColor(.red)
                    .padding()
            } else if viewModel.stores.isEmpty && viewModel.hasSearched {
                Text("No grocery stores found near this location.")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                List {
                    ForEach(viewModel.stores) { store in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(store.name)
                                .font(.headline)
                            
                            if !store.address.isEmpty {
                                Text(store.address)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            
                            if !store.distance.isEmpty {
                                Text(store.distance)
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Nearby Grocery Stores")
    }
}

class NearbyStoresViewModel: ObservableObject {
    @Published var stores: [GroceryStore] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    @Published var hasSearched: Bool = false
    
    func searchNearbyStores(zipCode: String) {
        isLoading = true
        errorMessage = ""
        stores = []
        
        // Convert zip code to coordinate using geocoding
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(zipCode) { [weak self] placemarks, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let error = error {
                    self.isLoading = false
                    self.hasSearched = true
                    self.errorMessage = "Error finding location: \(error.localizedDescription)"
                    return
                }
                
                guard let placemark = placemarks?.first, let location = placemark.location else {
                    self.isLoading = false
                    self.hasSearched = true
                    self.errorMessage = "Could not find location for this zip code"
                    return
                }
                
                // Now use MapKit to search for grocery stores near this location
                self.searchGroceryStores(near: location.coordinate)
            }
        }
    }
    
    private func searchGroceryStores(near coordinate: CLLocationCoordinate2D) {
        // Create a search request for grocery stores
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "grocery store supermarket"
        request.region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
        // Region is found with zip code, (not hardcoded as per ruberic)
        
        // Perform the search
        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                self.hasSearched = true
                
                if let error = error {
                    self.errorMessage = "Error finding stores: \(error.localizedDescription)"
                    return
                }
                
                guard let response = response, !response.mapItems.isEmpty else {
                    self.errorMessage = "No grocery stores found nearby."
                    return
                }
                
                // Convert MKMapItems to our GroceryStore model
                self.stores = response.mapItems.map { mapItem in
                    let distance = self.calculateDistance(from: coordinate, to: mapItem.placemark.coordinate)
                    
                    return GroceryStore(
                        id: UUID().uuidString,
                        name: mapItem.name ?? "Unknown Store",
                        address: self.formatAddress(from: mapItem.placemark),
                        distance: distance
                    )
                }
                
                // Sort stores by distance
                self.stores.sort { $0.distanceValue < $1.distanceValue }
            }
        }
    }
    
    // Format address from placemark
    private func formatAddress(from placemark: MKPlacemark) -> String {
        var addressComponents: [String] = []
        
        if let thoroughfare = placemark.thoroughfare {
            if let subThoroughfare = placemark.subThoroughfare {
                addressComponents.append("\(subThoroughfare) \(thoroughfare)")
            } else {
                addressComponents.append(thoroughfare)
            }
        }
        
        if let locality = placemark.locality {
            addressComponents.append(locality)
        }
        
        if let administrativeArea = placemark.administrativeArea {
            addressComponents.append(administrativeArea)
        }
        
        return addressComponents.joined(separator: ", ")
    }
    
    // Calculate distance between two coordinates
    private func calculateDistance(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) -> (String, Double) {
        let sourceLocation = CLLocation(latitude: source.latitude, longitude: source.longitude)
        let destinationLocation = CLLocation(latitude: destination.latitude, longitude: destination.longitude)
        
        let distanceInMeters = sourceLocation.distance(from: destinationLocation)
        
        // Format for display
        let distanceInMiles = distanceInMeters / 1609.34
        let formattedDistance = String(format: "%.1f miles away", distanceInMiles)
        
        return (formattedDistance, distanceInMiles)
    }
}

// Model for grocery stores
struct GroceryStore: Identifiable {
    let id: String
    let name: String
    let address: String
    let distance: String
    var distanceValue: Double
    
    init(id: String, name: String, address: String, distance: (String, Double)) {
        self.id = id
        self.name = name
        self.address = address
        self.distance = distance.0
        self.distanceValue = distance.1
    }
}

#Preview {
    NearbyStoresView()
}
