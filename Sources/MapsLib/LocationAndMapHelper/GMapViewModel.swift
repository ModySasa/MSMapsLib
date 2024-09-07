//
//  File.swift
//  
//
//  Created by Mohammad on 09/03/2024.
//

import SwiftuiHelper
import SwiftUI
import GoogleMaps
import GooglePlaces
import NetworkLib

public class GMapViewModel : BaseViewModel {
    
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
    public init( _ generalViewModel: GeneralViewModel? = nil) {
        self.customLocationManager = .init()
        self.placesViewModel = GooglePlacesAutocompleteViewModel(MapsHelper.shared.GoogleMapsAPIServerKey)
        super.init(generalViewModel)
    }
    
    @Published public var mustHaveFormattedAddress : Bool = false
    @Published public var mustMoveToMarkersCenter : Bool = true
    @Published public var showMarkers : Bool = true
    
    public var shouldShowHome : Bool {
        get {
            let rv = HandlingData.shared.getBool(data: savedData, dataName: LocationOptions.shouldShowHome.rawValue)
            return rv
        }
    }
    
    public var canTapMap : Bool {
        get {
            let rv = HandlingData.shared.getBool(data: savedData, dataName: LocationOptions.canTapMap.rawValue)
            return rv
        }
    }
    
    public var isPickLocation : Bool {
        get {
            let rv = HandlingData.shared.getBool(data: savedData, dataName: LocationOptions.isPickLocation.rawValue)
            return rv
        }
    }
    
    public var justShowLocation : Bool {
        get {
            let rv = HandlingData.shared.getBool(data: savedData, dataName: LocationOptions.justShowLocation.rawValue)
            return rv
        }
    }
    
    public var passedLocations : [PlaceDetails] {
        get {
            if let locs = savedData[LocationOptions.currentLocation.rawValue] as? [CLLocationCoordinate2D]
                , let addresses = savedData[LocationOptions.currentLocationAddress.rawValue] as? [String] {
                
                var places = [PlaceDetails]()
                if(addresses.count == locs.count) {
                    for i in 0..<locs.count {
                        let location = locs[i]
                        let address = addresses[i]
                        let place = PlaceDetails.init(coords: location, formattedAddress: address)
                        places.append(place)
                    }
                }
                return places
            } else {
                return .init()
            }
        }
    }
    
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
