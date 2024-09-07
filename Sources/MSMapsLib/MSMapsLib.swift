// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

public struct MSMapsLib {
    public let mapsHelper = MapsHelper.shared
    
    public init (_ mapKey : String , mapIcon : String = "") {
        setGooglePlacesKey(mapKey)
        if(!mapIcon.isEmpty) {
            setMapsIcon(mapIcon)
        }
    }
    
    func setGooglePlacesKey(_ key:String) {
        mapsHelper.GoogleMapsAPIServerKey = key
    }
    
    func setMapsIcon(_ key:String) {
        if(!key.isEmpty){
            mapsHelper.mapMarkerImage = Image(key)
        }
    }
}
