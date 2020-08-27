//
//  BusLocation.swift
//  BusSP
//
//  Created by Douglas Cardoso Ferreira on 21/07/20.
//  Copyright © 2020 Douglas Cardoso. All rights reserved.
//

import Foundation
import MapKit

struct BusLocation {
    let prefixo: String
    let sentido: String
    let latitude: CLLocationDegrees
    let longitude: CLLocationDegrees
    let address: String
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    static func getFormattedAddress(with placemark: CLPlacemark) -> String {
        var address = ""
        if let street = placemark.thoroughfare {
            address += street
        }
        if let number = placemark.subThoroughfare {
            address += ", \(number)"
        }
        return address
    }
}
