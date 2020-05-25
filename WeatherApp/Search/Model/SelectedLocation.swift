//
//  SelectedLocation.swift
//  WeatherApp
//
//  Created by Internship on 23/05/2020.
//  Copyright © 2020 Internship. All rights reserved.
//

import Foundation
import RealmSwift

class SelectedLocation: Object {
    @objc dynamic var id: Int = 1
    @objc dynamic var isSelected: Bool = true
    @objc dynamic var placeName: String = ""
    @objc dynamic var placeNameWithCode: String = ""
    @objc dynamic var lat: Double = 0
    @objc dynamic var lng: Double = 0
    @objc dynamic var dateSaved: Date?
}
