//
//  BusAnnotation.swift
//  BusSP
//
//  Created by Douglas Cardoso Ferreira on 21/07/20.
//  Copyright © 2020 Douglas Cardoso. All rights reserved.
//

import Foundation
import MapKit

class BusAnnotation: NSObject, MKAnnotation {
    
    enum AnnotationType {
        case bus
        case busStop
    }
    
    var coordinate: CLLocationCoordinate2D
    var line: String?
    var prefix: String?
    var accessible: String?
    var type: AnnotationType
    //var address: String?
    
    init(coordinate: CLLocationCoordinate2D, type: AnnotationType) {
        self.coordinate = coordinate
        self.type = type
    }
    
}
