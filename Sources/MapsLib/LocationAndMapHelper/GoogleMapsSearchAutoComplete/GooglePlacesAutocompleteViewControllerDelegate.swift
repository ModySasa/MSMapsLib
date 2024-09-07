//
//  GooglePlacesAutocompleteViewControllerDelegate.swift
//  
//
//  Created by Corptia 02 on 22/08/2023.
//

import Foundation
import CoreLocation

public protocol GooglePlacesAutocompleteViewControllerDelegate: class {
    func handlePlace(didAutocompleteWith place: PlaceDetails)
    func onCoordinateChanged(didAutocompleteWith coordinate: CLLocationCoordinate2D)
}

public class AutoCompleteDelegate : ObservableObject , GooglePlacesAutocompleteViewControllerDelegate {
    @Published public var coords : CLLocationCoordinate2D = kCLLocationCoordinate2DInvalid
    public var onPlaceChanged : ((PlaceDetails)->Void)? = nil
    public init(){}
    public func handlePlace(didAutocompleteWith place: PlaceDetails) {
//        dump(place)
        if let onPlaceChanged {
            onPlaceChanged(place)
        }
    }
    
    public func onCoordinateChanged(didAutocompleteWith coordinate: CLLocationCoordinate2D) {
        coords = coordinate
    }
}
