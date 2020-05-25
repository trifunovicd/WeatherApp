//
//  CurrentInfo.swift
//  WeatherApp
//
//  Created by Internship on 16/05/2020.
//  Copyright © 2020 Internship. All rights reserved.
//

import Foundation

struct CurrentInfo: Codable {
    let dt: Int64
    let temp: Float
    let pressure: Int
    let humidity: Int
    let wind_speed: Float
    let weather: [LocationCondition]
}
