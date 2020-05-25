//
//  Settings.swift
//  WeatherApp
//
//  Created by Internship on 24/05/2020.
//  Copyright © 2020 Internship. All rights reserved.
//

import Foundation
import RealmSwift

class Settings: Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var metric: Bool = true
    @objc dynamic var imperial: Bool = false
    @objc dynamic var humidity: Bool = true
    @objc dynamic var wind: Bool = true
    @objc dynamic var pressure: Bool = true
    @objc dynamic var lat: Double = 45.70333
    @objc dynamic var lng: Double = 17.70278
    @objc dynamic var location: String = "Slatina"
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
