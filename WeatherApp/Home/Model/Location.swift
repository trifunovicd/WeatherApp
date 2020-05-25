//
//  Location.swift
//  WeatherApp
//
//  Created by Internship on 15/05/2020.
//  Copyright © 2020 Internship. All rights reserved.
//

import Foundation

struct Location: Codable {
    let current: CurrentInfo
    let daily: [DailyInfo]
}
