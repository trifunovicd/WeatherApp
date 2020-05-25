//
//  LocationCondition.swift
//  WeatherApp
//
//  Created by Internship on 15/05/2020.
//  Copyright © 2020 Internship. All rights reserved.
//

import Foundation

struct LocationCondition: Codable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}
