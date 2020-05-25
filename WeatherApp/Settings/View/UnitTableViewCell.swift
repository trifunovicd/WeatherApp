//
//  UnitTableViewCell.swift
//  WeatherApp
//
//  Created by Internship on 24/05/2020.
//  Copyright © 2020 Internship. All rights reserved.
//

import UIKit

class UnitTableViewCell: UITableViewCell {

    private let selectButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let unitNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var onSelectOptionClicked: (() -> Void)?
    
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
    
    func configure(_ unit: UnitPreview) {
        unitNameLabel.text = unit.name
        if unit.isSelected {
            selectButton.isSelected = true
        }
        else {
            selectButton.isSelected = false
        }
    }
    
    private func setupLayout() {
        contentView.addSubviews(views: [selectButton, unitNameLabel])
        
        NSLayoutConstraint.activate([
            selectButton.topAnchor.constraint(equalTo: contentView.topAnchor),
            selectButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            selectButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -2),
            selectButton.heightAnchor.constraint(equalToConstant: 35),
            selectButton.widthAnchor.constraint(equalToConstant: 35),
            
            unitNameLabel.centerYAnchor.constraint(equalTo: selectButton.centerYAnchor),
            unitNameLabel.leadingAnchor.constraint(equalTo: selectButton.trailingAnchor, constant: 8)
        ])
    }

    private func setupSelectControl(){
        selectButton.setImage(#imageLiteral(resourceName: "square_checkmark_uncheck"), for: .normal)
        selectButton.setImage(#imageLiteral(resourceName: "square_checkmark_check"), for: .selected)
        selectButton.addTarget(self, action: #selector(unitClicked), for: .touchUpInside)
    }
    
    @objc private func unitClicked(){
        onSelectOptionClicked!()
    }
}
