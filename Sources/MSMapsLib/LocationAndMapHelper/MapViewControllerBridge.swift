import GoogleMaps
import SwiftUI

public struct MapViewControllerBridge: UIViewControllerRepresentable {
    @StateObject public var viewModel: GMapViewModel
    @Binding public var markers: [GMSMarker]
    @Binding public var selectedMarker: GMSMarker?
    @Binding public var polylinesPaths: [(path: GMSMutablePath, color: Color, width: CGFloat)]?
    @Binding public var markerClicks: [((Any) -> Void)?]?
    
    @Binding public var moveCameraToPosition : (coordinates : CLLocationCoordinate2D , zoom : Float)?
    
    func didSetPolylines(mapView: GMSMapView) {
        if let polylinesPaths = polylinesPaths {
            for path in polylinesPaths {
                let polyline = GMSPolyline(path: path.path)
                polyline.strokeColor = UIColor(path.color)
                polyline.strokeWidth = path.width
                polyline.map = mapView
            }
        }
    }
    
    func didHaveMarkers(mapView: GMSMapView) {
        var lat = 0.0
        var lng = 0.0
        
        markers.forEach {
            $0.map = mapView
            $0.isTappable = true
            lat += $0.position.latitude
            lng += $0.position.longitude
        }
        
        if viewModel.mustMoveToMarkersCenter {
            print("CAMERA TEST ::: mustMoveToMarkersCenter")
            let centerCoords = CLLocationCoordinate2D(latitude: lat / Double(markers.count), longitude: lng / Double(markers.count))
            let camera = GMSCameraPosition.camera(withLatitude: centerCoords.latitude, longitude: centerCoords.longitude, zoom: 14.0)
            mapView.camera = camera
        }
    }
    
    func moveCamera(mapView: GMSMapView) {
        if let moveCameraToPosition {
            let camera = GMSCameraPosition.camera(withLatitude: moveCameraToPosition.coordinates.latitude, longitude: moveCameraToPosition.coordinates.longitude, zoom: moveCameraToPosition.zoom)
//            print("CAMERA TEST :::" , camera.zoom , camera.target.latitude , camera.target.longitude)
            print("CAMERA TEST ::: moveCameraToPosition")
            mapView.camera = camera
        }
    }
    public init(
        viewModel: StateObject<GMapViewModel>,
        markers: Binding<[GMSMarker]>,
        markerClicks: Binding<[((Any) -> Void)?]?>? = nil,
        selectedMarker: Binding<GMSMarker?>,
        polylinesPaths: Binding<[(path: GMSMutablePath, color: Color, width: CGFloat)]?>? = nil,
        moveCameraToPosition : Binding<(coordinates : CLLocationCoordinate2D , zoom : Float)?>? = nil
    ) {
        self._viewModel = viewModel
        self._markers = markers
        self._markerClicks = markerClicks ?? .constant(nil)
        self._selectedMarker = selectedMarker
        self._polylinesPaths = polylinesPaths ?? .constant(nil)
        self._moveCameraToPosition = moveCameraToPosition ?? .constant(nil)
    }
    
    public func makeUIViewController(context: Context) -> MapViewController {
        let vc = MapViewController()
        vc.place = viewModel.selectedPlace
        vc.coord = viewModel.placesViewModel.coordinate
        vc.viewModel = self.viewModel
        vc.shouldTab = viewModel.isPickLocation
        vc.map.delegate = context.coordinator
        return vc
    }
    
    public func updateUIViewController(_ uiViewController: MapViewController, context: Context) {
        let mapView = uiViewController.map
        mapView.delegate = context.coordinator
        mapView.clear()
        
        if let place = viewModel.selectedPlace {
            if viewModel.mustHaveFormattedAddress, !place.formattedAddress.isEmpty {
                print("CHANGING ZOOM CHECK BEFORE , NOT EMPTY " , viewModel.shouldChangeZoom , mapView.camera.zoom)
                let camera = GMSCameraPosition.camera(withLatitude: place.coordinate!.latitude, longitude: place.coordinate!.longitude, zoom: viewModel.shouldChangeZoom ? 14.0 : mapView.camera.zoom)
                mapView.camera = camera
//                print("CHANGING ZOOM CHECK AFTER , NOT EMPTY " , viewModel.shouldChangeZoom , mapView.camera.zoom)
            } else {
                print("CHANGING ZOOM CHECK BEFORE , IS EMPTY " , viewModel.shouldChangeZoom , mapView.camera.zoom)
                let camera = GMSCameraPosition.camera(withLatitude: place.coordinate!.latitude, longitude: place.coordinate!.longitude, zoom: viewModel.shouldChangeZoom ? 14.0 : mapView.camera.zoom)
                mapView.camera = camera
//                print("CHANGING ZOOM CHECK AFTER , IS EMPTY " , viewModel.shouldChangeZoom , mapView.camera.zoom)
            }
            
            if let selectedMarker = selectedMarker {
                selectedMarker.map = mapView
            } else {
                selectedMarker = GMSMarker(position: place.coordinate ?? CLLocationCoordinate2D())
                if let selectedMarker = selectedMarker {
                    selectedMarker.map = mapView
                }
            }
        }
        
        if viewModel.showMarkers {
            didHaveMarkers(mapView: mapView)
        }
        
        didSetPolylines(mapView: mapView)
        
        moveCamera(mapView: mapView)
    }
    
    public func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    public class Coordinator: NSObject, GMSMapViewDelegate {
        var parent: MapViewControllerBridge
        
        init(_ parent: MapViewControllerBridge) {
            self.parent = parent
        }
        
        public func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
            if let index = parent.markers.firstIndex(of: marker), let clicks = parent.markerClicks {
                if clicks.count > index, let click = clicks[index] {
                    click(marker.userData ?? "" as Any)
                }
            }
            return true
        }
        
        public func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
            if(parent.viewModel.canTapMap) {
//                parent.viewModel.placesViewModel.coordinate = coordinate
                
                parent.viewModel.placesViewModel.coordinate = coordinate
                print("Address: reverseGeocodeCoordinate::: DID TAP AT \(coordinate)")
                reverseGeocodeCoordinate(coordinate:  parent.viewModel.placesViewModel.coordinate)
                let placeDetails = PlaceDetails.init(coords: parent.viewModel.placesViewModel.coordinate , formattedAddress: self.formattedAddress)
                
                parent.viewModel.placesViewModel.place = placeDetails
                parent.viewModel.selectedPlace = placeDetails
                parent.viewModel.places = [parent.viewModel.selectedPlace!]
                
                if let onMapTapped = parent.viewModel.onMapTapped {
                    onMapTapped(coordinate)
                }
            }
        }
        var formattedAddress : String = ""
        
        func reverseGeocodeCoordinate(coordinate: CLLocationCoordinate2D) {
            let geocoder = GMSGeocoder()
            
            geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
                if let address = response?.firstResult() {
                    let lines = address.lines ?? []
                    let addressString = lines.joined(separator: "\n")
                    self.formattedAddress = addressString
                    print("Address: reverseGeocodeCoordinate::: \(addressString)")
                }
            }
        }
    }
}
