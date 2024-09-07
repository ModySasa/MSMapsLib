//
//  File.swift
//  
//
//  Created by Corptia 02 on 28/11/2022.
//

import Foundation
import UIKit
import SwiftUI

public class MapsHelper{
    public init() {
        
    }
    public static let shared = MapsHelper.init()
    
    var GoogleMapsAPIServerKey = ""
    var mapMarkerImage = Image("location")
    
    public var onPickedLat : ((String)->Void)? = nil
    public var onPickedLng : ((String)->Void)? = nil
    public var onPickedTitle : ((String)->Void)? = nil
    
    var selectedLat = "" {
        didSet {
            if let pickedLat = onPickedLat {
                pickedLat(selectedLat)
            }
        }
    }
    
    var selectedLng = "" {
        didSet {
            if let pickedLng = onPickedLng {
                pickedLng(selectedLng)
            }
        }
    }
    
    var selectedTitle = "" {
        didSet {
            if let pickedTitle = onPickedTitle {
                pickedTitle(selectedTitle)
            }
        }
    }
    
    var requestLocationUpdate = false
    var hasCurrentLocationButton = false
    
    public func getAddressDetails()->(selectedLat:String,selectedLng:String,selectedTitle:String){
        return (selectedLat,selectedLng,selectedTitle)
    }
    
    public func requestUpdatedLocation(){
        requestLocationUpdate = true
    }
    public func disableUpdatedLocation(){
        requestLocationUpdate = false
    }
    
    public func enableCurrentLocationButton(){
        hasCurrentLocationButton = true
    }
    
    public func disableCurrentLocationButton(){
        hasCurrentLocationButton = false
    }
}
