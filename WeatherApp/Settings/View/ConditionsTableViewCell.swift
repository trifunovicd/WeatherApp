//
//  ConditionsTableViewCell.swift
//  WeatherApp
//
//  Created by Internship on 24/05/2020.
//  Copyright © 2020 Internship. All rights reserved.
//

import UIKit

class ConditionsTableViewCell: UITableViewCell {

    private let humidityImageView: UIImageView = {
        let view = UIImageView(image: #imageLiteral(resourceName: "humidity_icon"))
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let humidityButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let windImageView: UIImageView = {
        let view = UIImageView(image: #imageLiteral(resourceName: "wind_icon"))
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let windButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let pressureImageView: UIImageView = {
        let view = UIImageView(image: #imageLiteral(resourceName: "pressure_icon"))
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let pressureButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var onHumidityOptionClicked: (() -> Void)?
    var onWindOptionClicked: (() -> Void)?
    var onPressureOptionClicked: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupSelectControl()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func configure(_ conditions: ConditionsPreview) {
        humidityButton.isSelected = conditions.humidity ? true : false
        windButton.isSelected = conditions.wind ? true : false
        pressureButton.isSelected = conditions.pressure ? true : false
    }
    
    private func setupLayout() {
        let stackView = getConditionsStackView()
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    private func setupSelectControl(){
        humidityButton.setImage(#imageLiteral(resourceName: "checkmark_uncheck"), for: .normal)
        humidityButton.setImage(#imageLiteral(resourceName: "checkmark_check"), for: .selected)
        humidityButton.addTarget(self, action: #selector(humidityClicked), for: .touchUpInside)
        
        windButton.setImage(#imageLiteral(resourceName: "checkmark_uncheck"), for: .normal)
        windButton.setImage(#imageLiteral(resourceName: "checkmark_check"), for: .selected)
        windButton.addTarget(self, action: #selector(windClicked), for: .touchUpInside)
        
        pressureButton.setImage(#imageLiteral(resourceName: "checkmark_uncheck"), for: .normal)
        pressureButton.setImage(#imageLiteral(resourceName: "checkmark_check"), for: .selected)
        pressureButton.addTarget(self, action: #selector(pressureClicked), for: .touchUpInside)
    }
    
    @objc private func humidityClicked(){
        onHumidityOptionClicked!()
    }
    
    @objc private func windClicked(){
        onWindOptionClicked!()
    }
    
    @objc private func pressureClicked(){
        onPressureOptionClicked!()
    }
    
    private func getConditionsStackView() -> UIStackView {
        let humidityStackView = UIStackView(arrangedSubviews: [humidityImageView, humidityButton])
        humidityStackView.setupView(axis: .vertical, alignment: .center, distribution: nil, spacing: 20)
        
        let windStackView = UIStackView(arrangedSubviews: [windImageView, windButton])
        windStackView.setupView(axis: .vertical, alignment: .center, distribution: nil, spacing: 20)
        
        let pressureStackView = UIStackView(arrangedSubviews: [pressureImageView, pressureButton])
        pressureStackView.setupView(axis: .vertical, alignment: .center, distribution: nil, spacing: 20)
        
        let stackView = UIStackView(arrangedSubviews: [humidityStackView, windStackView, pressureStackView])
        stackView.setupView(axis: .horizontal, alignment: .fill, distribution: .fillEqually, spacing: 20)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }

}
