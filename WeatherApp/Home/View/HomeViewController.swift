//
//  HomeViewController.swift
//  WeatherApp
//
//  Created by Internship on 15/05/2020.
//  Copyright © 2020 Internship. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Hue

class HomeViewController: UIViewController {

    var viewModel: HomeViewModel!
    private let disposeBag: DisposeBag = DisposeBag()
    
    private let gradientView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#59B7E0")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let bodyImageView: UIImageView = {
        let view = UIImageView(image: #imageLiteral(resourceName: "body_image-clear-day"))
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let headerImageView: UIImageView = {
        let view = UIImageView(image: #imageLiteral(resourceName: "header_image-clear-day"))
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let tempLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont(name: "GothamRounded-Light", size: 72)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let conditionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont(name: "GothamRounded-Light", size: 24)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: "GothamRounded-Book", size: 36)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let tempMinValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont(name: "GothamRounded-Light", size: 24)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let tempMinLabel: UILabel = {
        let label = UILabel()
        label.text = R.string.localizable.temp_low_label()
        label.textColor = .white
        label.font = UIFont(name: "GothamRounded-Light", size: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let tempMaxValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont(name: "GothamRounded-Light", size: 24)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let tempMaxLabel: UILabel = {
        let label = UILabel()
        label.text = R.string.localizable.temp_high_label()
        label.textColor = .white
        label.font = UIFont(name: "GothamRounded-Light", size: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let humidityImageView: UIImageView = {
        let view = UIImageView(image: #imageLiteral(resourceName: "humidity_icon"))
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let humidityLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont(name: "GothamRounded-Light", size: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let windImageView: UIImageView = {
        let view = UIImageView(image: #imageLiteral(resourceName: "wind_icon"))
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let windLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont(name: "GothamRounded-Light", size: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let pressureImageView: UIImageView = {
        let view = UIImageView(image: #imageLiteral(resourceName: "pressure_icon"))
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let pressureLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont(name: "GothamRounded-Light", size: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let searchTextBar: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Search"
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 20
        textField.setLeftPaddingPoints(15)
        textField.setRightIcon(icon: #imageLiteral(resourceName: "search_icon"), color: UIColor(hex: "#6DA133"), width: 30, height: 25, padding: 7)
        textField.addTarget(self, action: #selector(openSearchView), for: .editingDidBegin)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let settingsButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "settings_icon"), for: .normal)
        button.addTarget(self, action: #selector(openSettingsView), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var bodyImageTopConstraint: NSLayoutConstraint!
    private var bodyImageHeight: NSLayoutConstraint!
    private var humidityStackView: UIStackView!
    private var windStackView: UIStackView!
    private var pressureStackView: UIStackView!
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setObservers()
        
        viewModel.fetchSettingsData()
        viewModel.initialize().disposed(by: disposeBag)
        viewModel.locationRequest.onNext((viewModel.defaultLocation, viewModel.unit))
    }
    
    @objc private func openSearchView() {
        searchTextBar.resignFirstResponder()
        viewModel.homeCoordinatorDelegate?.openSearchView(backgroundColor: viewModel.backgroundColor)
    }
    
    @objc private func openSettingsView() {
        viewModel.homeCoordinatorDelegate?.openSettingsView(backgroundColor: viewModel.backgroundColor)
    }
    
    
    private func setupLayout() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.backgroundColor = .white
        
        let tempStackView = getTempStackView()
        let tempDetailsStackView = getTempDetailsStackView()
        let infoStackView = getInfoStackView()
        let bottomStackView = getBottomStackView()
       
        view.addSubviews(views: [gradientView, headerImageView, bodyImageView, tempStackView, locationLabel, tempDetailsStackView, infoStackView, bottomStackView])
        view.bringSubviewToFront(headerImageView)
        view.bringSubviewToFront(tempStackView)
        
        bodyImageTopConstraint = bodyImageView.topAnchor.constraint(equalTo: view.topAnchor)
        bodyImageTopConstraint.priority = .defaultLow
        
        bodyImageHeight = bodyImageView.heightAnchor.constraint(equalToConstant: view.frame.height / 1.3)
        
        let tempStackTopConstraint = tempStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height / 4.4)
        tempStackTopConstraint.priority = .defaultLow

        NSLayoutConstraint.activate([
            gradientView.topAnchor.constraint(equalTo: view.topAnchor),
            gradientView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            gradientView.heightAnchor.constraint(equalToConstant: view.frame.height),
            
            bodyImageTopConstraint,
            bodyImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bodyImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bodyImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bodyImageHeight,
            
            headerImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerImageView.heightAnchor.constraint(equalToConstant: view.frame.height / 3),
            
            tempStackTopConstraint,
            tempStackView.bottomAnchor.constraint(equalTo: locationLabel.topAnchor, constant: -110),
            tempStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            locationLabel.bottomAnchor.constraint(equalTo: tempDetailsStackView.topAnchor, constant: -30),
            locationLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            locationLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            
            dividerView.widthAnchor.constraint(equalToConstant: 2),
                       
            tempDetailsStackView.bottomAnchor.constraint(equalTo: infoStackView.topAnchor, constant: -50),
            tempDetailsStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            infoStackView.bottomAnchor.constraint(equalTo: bottomStackView.topAnchor, constant: -50),
            infoStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            searchTextBar.heightAnchor.constraint(equalToConstant: 40),
            settingsButton.widthAnchor.constraint(equalToConstant: 24),
            
            bottomStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            bottomStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            bottomStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30)
            
        ])
    }
    
    private func getTempStackView() -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: [tempLabel, conditionLabel])
        stackView.setupView(axis: .vertical, alignment: .center, distribution: nil, spacing: nil)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }
    
    private func getTempDetailsStackView() -> UIStackView {
        let minStackView = UIStackView(arrangedSubviews: [tempMinValueLabel, tempMinLabel])
        minStackView.setupView(axis: .vertical, alignment: .center, distribution: nil, spacing: 10)
        
        let maxStackView = UIStackView(arrangedSubviews: [tempMaxValueLabel, tempMaxLabel])
        maxStackView.setupView(axis: .vertical, alignment: .center, distribution: nil, spacing: 10)
        
        let stackView = UIStackView(arrangedSubviews: [minStackView, dividerView, maxStackView])
        stackView.setupView(axis: .horizontal, alignment: .fill, distribution: nil, spacing: 40)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }
    
    private func getInfoStackView() -> UIStackView {
        humidityStackView = UIStackView(arrangedSubviews: [humidityImageView, humidityLabel])
        humidityStackView.setupView(axis: .vertical, alignment: .center, distribution: nil, spacing: 20)
        
        windStackView = UIStackView(arrangedSubviews: [windImageView, windLabel])
        windStackView.setupView(axis: .vertical, alignment: .center, distribution: nil, spacing: 20)
        
        pressureStackView = UIStackView(arrangedSubviews: [pressureImageView, pressureLabel])
        pressureStackView.setupView(axis: .vertical, alignment: .center, distribution: nil, spacing: 20)
        
        let stackView = UIStackView(arrangedSubviews: [humidityStackView, windStackView, pressureStackView])
        stackView.setupView(axis: .horizontal, alignment: .fill, distribution: .fillEqually, spacing: 20)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }
    
    private func getBottomStackView() -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: [settingsButton, searchTextBar])
        stackView.setupView(axis: .horizontal, alignment: .center, distribution: .fill, spacing: 20)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }
    
    private func setObservers() {
        viewModel.fetchFinished.subscribe(onNext: { [weak self] in
            self?.configure()
        }).disposed(by: disposeBag)
        
        viewModel.alertOfError.subscribe(onNext: { [weak self] in
            let alert = self?.getErrorAlert()
            self?.present(alert!, animated: true, completion: nil)
        }).disposed(by: disposeBag)
    }
    
    private func getErrorAlert() -> UIAlertController{
        let alert = UIAlertController(title: R.string.localizable.error_alert_title(), message: R.string.localizable.error_alert_message(), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: R.string.localizable.alert_ok_action(), style: .cancel, handler: nil))

        return alert
    }
    
    private func configure() {
        guard let location = viewModel.location else { return }
        guard let settings = viewModel.settings else { return }
        
        setBackgroundView(location: location)
        
        conditionLabel.text = location.condition
        locationLabel.text = viewModel.locationLabel
        humidityLabel.text = R.string.localizable.humidity(location.humidity)
        pressureLabel.text = R.string.localizable.pressure(location.pressure)
        
        if viewModel.unit == .imperial {
            tempLabel.text = location.temperature.toFahrenheit(showWithSymbol: false)
            tempMinValueLabel.text = location.temperatureMin.toFahrenheit(showWithSymbol: true)
            tempMaxValueLabel.text = location.temperatureMax.toFahrenheit(showWithSymbol: true)
            windLabel.text = R.string.localizable.wind_speed_imperial(String(location.windSpeed))
        }
        else {
            tempLabel.text = location.temperature.toCelsius(showWithSymbol: false)
            tempMinValueLabel.text = location.temperatureMin.toCelsius(showWithSymbol: true)
            tempMaxValueLabel.text = location.temperatureMax.toCelsius(showWithSymbol: true)
            windLabel.text = R.string.localizable.wind_speed_metric(String(location.windSpeed))
        }
        
        humidityStackView.isHidden = settings.humidity ? false : true
        windStackView.isHidden = settings.wind ? false : true
        pressureStackView.isHidden = settings.pressure ? false : true
    }
    
    private func setBackgroundView(location: LocationPreview) {
        headerImageView.image = UIImage(named: "header_image-\(location.icon)")
        bodyImageView.image = UIImage(named: "body_image-\(location.icon)")
        
        switch location.icon {
        case "clear-day", "partly-cloudy-day":
            bodyImageTopConstraint.priority = UILayoutPriority(rawValue: 249)
            viewModel.backgroundColor = (UIColor(hex: "#59B7E0"), UIColor(hex: "#D8D8D8"))
            bodyImageHeight.constant = view.frame.height / 1.3
        case "clear-night", "partly-cloudy-night":
            bodyImageTopConstraint.priority = UILayoutPriority(rawValue: 249)
            viewModel.backgroundColor = (UIColor(hex: "#044663"), UIColor(hex: "#234880"))
            bodyImageHeight.constant = view.frame.height / 1.3
        case "rain":
            bodyImageTopConstraint.priority = UILayoutPriority(rawValue: 249)
            viewModel.backgroundColor = (UIColor(hex: "#15587B"), UIColor(hex: "#4A75A2"))
            
        case "snow":
            bodyImageTopConstraint.priority = UILayoutPriority(rawValue: 249)
            viewModel.backgroundColor = (UIColor(hex: "#0B3A4E"), UIColor(hex: "#80D5F3"))
            
        case "fog":
            bodyImageTopConstraint.priority = UILayoutPriority(rawValue: 999)
            viewModel.backgroundColor = (UIColor(hex: "#ABD6E9"), UIColor(hex: "#D8D8D8"))
            bodyImageHeight.constant = view.frame.height
        default:
            bodyImageTopConstraint.priority = UILayoutPriority(rawValue: 249)
            viewModel.backgroundColor = (UIColor(hex: "#59B7E0"), UIColor(hex: "#D8D8D8"))
            bodyImageHeight.constant = view.frame.height / 1.3
        }
        
        setGradientToView(color1: viewModel.backgroundColor.0, color2: viewModel.backgroundColor.1, view: gradientView)
    }
}
