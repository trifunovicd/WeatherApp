//
//  AppCoordinator.swift
//  WeatherApp
//
//  Created by Internship on 15/05/2020.
//  Copyright © 2020 Internship. All rights reserved.
//

import UIKit

class AppCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    let window: UIWindow
    var presenter: UINavigationController
    
    init(window: UIWindow) {
        self.window = window
        self.presenter = UINavigationController()
    }
    
    func start() {
        window.rootViewController = presenter
        window.makeKeyAndVisible()
        let homeCoordinator = HomeCoordinator(presenter: presenter)
        childCoordinators.append(homeCoordinator)
        homeCoordinator.start()
    }
    
    
}
