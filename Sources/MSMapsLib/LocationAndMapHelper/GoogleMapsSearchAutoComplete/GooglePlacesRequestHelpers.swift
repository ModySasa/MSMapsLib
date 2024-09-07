//
//  GooglePlacesRequestHelpers.swift
//  
//
//  Created by Corptia 02 on 22/08/2023.
//

import Foundation
import UIKit

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
    
    static func doRequest(_ urlString: String, params: [String: String], completion: @escaping (NSDictionary) -> Void, onError: @escaping (Error) -> Void) {
        var components = URLComponents(string: urlString)
        components?.queryItems = params.map { URLQueryItem(name: $0, value: $1) }
        guard let url = components?.url else { return }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("GooglePlaces Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    onError(error)
                }
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
                print("GooglePlaces Error")
                DispatchQueue.main.async {
                    onError(error)
                }
                return
            }
            guard object?["status"] as? String == "OK" else {
                print("GooglePlaces API Error: \(object?["status"] ?? "")")
                return
            }
            DispatchQueue.main.async {
                completion(object ?? [:])
            }
        }
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
    
    static func getPlaceDetails(lat: Double, lng: Double, apiKey: String, completion: @escaping (ResultsData?) -> Void, onError: @escaping (Error) -> Void) {
            var parameters = ["latlng": "\(lat),\(lng)", "key": apiKey]
            if let deviceLanguage = deviceLanguage {
                parameters["language"] = deviceLanguage
            }
            
            doRequest(
                "https://maps.googleapis.com/maps/api/geocode/json",
                params: parameters,
                completion: { response in
                    let place = PlaceFromCoords(response as? [String: Any] ?? [:])
                    completion(place.result)
                },
                onError: { error in
                    onError(error)
                }
            )
        }
}

class PlaceFromCoords {
    var results: [ResultsData] = []
    var result: ResultsData

    init(_ jsonObject: [String: Any]) {
        self.result = ResultsData(jsonObject) // Set a default value
        self.handleDictionary(jsonObject)
    }

    func handleDictionary(_ jsonObject: [String: Any]) {
        guard let resultsArray = jsonObject["results"] as? [[String: AnyObject]] else { return }
        for result in resultsArray {
            let placeData = ResultsData(result)
            results.append(placeData)
        }
        if let firstResult = results.first {
            self.result = firstResult
        }
    }
}

class ResultsData {
    var formatted_address : String = ""
    var place_id : String = ""
    
    init(_ data : [String:Any]) {
        self.formatted_address = getString(data: data, dataName: "formatted_address")
        self.place_id = getString(data: data, dataName: "place_id")
    }
    
    func getString(data:[AnyHashable:Any] , dataName: String) -> String {
        var value : String = ""
        
        if(data["\(dataName)"] is NSNull){
            value = ""
        } else {
            if(data["\(dataName)"] != nil){
                if(data["\(dataName)"] is String) {
                    value = data["\(dataName)"] as! String
                    if ((data["\(dataName)"] as! String) == "null") {
                        value = ""
                    }
                }
            }
        }
        return value
    }
    
}
