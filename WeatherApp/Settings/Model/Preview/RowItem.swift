//
//  RowItem.swift
//  WeatherApp
//
//  Created by Internship on 23/05/2020.
//  Copyright © 2020 Internship. All rights reserved.
//

import Foundation

struct RowItem<RowType, Data> {
    let type: RowType
    let data: Data
}


enum RowType {
    case location
    case unit
    case condition
}


enum Conditions {
    case humidity
    case wind
    case pressure
}


enum Units: String {
    case imperial
    case metric
}
