//
//  HomeCoordinator.swift
//  WeatherApp
//
//  Created by Internship on 15/05/2020.
//  Copyright © 2020 Internship. All rights reserved.
//

import UIKit

class HomeCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var presenter: UINavigationController
    let controller: HomeViewController
    
    init(presenter: UINavigationController) {
        self.presenter = presenter
        let homeViewController = HomeViewController()
        let homeViewModel = HomeViewModel()
        homeViewController.viewModel = homeViewModel
        self.controller = homeViewController
    }
    
    func start() {
        controller.viewModel.homeCoordinatorDelegate = self
        presenter.pushViewController(controller, animated: true)
    }
}


extension HomeCoordinator: SearchDelegate {
    func openSearchView(backgroundColor: (UIColor, UIColor)) {
        let searchViewController = SearchViewController()
        let viewModel = SearchViewModel()
        viewModel.homeCoordinatorDelegate = self
        viewModel.backgroundColor = backgroundColor
        searchViewController.viewModel = viewModel
        presenter.present(searchViewController, animated: true, completion: nil)
    }
}

extension HomeCoordinator: SettingsDelegate {
    func openSettingsView(backgroundColor: (UIColor, UIColor)) {
        let settingsViewController = SettingsViewController()
        let viewModel = SettingsViewModel()
        viewModel.homeCoordinatorDelegate = self
        viewModel.backgroundColor = backgroundColor
        settingsViewController.viewModel = viewModel
        presenter.present(settingsViewController, animated: true, completion: nil)
    }
}

extension HomeCoordinator: ModalDelegate {
    func getWeatherForLocation() {
        controller.viewModel.fetchSettingsData()
        controller.viewModel.locationRequest.onNext((controller.viewModel.defaultLocation, controller.viewModel.unit))
    }
    
    func dismissModal() {
        presenter.dismiss(animated: true, completion: nil)
    }
}
