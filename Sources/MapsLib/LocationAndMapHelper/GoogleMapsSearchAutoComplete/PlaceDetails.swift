//
//  PlaceDetails.swift
//  
//
//  Created by Corptia 02 on 22/08/2023.
//

import Foundation
import CoreLocation

open class PlaceDetails: CustomStringConvertible , Identifiable , Equatable{
    public static func == (lhs: PlaceDetails, rhs: PlaceDetails) -> Bool {
        return lhs.id == rhs.id && lhs.formattedAddress == rhs.formattedAddress
    }
    
    open var id : String {
        get {
            return "\(name ?? "")-\(postalCode ?? "")-\(coordinate?.latitude ?? 0.0)-\(coordinate?.longitude ?? 0.0)"
        }
    }
    public let formattedAddress: String
    open var name: String? = nil
    open var streetNumber: String? = nil
    open var route: String? = nil
    open var postalCode: String? = nil
    open var country: String? = nil
    open var countryCode: String? = nil
    open var locality: String? = nil
    open var subLocality: String? = nil
    open var administrativeArea: String? = nil
    open var administrativeAreaCode: String? = nil
    open var subAdministrativeArea: String? = nil
    open var coordinate: CLLocationCoordinate2D? = nil
    public init(coords:CLLocationCoordinate2D , formattedAddress:String = ""){
        self.coordinate = coords
        self.formattedAddress = formattedAddress
    }
    public init?(json: [String: Any]) {
        guard let result = json["result"] as? [String: Any],
              let formattedAddress = result["formatted_address"] as? String
        else { return nil }
        self.formattedAddress = formattedAddress
        self.name = result["name"] as? String
        if let addressComponents = result["address_components"] as? [[String: Any]] {
            streetNumber = get("street_number", from: addressComponents, ofType: .short)
            route = get("route", from: addressComponents, ofType: .short)
            postalCode = get("postal_code", from: addressComponents, ofType: .long)
            country = get("country", from: addressComponents, ofType: .long)
            countryCode = get("country", from: addressComponents, ofType: .short)
            locality = get("locality", from: addressComponents, ofType: .long)
            subLocality = get("sublocality", from: addressComponents, ofType: .long)
            administrativeArea = get("administrative_area_level_1", from: addressComponents, ofType: .long)
            administrativeAreaCode = get("administrative_area_level_1", from: addressComponents, ofType: .short)
            subAdministrativeArea = get("administrative_area_level_2", from: addressComponents, ofType: .long)
        }
        if let geometry = result["geometry"] as? [String: Any],
           let location = geometry["location"] as? [String: Any],
           let latitude = location["lat"] as? CLLocationDegrees,
           let longitude = location["lng"] as? CLLocationDegrees {
            coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
    }
    open var description: String {
        return "\nAddress: \(formattedAddress)\ncoordinate: (\(coordinate?.latitude ?? 0), \(coordinate?.longitude ?? 0))\n"
    }
}
private extension PlaceDetails {
    enum ComponentType: String {
        case short = "short_name"
        case long = "long_name"
    }
    /// Parses the element value with the specified type from the array or components.
    /// Example: `{ "long_name" : "90", "short_name" : "90", "types" : [ "street_number" ] }`
    ///
    /// - Parameters:
    ///  - component: The name of the element.
    ///  - array: The root component array to search from.
    ///  - ofType: The type of element to extract the value from.
    func get(_ component: String, from array: [[String: Any]], ofType: ComponentType) -> String? {
        return (array.first { ($0["types"] as? [String])?.contains(component) == true })?[ofType.rawValue] as? String
    }
}
