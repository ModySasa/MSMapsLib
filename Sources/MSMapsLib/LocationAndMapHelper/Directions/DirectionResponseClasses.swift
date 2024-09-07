struct DirectionsResponse: Codable {
    let routes: [Route]
}

struct Route: Codable {
    let legs: [Leg]
    let overviewPolyline: Polyline
    
    enum CodingKeys: String, CodingKey {
        case legs
        case overviewPolyline = "overview_polyline"
    }
}

struct Leg: Codable {
    let steps: [Step]
}

struct Step: Codable {
    let startLocation: Location
    let endLocation: Location
    let polyline: Polyline
    
    enum CodingKeys: String, CodingKey {
        case startLocation = "start_location"
        case endLocation = "end_location"
        case polyline
    }
}

struct Polyline: Codable {
    let points: String
}

struct Location: Codable {
    let lat: Double
    let lng: Double
}
