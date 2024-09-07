//
//  File.swift
//
//
//  Created by Mohammad on 09/03/2024.
//

import GoogleMaps
import SwiftUI
import UIKit

public class MapViewController: UIViewController  , GMSMapViewDelegate , ObservableObject {
    
    public let map = GMSMapView()
    public var isAnimating: Bool = false
    public var shouldTab : Bool = true
    
    @Published public var place: PlaceDetails? = nil
    @Published public var coord: CLLocationCoordinate2D? = nil
    public var viewModel : GMapViewModel? = nil
    
    public override func loadView() {
        super.loadView()
        self.map.delegate = self
        self.view = map
    }
    
    public func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        if(shouldTab) {
            reverseGeocodeCoordinate(coordinate: coordinate)
        }
    }
    
    func reverseGeocodeCoordinate(coordinate: CLLocationCoordinate2D) {
        print("TAPPED ON " , coordinate.latitude , coordinate.longitude)
        self.coord = coordinate
        let placeDetails = PlaceDetails.init(coords: coordinate)
//        let geocoder = GMSGeocoder()
        
//        geocoder.reverseGeocodeCoordinate(coordinate) { [self] response, error in
//            if let address = response?.firstResult() {
//                let lines = address.lines ?? []
//                let addressString = lines.joined(separator: "\n")
//                self.place = .init(coords: coordinate, formattedAddress: addressString)
//                
//                
//                viewModel?.selectedPlace = place
//                viewModel?.placesViewModel.place = self.place
//                
//                viewModel?.places.append(self.place!)
//            }
//        }
    }
}
