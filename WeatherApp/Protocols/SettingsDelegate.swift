//
//  SettingsDelegate.swift
//  WeatherApp
//
//  Created by Internship on 23/05/2020.
//  Copyright © 2020 Internship. All rights reserved.
//

import UIKit

protocol SettingsDelegate: AnyObject {
    func openSettingsView(backgroundColor: (UIColor, UIColor))
}
