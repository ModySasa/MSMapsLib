//
//  GooglePlacesRequestHelpers.swift
//  
//
//  Created by Corptia 02 on 22/08/2023.
//

import Foundation
import UIKit
import NetworkLib
import Alamofire

open class GooglePlacesRequestHelpers {
    static func doRequest(_ urlString: String, params: [String: String], completion: @escaping (NSDictionary) -> Void) {
        var components = URLComponents(string: urlString)
        components?.queryItems = params.map { URLQueryItem(name: $0, value: $1) }
        guard let url = components?.url else { return }
        let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            if let error = error {
                print("GooglePlaces Error: \(error.localizedDescription)")
                return
            }
            guard let data = data, let response = response as? HTTPURLResponse else {
                print("GooglePlaces Error: No response from API")
                return
            }
            guard response.statusCode == 200 else {
                print("GooglePlaces Error: Invalid status code \(response.statusCode) from API")
                return
            }
            let object: NSDictionary?
            do {
                object = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary
            } catch {
                object = nil
                print("GooglePlaces Error")
                return
            }
            guard object?["status"] as? String == "OK" else {
                print("GooglePlaces API Error: \(object?["status"] ?? "")")
                return
            }
            guard let json = object else {
                print("GooglePlaces Parse Error")
                return
            }
            // Perform table updates on UI thread
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                completion(json)
            }
        })
        task.resume()
    }
    
    static func getPlaces(with parameters: [String: String], completion: @escaping ([Place]) -> Void) {
        var parameters = parameters
        if let deviceLanguage = deviceLanguage {
            parameters["language"] = deviceLanguage
        }
        doRequest(
            "https://maps.googleapis.com/maps/api/place/autocomplete/json",
            params: parameters,
            completion: {
                guard let predictions = $0["predictions"] as? [[String: Any]] else { return }
                completion(predictions.map { Place(prediction: $0) })
            }
        )
    }
    
    static func getPlaceDetails(id: String, apiKey: String, completion: @escaping (PlaceDetails?) -> Void) {
        var parameters = [ "placeid": id, "key": apiKey ]
        if let deviceLanguage = deviceLanguage {
            parameters["language"] = deviceLanguage
        }
        doRequest(
            "https://maps.googleapis.com/maps/api/place/details/json",
            params: parameters,
            completion: { completion(PlaceDetails(json: $0 as? [String: Any] ?? [:])) }
        )
    }
    
    private static var deviceLanguage: String? {
        return (Locale.current as NSLocale).object(forKey: NSLocale.Key.languageCode) as? String
    }
    
    static func getPlaceDetails(lat: Double , lng:Double , apiKey: String, completion: @escaping (ResultsData?) -> Void , onError : @escaping (AFError)->Void) {
        var parameters = [ "latlng": "\(lat),\(lng)", "key": apiKey ]
        if let deviceLanguage = deviceLanguage {
            parameters["language"] = deviceLanguage
        }
        NetworkViewModel()
            .getData(
                "https://maps.googleapis.com/maps/api/geocode/json"
                , withAuth: false
                , shouldLoad: false
                , isLoadingIndex: 0
                , parameters: parameters) { data in
                    let place = PlaceFromCoords(data)
                    completion(place.result)
                } onError: { error in
                    onError(error)
                }

//        doRequest(
//            "https://maps.googleapis.com/maps/api/geocode/json",
//            params: parameters,
//            completion: { completion(ResultsData($0 as? [String: Any] ?? [:])) }
//        )
    }
}

class PlaceFromCoords : GeneralResponse {
    var results : [ResultsData] = .init()
    var result : ResultsData = .init([String : Any]())
    
    override func handleDictionary(_ jsonObject: [String : AnyObject]) {
        HandlingData.shared.fillListByName(jsonObject: jsonObject, jsonName: "results") { obj in
            self.results.append(.init(obj))
            self.result = self.results[0]
        }
    }
    
}

class ResultsData {
    let formatted_address : String
    let place_id : String
    
    init(_ data : [String:Any]) {
        self.formatted_address = HandlingData.shared.getString(data: data, dataName: "formatted_address")
        self.place_id = HandlingData.shared.getString(data: data, dataName: "place_id")
    }
    
}
