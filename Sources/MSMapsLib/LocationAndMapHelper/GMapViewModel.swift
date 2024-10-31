//
//  File.swift
//  
//
//  Created by Mohammad on 09/03/2024.
//

import SwiftUI
import GoogleMaps
import GooglePlaces

public class GMapViewModel : ObservableObject {
    @Published public var zoomInCenter: Bool = false
    @Published public var places : [PlaceDetails] = .init()
    @Published public var selectedPlace : PlaceDetails? = nil
    
    public func createMarkerFromPlace(_ place : PlaceDetails , icon : String? = nil) -> GMSMarker{
        let marker = GMSMarker(position: place.coordinate ?? .init(latitude: 31, longitude: 31))
        marker.title = place.name ?? place.formattedAddress
        if let icon {
            if !icon.isEmpty {
                marker.icon = .init(named: icon)
            }
            marker.isTappable = false
        }
        return marker
    }
        
    @Published public var placesViewModel : GooglePlacesAutocompleteViewModel
    @Published public var customLocationManager : CustomLocationManager
    
    @MainActor
    public init(
        shouldShowHome : Bool = false
        , canTapMap : Bool = false
        , isPickLocation : Bool = false
        , justShowLocation : Bool = false
        , shouldChangeZoom : Bool = false
        , passedLocations : [PlaceDetails] = .init()
    ) {
        self.customLocationManager = .init()
        self.placesViewModel = GooglePlacesAutocompleteViewModel(MapsHelper.shared.GoogleMapsAPIServerKey)
        
        self.shouldShowHome = shouldShowHome
        self.canTapMap = canTapMap
        self.isPickLocation = isPickLocation
        self.justShowLocation = justShowLocation
        self.shouldChangeZoom = shouldChangeZoom
        self.passedLocations = passedLocations
    }
    
    @Published public var mustHaveFormattedAddress : Bool = false
    @Published public var mustMoveToMarkersCenter : Bool = true
    @Published public var shouldChangeZoom : Bool = true
    @Published public var showMarkers : Bool = true
    
    public var shouldShowHome : Bool
    
    public var canTapMap : Bool
    
    public var isPickLocation : Bool
    
    public var justShowLocation : Bool
    
    public var passedLocations : [PlaceDetails]
    
    public var onMapTapped : ((CLLocationCoordinate2D)->Void)? = nil
    
}

extension Array<CLLocationCoordinate2D> {
    public func toGMSMutablePath() -> GMSMutablePath {
        let path = GMSMutablePath()
        for coordinate in self {
            path.add(coordinate)
        }
        if let first = first {
            path.add(first)
        }
        return path
    }
}
