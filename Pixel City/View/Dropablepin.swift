//
//  Dropablepin.swift
//  Pixel City
//
//  Created by Mohamed on 6/2/20.
//  Copyright © 2020 Mohamed. All rights reserved.
//

import Foundation
import MapKit
import UIKit

class Dropablepin: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var identifier: String
    
    init(coordinate: CLLocationCoordinate2D, identifier: String) {
        
        self.coordinate = coordinate
        self.identifier = identifier
        
        
    }
    
    
    
    
}
