//
//  GooglePlacesAutocompleteViewModel.swift
//  
//
//  Created by Corptia 02 on 22/08/2023.
//

import Foundation
import CoreLocation

public class GooglePlacesAutocompleteViewModel: ObservableObject {
    @Published public var searchText = ""
    @Published public var searchResults: [Place] = []
    @Published public var placeIndex : Int = -1 {
        didSet {
            if(placeIndex > -1){
                let place = searchResults[placeIndex]
                GooglePlacesRequestHelpers
                    .getPlaceDetails(id: place.id, apiKey: apiKey) { [unowned self] in
                        guard let value = $0 else { return }
                        self.searchText = value.formattedAddress
                        self.searchResults.removeAll()
                        self.place = value
                        self.coordinate = value.coordinate!
                        
                        placeIndex = -1
                    }
            }
            
        }
    }
    @Published public var coordinate: CLLocationCoordinate2D = .init(latitude: 0, longitude: 0) {
        didSet {
            self.delegate!.onCoordinateChanged(didAutocompleteWith: coordinate)
            if(coordinate.latitude != 0.0) {
                GooglePlacesRequestHelpers.getPlaceDetails(lat: coordinate.latitude, lng: coordinate.longitude, apiKey: apiKey) { res in
                    self.place = .init(coords: self.coordinate, formattedAddress: res?.formatted_address ?? "")
                }  onError: { _ in
                    self.place = .init(coords: self.coordinate)
                }
            }
        }
    }
    
    @Published public var place: PlaceDetails? = nil {
        didSet {
            if let place {
                self.delegate!.handlePlace(didAutocompleteWith: place)
            }
        }
    }
    
    public var delegate : GooglePlacesAutocompleteViewControllerDelegate? = nil
    
    public init(_ apiKey:String , placeType:PlaceType = .all , radius : Double = 0 , strictBounds: Bool = false , delegate : GooglePlacesAutocompleteViewControllerDelegate? = nil) {
        self.apiKey = apiKey
        self.placeType = placeType
        self.radius = radius
        self.strictBounds = strictBounds
        self.delegate = delegate
    }
    
    private var apiKey: String = ""
    private var placeType: PlaceType
    private var radius: Double
    private var strictBounds: Bool
    
    public func search() {
        guard searchText.count > 2 else { searchResults = []; return }
        let parameters = getParameters(for: searchText)
        GooglePlacesRequestHelpers.getPlaces(with: parameters) {
            self.searchResults = $0
        }
    }
    
    private func getParameters(for text: String) -> [String: String] {
        var params = [
            "types": placeType.rawValue,
            "key": apiKey
        ]
        if(!text.isEmpty){
            params["input"] = text
        }
        if CLLocationCoordinate2DIsValid(coordinate) {
            params["location"] = "\(coordinate.latitude),\(coordinate.longitude)"
            if radius > 0 {
                params["radius"] = "\(radius)"
            }
            if strictBounds {
                params["strictbounds"] = "true"
            }
        }
        return params
    }
    
}
