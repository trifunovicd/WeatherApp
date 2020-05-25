//
//  Coordinator.swift
//  WeatherApp
//
//  Created by Internship on 15/05/2020.
//  Copyright © 2020 Internship. All rights reserved.
//

import UIKit

protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    var presenter: UINavigationController { get set }

    func start()
}
