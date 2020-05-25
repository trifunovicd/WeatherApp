//
//  DailyInfo.swift
//  WeatherApp
//
//  Created by Internship on 16/05/2020.
//  Copyright © 2020 Internship. All rights reserved.
//

import Foundation

struct DailyInfo: Codable {
    let dt: Int64
    let temp: TemperatureInfo
}
