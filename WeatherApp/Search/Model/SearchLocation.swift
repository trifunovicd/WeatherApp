//
//  SearchLocation.swift
//  WeatherApp
//
//  Created by Internship on 22/05/2020.
//  Copyright © 2020 Internship. All rights reserved.
//

import Foundation

struct SearchLocation: Codable {
    let placeName: String
    let countryCode: String
    let lat: Double
    let lng: Double
}
