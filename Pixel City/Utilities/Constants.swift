//
//  Constants.swift
//  Pixel City
//
//  Created by Mohamed on 6/9/20.
//  Copyright © 2020 Mohamed. All rights reserved.
//

import Foundation

let apikey = "e8ebb28a9f0487a06ed0490853cffa40"

func flickrurl(withkey key: String, withannotation annotaion: Dropablepin, numperofphotos: Int) -> String {
    
    return "https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(key)&lat=\(annotaion.coordinate.latitude)&lon=\(annotaion.coordinate.longitude)&radius=1&radius_units=mi&per_page=\(numperofphotos)&format=json&nojsoncallback=1"

}
