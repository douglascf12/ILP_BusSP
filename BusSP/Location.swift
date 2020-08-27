//
//  Location.swift
//  BusSP
//
//  Created by Douglas Cardoso Ferreira on 23/07/20.
//  Copyright © 2020 Douglas Cardoso. All rights reserved.
//

import Foundation
import MapKit

class Location: Codable {
    let p: String
    let a: Bool
    let ta: String
    let py: Double
    let px: Double
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: py, longitude: px)
    }
}
