//
//  ModalDelegate.swift
//  WeatherApp
//
//  Created by Internship on 23/05/2020.
//  Copyright © 2020 Internship. All rights reserved.
//

import Foundation

protocol ModalDelegate: AnyObject {
    func getWeatherForLocation()
    func dismissModal()
}
