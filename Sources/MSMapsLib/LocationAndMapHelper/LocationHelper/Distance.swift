//
//  Distance.swift
//  MSMapsLib
//
//  Created by Moha on 9/7/24.
//

import Foundation

public func deg2rad(_ deg: Double) -> Double {
    return deg * (Double.pi / 180);
}

public func getDistanceInMeters(lat1:Double , lng1:Double , lat2: Double, lon2: Double) -> Double {
    let R: Double = 6371; // Earth's radius (km)
    let dLat: Double = deg2rad(lat2 - lat1);
    let dLon: Double = deg2rad(lon2 - lng1);
    let a: Double =
    sin(dLat / 2) * sin(dLat / 2) +
    cos(deg2rad(lat1)) *
    cos(deg2rad(lat2)) *
    sin(dLon / 2) *
    sin(dLon / 2);
    let c: Double = 2 * atan2(sqrt(a), sqrt(1 - a));
    let d: Double = R * c; // Distance in meter
    return d;
}
