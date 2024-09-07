//
//  GoogleDirectionsService.swift
//
//
//  Created by Moha on 14/06/2024.
//

import Foundation
import CoreLocation

public class GoogleDirectionsService {
    private let apiKey: String
    
    public init() {
        self.apiKey = MapsHelper.shared.GoogleMapsAPIServerKey
    }
    
    public func getDirections(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D, completion: @escaping (Result<[CLLocationCoordinate2D], Error>) -> Void) {
        let baseURL = "https://maps.googleapis.com/maps/api/directions/json"
        let origin = "\(start.latitude),\(start.longitude)"
        let destination = "\(end.latitude),\(end.longitude)"
        
        guard var urlComponents = URLComponents(string: baseURL) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "origin", value: origin),
            URLQueryItem(name: "destination", value: destination),
            URLQueryItem(name: "key", value: apiKey)
        ]
        
        guard let url = urlComponents.url else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data received", code: 0, userInfo: nil)))
                return
            }
            
            do {
                let directionsResponse = try JSONDecoder().decode(DirectionsResponse.self, from: data)
                let coordinates = self.extractCoordinates(from: directionsResponse)
                completion(.success(coordinates))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    private func extractCoordinates(from response: DirectionsResponse) -> [CLLocationCoordinate2D] {
        var coordinates = [CLLocationCoordinate2D]()
        
        for route in response.routes {
            // Decode the overview polyline
            if let overviewPoints = decodePolyline(route.overviewPolyline.points) {
                coordinates.append(contentsOf: overviewPoints)
            }
            
            // Decode each step's polyline
            for leg in route.legs {
                for step in leg.steps {
                    if let stepPoints = decodePolyline(step.polyline.points) {
                        coordinates.append(contentsOf: stepPoints)
                    }
                }
            }
        }
        
        return coordinates
    }
    
    private func decodePolyline(_ polyline: String) -> [CLLocationCoordinate2D]? {
        var coordinates = [CLLocationCoordinate2D]()
        var index = polyline.startIndex
        let polylineLength = polyline.count
        var lat = 0
        var lng = 0
        
        while index < polyline.endIndex {
            var b = 0
            var shift = 0
            var result = 0
            repeat {
                b = Int(polyline[index].asciiValue! - 63)
                result |= (b & 0x1f) << shift
                shift += 5
                index = polyline.index(after: index)
            } while b >= 0x20
            let dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1))
            lat += dlat
            
            shift = 0
            result = 0
            repeat {
                b = Int(polyline[index].asciiValue! - 63)
                result |= (b & 0x1f) << shift
                shift += 5
                index = polyline.index(after: index)
            } while b >= 0x20
            let dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1))
            lng += dlng
            
            let latDouble = Double(lat) / 1e5
            let lngDouble = Double(lng) / 1e5
            let coord = CLLocationCoordinate2D(latitude: latDouble, longitude: lngDouble)
            coordinates.append(coord)
        }
        
        return coordinates
    }
}

