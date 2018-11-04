//
//  Rock.swift
//  RDrop
//
//  Created by Admin on 11/13/17.
//  Copyright © 2017 baileyth. All rights reserved.
//

import Foundation
import CoreLocation

struct Rock {
    
    var name : String?
    var description : String?
    var id : String?
    var user : String?
    var points : Int?
    var lat : Double?
    var lng : Double?
    var dropped : Bool

    init(name : String?, id: String?, points : Int?, description : String?, user : String?, lat : Double?, lng : Double?, dropped : Bool?) {
        self.name = name
        self.id = id
        self.description = description
        self.user = user
        self.lat = lat
        self.lng = lng
        self.points = points
        self.dropped = dropped!
    }
    
    func getLocation() -> CLLocation {
        if (!isDropped()) {
            return loc.location!
        }
        return CLLocation(latitude: lat!, longitude: lng!)
    }
    
    func isDropped() -> Bool {
        return self.dropped
    }
    
}
