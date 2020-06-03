//
//  SettingsViewController.swift
//  WeatherApp
//
//  Created by Internship on 23/05/2020.
//  Copyright © 2020 Internship. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

private let locationCellIdentifier = "LocationTableViewCell"
private let unitCellIdentifier = "UnitTableViewCell"
private let conditionsCellIdentifier = "ConditionsTableViewCell"

class SettingsViewController: UIViewController {

    var viewModel: SettingsViewModel!
    private let disposeBag: DisposeBag = DisposeBag()
    
    let tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .clear
        table.register(LocationTableViewCell.self, forCellReuseIdentifier: locationCellIdentifier)
        table.register(UnitTableViewCell.self, forCellReuseIdentifier: unitCellIdentifier)
        table.register(ConditionsTableViewCell.self, forCellReuseIdentifier: conditionsCellIdentifier)
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    let doneButton: UIButton = {
        let button = UIButton()
        button.setTitle(R.string.localizable.done(), for: .normal)
        button.setTitleColor(UIColor(hex: "#6DA133"), for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 20
        button.addTarget(self, action: #selector(closeModal), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var bottomConstraint: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        
        viewModel.fetchSettingsData()
        viewModel.setSaveOption().disposed(by: disposeBag)
        viewModel.setDeleteLocationOption().disposed(by: disposeBag)
        viewModel.setChangeLocationOption().disposed(by: disposeBag)
        viewModel.initialize().disposed(by: disposeBag)
        getSettings()
    }
    
    @objc private func closeModal() {
        viewModel.saveSettingsAction.onNext((viewModel.tempSettings, viewModel.tempLocations))
    }
    
    private func setup() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        
        if #available(iOS 11.0, *), let keyWindow = UIApplication.shared.windows.filter({$0.isKeyWindow}).first, keyWindow.safeAreaInsets.bottom > 0 {
            viewModel.hasSafeArea = true
        }
        else {
            viewModel.hasSafeArea = false
        }
        
        setupLayout()
        setObservers()
    }
    
    private func setupLayout() {
        setGradientToView(color1: viewModel.backgroundColor.0, color2: viewModel.backgroundColor.1, view: view)
        
        view.addSubviews(views: [tableView, doneButton])
        
        bottomConstraint = viewModel.hasSafeArea ? doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor) : doneButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            
            doneButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 16),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 40),
            doneButton.widthAnchor.constraint(equalToConstant: 90),
            bottomConstraint
        ])
    }
    
    private func setObservers() {
        viewModel.fetchFinished.subscribe(onNext: { [weak self] in
            self?.tableView.reloadData()
        }).disposed(by: disposeBag)
        
        viewModel.alertOfError.subscribe(onNext: { [weak self] in
            let alert = self?.getErrorAlert()
            self?.present(alert!, animated: true, completion: nil)
        }).disposed(by: disposeBag)
        
        viewModel.showSpinner.subscribe(onNext: { [weak self] in
            self?.showSpinner()
        }).disposed(by: disposeBag)
    }
    
    private func getErrorAlert() -> UIAlertController{
        let alert = UIAlertController(title: R.string.localizable.error_alert_title(), message: R.string.localizable.error_alert_message(), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: R.string.localizable.alert_ok_action(), style: .cancel, handler: nil))
        
        return alert
    }
    
    private func getSettings() {
        viewModel.settingsRequest.onNext((viewModel.tempSettings, viewModel.tempLocations))
    }
    
    private func showSpinner() {
        let spinner = SpinnerViewController()
        spinner.view.frame = view.frame
        view.addSubview(spinner.view)
    }
}


extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.settingsPreviews.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.settingsPreviews[section].items.count
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = UIColor.clear
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerText = UITextView()
        headerText.textColor = .white
        headerText.textAlignment = .center
        headerText.font = UIFont.systemFont(ofSize: 20)
        headerText.backgroundColor = .clear
        headerText.isEditable = false
        headerText.text = viewModel.settingsPreviews[section].headerTitle
        headerText.textContainerInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0);
        return headerText
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = viewModel.settingsPreviews[indexPath.section]
        let item = section.items[indexPath.row]
        
        let selectedView = UIView()
        selectedView.backgroundColor = .clear
        
        switch item.type {
        case .location:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: locationCellIdentifier, for: indexPath) as? LocationTableViewCell else{
                fatalError(R.string.localizable.cell_error(locationCellIdentifier))
            }
            cell.backgroundColor = .clear
            cell.selectedBackgroundView = selectedView
            
            guard let location = item.data as? SearchPreview else { return cell }
            cell.configure(location)
            
            cell.onDeleteClicked = { [weak self] in
                self?.viewModel.deleteLocationAction.onNext(location)
            }
            
            cell.onCellClicked = { [weak self] in
                self?.viewModel.changeSelectedLocation.onNext(location)
            }
            
            return cell
        case .unit:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: unitCellIdentifier, for: indexPath) as? UnitTableViewCell else{
                fatalError(R.string.localizable.cell_error(unitCellIdentifier))
            }
            cell.backgroundColor = .clear
            cell.selectedBackgroundView = selectedView
            
            guard let unitPreview = item.data as? UnitPreview else { return cell }
            cell.configure(unitPreview)
            
            cell.onSelectOptionClicked = { [weak self] in
                if unitPreview.name.lowercased() == Units.metric.rawValue {
                    self?.viewModel.tempSettings.metric = true
                    self?.viewModel.tempSettings.imperial = false
                }
                else {
                    self?.viewModel.tempSettings.metric = false
                    self?.viewModel.tempSettings.imperial = true
                }
                
                self?.getSettings()
            }
            
            return cell
        case .condition:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: conditionsCellIdentifier, for: indexPath) as? ConditionsTableViewCell else{
                fatalError(R.string.localizable.cell_error(conditionsCellIdentifier))
            }
            cell.backgroundColor = .clear
            cell.selectedBackgroundView = selectedView
            
            guard let conditionsPreview = item.data as? ConditionsPreview else { return cell }
            cell.configure(conditionsPreview)
            
            cell.onHumidityOptionClicked = { [weak self] in
                self?.viewModel.tempSettings.humidity = !conditionsPreview.humidity
                self?.getSettings()
            }
            
            cell.onWindOptionClicked = { [weak self] in
                self?.viewModel.tempSettings.wind = !conditionsPreview.wind
                self?.getSettings()
            }
            
            cell.onPressureOptionClicked = { [weak self] in
                self?.viewModel.tempSettings.pressure = !conditionsPreview.pressure
                self?.getSettings()
            }
            return cell
        }
    }
}
