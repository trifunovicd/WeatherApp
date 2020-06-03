//
//  SearchViewController.swift
//  WeatherApp
//
//  Created by Internship on 22/05/2020.
//  Copyright © 2020 Internship. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

private let cellIdentifier = "SearchTableViewCell"

class SearchViewController: UIViewController, UITextFieldDelegate {

    var viewModel: SearchViewModel!
    private let disposeBag: DisposeBag = DisposeBag()
    
    let closeButton: UIButton = {
        let button = UIButton()
        let image = #imageLiteral(resourceName: "close").withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.5)
        button.addTarget(self, action: #selector(closeModal), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .clear
        table.register(SearchTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private let searchTextBar: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Search"
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 20
        textField.setLeftPaddingPoints(15)
        textField.setRightIcon(icon: #imageLiteral(resourceName: "search_icon"), color: UIColor(hex: "#6DA133"), width: 30, height: 25, padding: 7)
        textField.becomeFirstResponder()
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let spinner = SpinnerViewController()
    private var bottomConstraint: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        
        viewModel.initialize().disposed(by: disposeBag)
        viewModel.setSaveOption().disposed(by: disposeBag)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        viewModel.hideKeyboard.onNext(())
        
        if let location = textField.text {
            viewModel.searchRequest.onNext(location)
            viewModel.showSpinner.onNext(())
        }
        
        return true
    }
    
    @objc private func handleKeyboardNotification(notification: NSNotification) {
        
        guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        if notification.name == UIResponder.keyboardWillShowNotification {
            bottomConstraint.constant = viewModel.hasSafeArea ? -(keyboardRect.height - 20) : -(keyboardRect.height + 10)
        }
        else {
            bottomConstraint.constant = viewModel.hasSafeArea ? 0 : -10
        }
    }
    
    @objc private func closeModal() {
        viewModel.closeModal.onNext(())
    }
    
    
    private func setup() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        
        searchTextBar.delegate = self
        
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
        
        view.addSubviews(views: [closeButton, tableView, searchTextBar])
        
        bottomConstraint = viewModel.hasSafeArea ? searchTextBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor) : searchTextBar.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10)
        
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            closeButton.heightAnchor.constraint(equalToConstant: 24),
            closeButton.widthAnchor.constraint(equalToConstant: 24),
            
            tableView.topAnchor.constraint(equalTo: closeButton.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            
            searchTextBar.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 10),
            searchTextBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            searchTextBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            searchTextBar.heightAnchor.constraint(equalToConstant: 40),
            bottomConstraint
        ])
    }
    
    private func setObservers() {
        viewModel.fetchFinished.subscribe(onNext: { [weak self] in
            self?.tableView.layoutIfNeeded()
            self?.tableView.setContentOffset(.zero, animated: false)
            self?.tableView.reloadData()
        }).disposed(by: disposeBag)
        
        viewModel.alertOfError.subscribe(onNext: { [weak self] in
            let alert = self?.getErrorAlert()
            self?.present(alert!, animated: true, completion: nil)
        }).disposed(by: disposeBag)
        
        viewModel.showSpinner.subscribe(onNext: { [weak self] in
            self?.showSpinner()
        }).disposed(by: disposeBag)
        
        viewModel.removeSpinner.subscribe(onNext: { [weak self] in
            self?.spinner.view.removeFromSuperview()
        }).disposed(by: disposeBag)
        
        viewModel.closeModal.subscribe(onNext: { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }).disposed(by: disposeBag)
        
        viewModel.hideKeyboard.subscribe(onNext: { [weak self] in
            self?.searchTextBar.resignFirstResponder()
        }).disposed(by: disposeBag)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func getErrorAlert() -> UIAlertController{
        let alert = UIAlertController(title: R.string.localizable.error_alert_title(), message: R.string.localizable.error_alert_message(), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: R.string.localizable.alert_ok_action(), style: .cancel, handler: nil))
        
        return alert
    }
    
    private func showSpinner() {
        spinner.view.frame = view.frame
        view.addSubview(spinner.view)
    }
}


extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.searchPreviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? SearchTableViewCell else{
            fatalError(R.string.localizable.cell_error(cellIdentifier))
        }
        
        cell.backgroundColor = .clear
        
        let location = viewModel.searchPreviews[indexPath.row]
        cell.configure(location)
        
        cell.onLocationClicked = { [weak self] in
            self?.viewModel.saveLocationAction.onNext(location)
            self?.viewModel.homeCoordinatorDelegate?.getWeatherForLocation()
            self?.viewModel.showSpinner.onNext(())
        }
        
        return cell
    }
    
}
